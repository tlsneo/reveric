// 职责: 发起人物四视图生成并展示整理、生成、保存状态。
// 关联文件:
//   lib/shared/providers/character_image.dart
//   lib/shared/services/character/image_orchestrator.dart
//   lib/desktop/widgets/workspace/character_profile_editor.dart
//   lib/mobile/pages/character_editor_page.dart
//   lib/shared/localization/locale_keys.dart
//   assets/translations/en/workspace.json
//   assets/translations/zh-CN/workspace.json
//   assets/translations/en/common.json
//   assets/translations/zh-CN/common.json
// 遵循的 Rules:
//   .agents/rules/state-management.md
//   .agents/rules/design-system.md
//   .agents/rules/error-handling.md

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/reveric_button.dart';
import '../../database/novel_content_database.dart';
import '../../localization/app_localization.dart';
import '../../localization/locale_keys.dart';
import '../../providers/character_image.dart';
import '../../services/ai/image.dart';
import '../../services/character/image_orchestrator.dart';
import '../../theme/theme.dart';

class CharacterImageGenerationButton extends ConsumerWidget {
  const CharacterImageGenerationButton({
    super.key,
    required this.databasePath,
    required this.characterId,
    required this.appearanceController,
    this.onGenerated,
    this.enabled = true,
    this.compact = false,
  });

  final String databasePath;
  final String characterId;
  final TextEditingController appearanceController;
  final ValueChanged<List<SubjectPhoto>>? onGenerated;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = characterImageProvider((
      databasePath: databasePath,
      characterId: characterId,
    ));
    final stage = ref.watch(provider);
    final labelKey = switch (stage) {
      null => LocaleKeys.workspaceCharacterImageGenerate,
      CharacterImageStage.preparing =>
        LocaleKeys.workspaceCharacterImagePreparing,
      CharacterImageStage.generating =>
        LocaleKeys.workspaceCharacterImageGenerating,
      CharacterImageStage.saving => LocaleKeys.commonSaving,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.end,
      children: [
        RevericButton.secondary(
          size: compact
              ? RevericButtonSize.compact
              : RevericButtonSize.standard,
          labelMaxLines: compact ? 1 : null,
          label: context.t(labelKey),
          icon: RevericIcons.auto_awesome_outlined,
          loading: stage != null,
          onPressed: !enabled || stage != null
              ? null
              : () async {
                  // 读取编辑器当前值，不能等防抖落库后再生成，也不覆盖人物形象原文。
                  final appearance = appearanceController.text;
                  try {
                    final photos = await ref
                        .read(provider.notifier)
                        .generate(appearance);
                    if (!context.mounted) {
                      return;
                    }
                    onGenerated?.call(photos);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.t(LocaleKeys.workspaceCharacterImageSaved),
                        ),
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    final key = switch (error) {
                      CharacterImageException(:final failure) =>
                        switch (failure) {
                          CharacterImageFailure.empty_appearance =>
                            LocaleKeys
                                .workspaceCharacterImageAppearanceRequired,
                          CharacterImageFailure.missing_model =>
                            LocaleKeys.workspaceCharacterImageModelsRequired,
                          CharacterImageFailure.unsupported_model =>
                            LocaleKeys.workspaceCharacterImageModelUnsupported,
                          CharacterImageFailure.missing_avatar =>
                            LocaleKeys.workspaceCharacterImageAvatarMissing,
                          CharacterImageFailure.empty_prompt =>
                            LocaleKeys.workspaceCharacterImagePromptFailed,
                          CharacterImageFailure.character_unavailable =>
                            LocaleKeys
                                .workspaceCharacterImageCharacterUnavailable,
                        },
                      AiImageFetchException() =>
                        LocaleKeys.workspaceCharacterImageResultPending,
                      _ => LocaleKeys.workspaceCharacterImageFailed,
                    };
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(context.t(key))));
                  }
                },
        ),
      ],
    );
  }
}
