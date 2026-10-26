// 职责: 按角色管理一键生图的运行态、模型选择与操作期生命周期。
// 关联文件:
//   lib/shared/services/character/image_orchestrator.dart
//   lib/shared/providers/novel_providers.dart
//   lib/shared/providers/settings_providers.dart
//   lib/shared/widgets/character/image_generation_button.dart
// 遵循的 Rules:
//   .agents/rules/state-management.md
//   .agents/rules/ai-calling.md

import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/novel_content_database.dart';
import '../logger/app_logger.dart';
import '../models/ai_provider.dart';
import '../models/production/image_request.dart';
import '../services/ai/ai_service_config.dart';
import '../services/ai/chat.dart';
import '../services/ai/image.dart';
import '../services/character/image_orchestrator.dart';
import 'async_read.dart';
import 'novel_providers.dart';
import 'settings_providers.dart';

typedef CharacterImageTarget = ({String databasePath, String characterId});

final characterImageProvider = NotifierProvider.autoDispose.family<
  CharacterImageController,
  CharacterImageStage?,
  CharacterImageTarget
>(CharacterImageController.new);

class CharacterImageController extends Notifier<CharacterImageStage?> {
  CharacterImageController(this.target);

  final CharacterImageTarget target;
  Future<List<SubjectPhoto>>? _active;

  @override
  CharacterImageStage? build() => null;

  Future<List<SubjectPhoto>> generate(String appearance) {
    final active = _active;
    if (active != null) {
      return active;
    }
    // 只在一次已确认的生成期间保活；切换角色不取消任务，也不能重复提交。
    final lease = ref.keepAlive();
    state = CharacterImageStage.preparing;
    final operation = run(appearance).whenComplete(() {
      _active = null;
      if (ref.mounted) {
        state = null;
      }
      lease.close();
    });
    _active = operation;
    return operation;
  }

  @protected
  Future<List<SubjectPhoto>> run(String appearance) async {
    AiClient? text;
    try {
      if (appearance.trim().isEmpty) {
        throw const CharacterImageException(
          CharacterImageFailure.empty_appearance,
        );
      }
      final textOption = ref.read(
        resolvedAiModelOptionForKindProvider(kind: AiModelKind.chat),
      );
      final imageOption = ref.read(
        resolvedAiModelOptionForKindProvider(kind: AiModelKind.image),
      );
      final settings = ref.read(aiSettingsProvider);
      final textConfig = textOption == null
          ? null
          : settings.findConfigForSelection(
              providerId: textOption.providerId,
              model: textOption.model,
              kind: AiModelKind.chat,
            );
      final imageConfig = imageOption == null
          ? null
          : settings.findConfigForSelection(
              providerId: imageOption.providerId,
              model: imageOption.model,
              kind: AiModelKind.image,
            );
      if (textOption == null ||
          imageOption == null ||
          textConfig == null ||
          imageConfig == null) {
        throw const CharacterImageException(CharacterImageFailure.missing_model);
      }
      text = AiClient.fromConfig(
        AiServiceConfig(provider: textConfig, chatModel: textOption.model),
      );
      final client = text;
      return await ref.container.withProvider(
        novelContentServiceProvider(target.databasePath),
        (content) => CharacterImageOrchestrator().generate(
          content: content,
          text: client,
          image: AiImageGenerationService(imageConfig, model: imageOption.model),
          request: CharacterImageRequest(
            characterId: target.characterId,
            appearance: appearance,
            capabilities: ProductionImageCapabilities(
              imageConfig,
              imageOption.model,
            ),
          ),
          onStage: (stage) {
            if (ref.mounted) {
              state = stage;
            }
          },
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        '[CharacterImage] generation failed character=${target.characterId}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      text?.dispose();
    }
  }
}
