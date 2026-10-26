// 职责: 验证人物生图使用当前外观、冻结头像引用，并安全追加真实入库照片。
// 关联文件:
//   lib/shared/services/character/image_orchestrator.dart
//   lib/shared/services/novel_content.dart
//   lib/shared/services/image_library_service.dart
//   lib/shared/services/ai/prompts/ai_prompt_service.dart
//   lib/shared/database/novel_content_database.dart

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:reveric/shared/agent/agent_hook.dart';
import 'package:reveric/shared/database/app_database.dart' as app;
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/models/ai_chat_models.dart';
import 'package:reveric/shared/models/asset_purpose.dart';
import 'package:reveric/shared/models/production/asset_content.dart';
import 'package:reveric/shared/models/production/image_request.dart';
import 'package:reveric/shared/services/ai/chat.dart';
import 'package:reveric/shared/services/ai/image.dart';
import 'package:reveric/shared/services/ai/prompt_template.dart';
import 'package:reveric/shared/services/ai/prompts/ai_prompt_service.dart';
import 'package:reveric/shared/services/character/image_orchestrator.dart';
import 'package:reveric/shared/services/image_library_service.dart';
import 'package:reveric/shared/services/novel_content.dart';
import 'package:reveric/shared/utils/storage_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const characterId = 'character';
  const savedAppearance = 'Stale saved appearance: long black hair.';
  const biography = 'Private biography: secretly rules a distant kingdom.';
  const currentAppearance =
      '  少年感，年龄未知；银框眼镜 & 短发。\n'
      '蓝色外套，{{appearance}} 是原文。  ';
  const finalPrompt = 'One 16:9 four-view character sheet on white.';
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;
  late app.AppDatabase appDb;
  late NovelContentDatabase db;
  late ImageLibraryService library;
  late _Content content;
  late app.AssetRow original;
  late File output;
  late ProductionImageCapabilities capabilities;
  late _TextClient text;
  late _ImageClient image;
  late List<CharacterImageStage> stages;

  Future<List<SubjectPhoto>> generate([
    String appearance = currentAppearance,
  ]) => CharacterImageOrchestrator().generate(
    content: content,
    text: text,
    image: image,
    request: CharacterImageRequest(
      characterId: characterId,
      appearance: appearance,
      capabilities: capabilities,
    ),
    onStage: stages.add,
  );

  Future<CharacterProfile> character() async =>
      (await content.getCharacterProfileById(characterId))!;

  setUpAll(PromptTemplateService.loadAll);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('character-image-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
    await RevericPaths.initialize();
    appDb = app.AppDatabase.forTest(NativeDatabase.memory());
    db = NovelContentDatabase.forTest(NativeDatabase.memory());
    library = buildImageLibraryService(appDb);
    content = _Content(db, imageLibraryService: library);
    await appDb
        .into(appDb.aiProviders)
        .insert(
          app.AiProvidersCompanion.insert(
            id: 'image',
            name: 'Images',
            type: 'openai',
            enabled: const Value(true),
            apiKey: const Value('test'),
            imageModels: const Value(['gpt-image-2']),
          ),
        );
    capabilities = ProductionImageCapabilities(
      (await appDb.aiProviderDao.getById('image'))!,
      'gpt-image-2',
    );
    final source = await File(
      '${root.path}/original.png',
    ).writeAsBytes(img.encodePng(img.Image(width: 2, height: 2)));
    original = await library.importFile(
      source.path,
      novelId: 'work',
      purpose: AssetPurpose.photo,
    );
    output = await File(
      '${root.path}/generated.png',
    ).writeAsBytes(img.encodePng(img.Image(width: 4, height: 2)));
    await db
        .into(db.characterProfiles)
        .insert(
          CharacterProfilesCompanion.insert(
            id: characterId,
            name: 'Lin',
            appearance: const Value(savedAppearance),
            biography: const Value(biography),
            photos: Value([
              SubjectPhoto(assetId: original.id, name: 'Original'),
            ]),
          ),
        );
    text = _TextClient()..reply = '  $finalPrompt\n';
    image = _ImageClient(
      () async => AiImageGenerationResult(localFilePath: output.path),
    );
    stages = [];
  });

  tearDown(() async {
    await db.close();
    await appDb.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  test(
    'no avatar uses current editor appearance and appends a generated photo',
    () async {
      final before = await character();
      final photos = await generate();

      final message = text.calls.single.single;
      expect(message.role, AiMessageRole.user);
      expect(
        message.content,
        AiPromptService.fromInitializedTemplates().task.characterImage(
          appearance: currentAppearance.trim(),
          hasAvatar: false,
        ),
      );
      expect(
        message.content,
        contains(
          '<appearance_data>\n${currentAppearance.trim()}\n</appearance_data>',
        ),
      );
      expect(message.content, isNot(contains(savedAppearance)));
      expect(message.content, isNot(contains(biography)));
      expect(text.timeout, const Duration(minutes: 2));
      final call = image.calls.single;
      expect(call.editing, isFalse);
      expect(call.prompt, finalPrompt);
      expect(call.references, isEmpty);
      expect(call.size, '2048x1152');
      expect(call.ratio, '16:9');
      expect(call.resolution, '2K');
      expect(stages, CharacterImageStage.values);
      expect(photos, hasLength(2));
      expect(photos.first, before.photos!.single);
      final after = await character();
      expect(after.photos, photos);
      expect(after.avatarAssetId, isNull);
      expect(after.appearance, savedAppearance);
      expect(after.biography, biography);

      final asset = (await appDb.assetDao.getAsset(photos.last.assetId))!;
      expect(asset.purpose, AssetPurpose.photo.value);
      expect(asset.source, 'generated');
      expect(asset.novelId, 'work');
      final metadata = asset.content! as ImageAssetContent;
      expect(metadata.generation?.prompt, finalPrompt);
      expect(metadata.generation?.model, 'gpt-image-2');
      expect(
        await File(RevericPaths.resolveStored(asset.path)!).readAsBytes(),
        await output.readAsBytes(),
      );
      expect(await appDb.select(appDb.assets).get(), hasLength(2));
    },
  );

  test(
    'saved avatar selects editing and freezes bytes before text completion',
    () async {
      await content.updateCharacterAvatarAndPhotos(
        entryId: characterId,
        avatarAssetId: original.id,
      );
      final avatarFile = File(RevericPaths.resolveStored(original.path)!);
      final frozenBytes = await avatarFile.readAsBytes();
      text.beforeReply = () async {
        await content.updateCharacterAvatarAndPhotos(
          entryId: characterId,
          avatarAssetId: '',
        );
        await (db.update(
          db.characterProfiles,
        )..where((row) => row.id.equals(characterId))).write(
          const CharacterProfilesCompanion(
            appearance: Value('Appearance saved while generating'),
          ),
        );
        await avatarFile.writeAsBytes(await output.readAsBytes());
      };

      final photos = await generate();

      expect(
        text.calls.single.single.content,
        AiPromptService.fromInitializedTemplates().task.characterImage(
          appearance: currentAppearance.trim(),
          hasAvatar: true,
        ),
      );
      final call = image.calls.single;
      expect(call.editing, isTrue);
      expect(call.references, [
        'data:image/png;base64,${base64Encode(frozenBytes)}',
      ]);
      expect(call.prompt, finalPrompt);
      expect(call.ratio, '16:9');
      expect(call.resolution, '2K');
      expect(call.size, '2048x1152');
      final after = await character();
      expect(after.avatarAssetId, isNull);
      expect(after.appearance, 'Appearance saved while generating');
      expect(after.photos, photos);
      expect(photos.first.assetId, original.id);
      expect(photos, hasLength(2));
    },
  );

  test('empty appearance fails before either AI request', () async {
    await expectLater(
      generate(' \n\t '),
      _fails(CharacterImageFailure.empty_appearance),
    );
    expect(text.calls, isEmpty);
    expect(image.calls, isEmpty);
    expect(await appDb.select(appDb.assets).get(), hasLength(1));
  });

  test('missing saved avatar does not fall back to text-to-image', () async {
    await content.updateCharacterAvatarAndPhotos(
      entryId: characterId,
      avatarAssetId: 'missing-asset',
    );
    await expectLater(generate(), _fails(CharacterImageFailure.missing_avatar));
    expect(text.calls, isEmpty);
    expect(image.calls, isEmpty);
    expect((await character()).avatarAssetId, 'missing-asset');
    expect(await appDb.select(appDb.assets).get(), hasLength(1));
  });

  test('missing avatar file stops before either paid request', () async {
    await content.updateCharacterAvatarAndPhotos(
      entryId: characterId,
      avatarAssetId: original.id,
    );
    await File(RevericPaths.resolveStored(original.path)!).delete();

    await expectLater(generate(), _fails(CharacterImageFailure.missing_avatar));
    expect(text.calls, isEmpty);
    expect(image.calls, isEmpty);
  });

  for (final model in ['unregistered-model', 'gpt-image-1']) {
    for (final hasAvatar in [false, true]) {
      test(
        'image model $model is submitted without capability gating, avatar=$hasAvatar',
        () async {
          capabilities = ProductionImageCapabilities(
            capabilities.provider,
            model,
          );
          if (hasAvatar) {
            await content.updateCharacterAvatarAndPhotos(
              entryId: characterId,
              avatarAssetId: original.id,
            );
          }

          final photos = await generate();

          expect(text.calls, hasLength(1));
          final call = image.calls.single;
          expect(call.editing, hasAvatar);
          expect(call.references, hasLength(hasAvatar ? 1 : 0));
          expect(call.size, '2048x1152');
          expect(call.ratio, '16:9');
          expect(call.resolution, '2K');
          expect(photos, hasLength(2));
          expect(
            (await character()).avatarAssetId,
            hasAvatar ? original.id : null,
          );
          final asset = (await appDb.assetDao.getAsset(photos.last.assetId))!;
          expect(
            (asset.content! as ImageAssetContent).generation?.model,
            model,
          );
        },
      );
    }
  }

  test('empty text completion fails before requesting an image', () async {
    text.reply = ' \n ';
    await expectLater(generate(), _fails(CharacterImageFailure.empty_prompt));
    expect(text.calls, hasLength(1));
    expect(image.calls, isEmpty);
    expect(await appDb.select(appDb.assets).get(), hasLength(1));
  });

  test(
    'image failure leaves avatar, photos and saved appearance intact',
    () async {
      await content.updateCharacterAvatarAndPhotos(
        entryId: characterId,
        avatarAssetId: original.id,
      );
      final before = await character();
      const failure = AiImageGenerationException('Image service failed');
      image.respond = () async => throw failure;

      await expectLater(generate(), throwsA(same(failure)));

      final after = await character();
      expect(after.avatarAssetId, before.avatarAssetId);
      expect(after.photos, before.photos);
      expect(after.appearance, before.appearance);
      expect(image.calls.single.editing, isTrue);
      expect(await appDb.select(appDb.assets).get(), hasLength(1));
    },
  );

  test(
    'append preserves a photo and avatar saved during image generation',
    () async {
      final manualFile = await File(
        '${root.path}/manual.png',
      ).writeAsBytes(img.encodePng(img.Image(width: 3, height: 2)));
      final manual = await library.importFile(
        manualFile.path,
        novelId: 'work',
        purpose: AssetPurpose.photo,
      );
      final concurrentPhotos = [
        SubjectPhoto(assetId: original.id, name: 'Renamed while generating'),
        SubjectPhoto(assetId: manual.id, name: 'Added while generating'),
      ];
      image.respond = () async {
        await content.updateCharacterAvatarAndPhotos(
          entryId: characterId,
          avatarAssetId: manual.id,
          photos: concurrentPhotos,
        );
        return AiImageGenerationResult(localFilePath: output.path);
      };

      final photos = await generate();

      expect(photos, [
        ...concurrentPhotos,
        SubjectPhoto(assetId: photos.last.assetId),
      ]);
      expect(photos.last.assetId, isNot(isIn([original.id, manual.id])));
      final after = await character();
      expect(after.photos, photos);
      expect(after.avatarAssetId, manual.id);
      expect(after.appearance, savedAppearance);
    },
  );

  test(
    'deletion during prompt preparation prevents the image request',
    () async {
      text.beforeReply = () async {
        await db.characterProfileDao.softDelete(characterId);
      };

      await expectLater(
        generate(),
        _fails(CharacterImageFailure.character_unavailable),
      );

      expect(text.calls, hasLength(1));
      expect(image.calls, isEmpty);
      expect(await content.getCharacterProfileById(characterId), isNull);
      expect(await appDb.select(appDb.assets).get(), hasLength(1));
    },
  );

  test(
    'deletion during generation retains the asset without restoring character',
    () async {
      final before = await character();
      image.respond = () async {
        await db.characterProfileDao.softDelete(characterId);
        return AiImageGenerationResult(localFilePath: output.path);
      };

      await expectLater(
        generate(),
        _fails(CharacterImageFailure.character_unavailable),
      );

      expect(await content.getCharacterProfileById(characterId), isNull);
      final deleted = await db.select(db.characterProfiles).getSingle();
      expect(deleted.deletedAt, isNot(notDeletedSentinel));
      expect(deleted.photos, before.photos);
      expect(deleted.avatarAssetId, before.avatarAssetId);
      final assets = await appDb.select(appDb.assets).get();
      expect(assets, hasLength(2));
      final generated = assets.singleWhere((asset) => asset.id != original.id);
      expect(generated.source, 'generated');
      expect(generated.purpose, AssetPurpose.photo.value);
      expect(
        await File(RevericPaths.resolveStored(generated.path)!).readAsBytes(),
        await output.readAsBytes(),
      );
    },
  );
}

Matcher _fails(CharacterImageFailure failure) => throwsA(
  isA<CharacterImageException>().having(
    (error) => error.failure,
    'failure',
    failure,
  ),
);

class _Content extends NovelContentService {
  _Content(super.database, {super.imageLibraryService});

  @override
  Future<String> requireNovelId() async => 'work';
}

class _TextClient extends Fake implements AiClient {
  final calls = <List<AiMessage>>[];
  String reply = '';
  Duration? timeout;
  Future<void> Function()? beforeReply;

  @override
  Future<String> chatCompletionDetached(
    List<AiMessage> messages, {
    required Duration timeout,
    AiSessionContext? context,
    List<AgentHook> hooks = const [],
  }) async {
    calls.add(List.of(messages));
    this.timeout = timeout;
    await beforeReply?.call();
    return reply;
  }
}

class _ImageClient extends Fake implements AiImageGenerationService {
  _ImageClient(this.respond);

  Future<AiImageGenerationResult> Function() respond;
  final calls =
      <
        ({
          bool editing,
          String prompt,
          List<String> references,
          String? size,
          String? ratio,
          String? resolution,
        })
      >[];

  @override
  Future<AiImageGenerationResult> generateImage(
    String prompt, {
    String? model,
    String? size,
    String? quality,
    String? aspectRatio,
    String? resolution,
    ImageSubmitted? onSubmitted,
  }) {
    calls.add((
      editing: false,
      prompt: prompt,
      references: [],
      size: size,
      ratio: aspectRatio,
      resolution: resolution,
    ));
    return respond();
  }

  @override
  Future<AiImageGenerationResult> editImages(
    String prompt, {
    required List<String> imageData,
    String? model,
    String? size,
    String? quality,
    String? aspectRatio,
    String? resolution,
    ImageSubmitted? onSubmitted,
  }) {
    calls.add((
      editing: true,
      prompt: prompt,
      references: List.of(imageData),
      size: size,
      ratio: aspectRatio,
      resolution: resolution,
    ));
    return respond();
  }
}
