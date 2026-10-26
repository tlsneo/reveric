// 职责: 将人物外观按四视图模板整理为提示词，直接出图并追加到原角色照片。
// 关联文件:
//   lib/shared/services/ai/prompts/use_cases/task_prompt_use_case.dart
//   lib/shared/services/ai/chat.dart
//   lib/shared/services/ai/image.dart
//   lib/shared/services/novel_content.dart
//   lib/shared/providers/character_image.dart
// 遵循的 Rules:
//   .agents/rules/ai-calling.md
//   .agents/rules/service-naming.md
//   .agents/rules/file-access.md

import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

import '../../database/novel_content_database.dart';
import '../../logger/app_logger.dart';
import '../../models/ai_chat_models.dart';
import '../../models/asset_purpose.dart';
import '../../models/production/image_request.dart';
import '../../utils/storage_paths.dart';
import '../ai/chat.dart';
import '../ai/image.dart';
import '../ai/prompts/ai_prompt_service.dart';
import '../novel_content.dart';

enum CharacterImageStage { preparing, generating, saving }

enum CharacterImageFailure {
  empty_appearance,
  missing_model,
  unsupported_model,
  missing_avatar,
  empty_prompt,
  character_unavailable,
}

class CharacterImageException implements Exception {
  const CharacterImageException(this.failure);
  final CharacterImageFailure failure;

  @override
  String toString() => 'CharacterImageException(${failure.name})';
}

class CharacterImageRequest {
  const CharacterImageRequest({
    required this.characterId,
    required this.appearance,
    required this.capabilities,
  });

  final String characterId;
  final String appearance;
  final ProductionImageCapabilities capabilities;
}

class CharacterImageOrchestrator {
  Future<List<SubjectPhoto>> generate({
    required NovelContentService content,
    required AiClient text,
    required AiImageGenerationService image,
    required CharacterImageRequest request,
    required void Function(CharacterImageStage) onStage,
  }) async {
    final appearance = request.appearance.trim();
    if (appearance.isEmpty) {
      throw const CharacterImageException(
        CharacterImageFailure.empty_appearance,
      );
    }
    final library = content.imageLibraryService;
    if (library == null) {
      throw StateError('Character image generation requires the image library');
    }
    final character = await content.getCharacterProfileById(request.characterId);
    if (character == null) {
      throw const CharacterImageException(
        CharacterImageFailure.character_unavailable,
      );
    }
    final novelId = await content.requireNovelId();
    final avatarId = character.avatarAssetId;
    final hasAvatar = avatarId != null && avatarId.isNotEmpty;
    final capabilities = request.capabilities;
    final resolution = capabilities.resolutions.contains('2K')
        ? '2K'
        : capabilities.resolutions.first;
    const ratio = '16:9';
    try {
      capabilities.validate(
        prompt: appearance,
        ratio: ratio,
        resolution: resolution,
        references: hasAvatar ? 1 : 0,
      );
    } on FormatException {
      throw const CharacterImageException(
        CharacterImageFailure.unsupported_model,
      );
    }

    // 在整理提示词前冻结头像字节，避免生成期间更换或移除头像改变本次输入。
    String? reference;
    if (hasAvatar) {
      final path = RevericPaths.resolveStored(await library.assetPath(avatarId));
      if (path == null || !await File(path).exists()) {
        throw const CharacterImageException(
          CharacterImageFailure.missing_avatar,
        );
      }
      final bytes = await File(path).readAsBytes();
      final mime = lookupMimeType(path, headerBytes: bytes);
      if (bytes.isEmpty || mime == null || !mime.startsWith('image/')) {
        throw const CharacterImageException(
          CharacterImageFailure.missing_avatar,
        );
      }
      reference = 'data:$mime;base64,${base64Encode(bytes)}';
    }

    onStage(CharacterImageStage.preparing);
    final prompt = (await text.chatCompletionDetached(
      [
        AiMessage.user(
          id: 'character_image_prompt',
          content: AiPromptService.fromInitializedTemplates().task.characterImage(
            appearance: appearance,
            hasAvatar: hasAvatar,
          ),
        ),
      ],
      timeout: const Duration(minutes: 2),
    )).trim();
    if (prompt.isEmpty) {
      throw const CharacterImageException(CharacterImageFailure.empty_prompt);
    }
    if (await content.getCharacterProfileById(request.characterId) == null) {
      throw const CharacterImageException(
        CharacterImageFailure.character_unavailable,
      );
    }

    onStage(CharacterImageStage.generating);
    final size = capabilities.size(ratio, resolution);
    final result = reference == null
        ? await image.generateImage(
            prompt,
            size: size,
            aspectRatio: ratio,
            resolution: resolution,
          )
        : await image.editImages(
            prompt,
            imageData: [reference],
            size: size,
            aspectRatio: ratio,
            resolution: resolution,
          );
    onStage(CharacterImageStage.saving);
    final asset = await library.importGenerated(
      result,
      novelId: novelId,
      purpose: AssetPurpose.photo,
      prompt: prompt,
      model: capabilities.model,
    );

    try {
      return await content.database.transaction(() async {
        final current = await content.getCharacterProfileById(
          request.characterId,
        );
        if (current == null) {
          // 已生成的资产留在图片库，不恢复已删除角色。
          throw const CharacterImageException(
            CharacterImageFailure.character_unavailable,
          );
        }
        final photos = [
          ...?current.photos,
          if (!(current.photos ?? const <SubjectPhoto>[]).any(
            (photo) => photo.assetId == asset.id,
          ))
            SubjectPhoto(assetId: asset.id),
        ];
        await content.updateCharacterAvatarAndPhotos(
          entryId: current.id,
          photos: photos,
        );
        return photos;
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        '[DB] table=character_profiles operation=UPDATE action=append_photo '
        'id=${request.characterId} asset=${asset.id}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
