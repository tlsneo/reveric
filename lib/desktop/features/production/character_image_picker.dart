// 职责: 按角色选择已有头像或照片作为制片参考，不改变照片归属或资产库状态。
// 关联文件:
//   lib/desktop/features/production/subject_picker.dart
//   lib/desktop/features/production/node_card.dart
//   lib/shared/services/subjects.dart
//   lib/shared/services/production/canvas_service.dart
//   lib/shared/localization/locale_keys.dart
//   assets/translations/en/screenplay.json
//   assets/translations/zh-CN/screenplay.json
//   assets/translations/en/workspace.json
//   assets/translations/zh-CN/workspace.json
//   assets/translations/en/common.json
//   assets/translations/zh-CN/common.json
// 遵循的 Rules:
//   .agents/rules/hooks.md
//   .agents/rules/design-system.md
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/components/reveric_button.dart';
import '../../../shared/components/reveric_dialog.dart';
import '../../../shared/components/reveric_placeholder.dart';
import '../../../shared/database/app_database.dart' show AssetRow;
import '../../../shared/localization/app_localization.dart';
import '../../../shared/localization/locale_keys.dart';
import '../../../shared/logger/app_logger.dart';
import '../../../shared/services/production/canvas_service.dart';
import '../../../shared/services/subjects.dart';
import '../../../shared/theme/theme.dart';
import '../../../shared/widgets/subject_picker.dart';
import 'node_card.dart';
import 'subject_picker.dart';

Future<AssetRow?> pickProductionCharacterImage(
  BuildContext context,
  ProductionCanvasService service,
) async {
  final characterId = await pickProductionSubject(
    context,
    service,
    kind: SubjectKind.character,
  );
  if (characterId == null || !context.mounted) {
    return null;
  }
  final assetId = await showRevericDialog<String>(
    context: context,
    builder: (_) =>
        _CharacterImages(service: service, characterId: characterId),
  );
  if (assetId == null) {
    return null;
  }
  return service.requireAsset(assetId, type: 'image');
}

class _CharacterImages extends HookWidget {
  const _CharacterImages({required this.service, required this.characterId});
  final ProductionCanvasService service;
  final String characterId;

  @override
  Widget build(BuildContext context) {
    final profile = useStream(
      useMemoized(
        () =>
            watchSubjectProfile(service.db, SubjectKind.character, characterId),
        [service, characterId],
      ),
    );
    useEffect(() {
      if (profile.hasError) {
        AppLogger.error(
          '[Production] Character images failed to load: $characterId',
          error: profile.error,
          stackTrace: profile.stackTrace,
        );
      }
      return null;
    }, [characterId, profile.error]);
    final data = profile.data;
    final avatar = data?.entity.avatarAssetId;
    // 同一资产同时是头像和照片时只展示一次，保留照片的命名。
    final images = <String, String>{
      if (avatar != null && avatar.isNotEmpty)
        avatar: context.t(LocaleKeys.workspaceCharacterAvatar),
      for (final photo in data?.photos ?? [])
        photo.assetId: photo.name.isNotEmpty
            ? photo.name
            : photo.assetId == avatar
            ? context.t(LocaleKeys.workspaceCharacterAvatar)
            : context.t(LocaleKeys.commonUntitled),
    }.entries.toList();
    final body = profile.hasError
        ? Center(
            child: RevericPlaceholder.error(
              title: context.t(LocaleKeys.commonLoadFailed),
            ),
          )
        : data == null
        ? const Center(child: CircularProgressIndicator())
        : images.isEmpty
        ? Center(
            child: RevericPlaceholder.empty(
              icon: RevericIcons.image_outlined,
              title: context.t(LocaleKeys.productionPhotosEmpty),
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 168,
              mainAxisExtent: 200,
              crossAxisSpacing: RevericSpacing.md,
              mainAxisSpacing: RevericSpacing.md,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return SubjectPickerTile(
                key: ValueKey('character-image-${image.key}'),
                label: image.value,
                cover: ProductionAssetThumb(
                  service: service,
                  assetId: image.key,
                ),
                onTap: () => Navigator.of(context).pop(image.key),
              );
            },
          );
    return RevericDialog.panel(
      width: 720,
      title: Text(
        data?.entity.label ?? context.t(LocaleKeys.productionPickCharacter),
      ),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Flexible(child: SizedBox(height: 420, child: body))],
        ),
      ),
      actions: [
        RevericButton.text(
          label: context.t(LocaleKeys.commonCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
