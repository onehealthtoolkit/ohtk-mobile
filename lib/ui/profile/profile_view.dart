import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/language_dropdown.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/login/picker_sheets.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:podd_app/ui/profile/profile_widgets.dart';
import 'package:podd_app/ui/report_type/form_simulator_view.dart';
import 'package:podd_app/ui/report_type/qr_report_type_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

Color get _profileTeal => OhtkTheme.palette.teal700;
Color get _profileTealMid => OhtkTheme.palette.teal800;

String _themePresetLabel(OhtkThemePreset preset) {
  return preset.label;
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) {
        return Container(
          color: incidentsSand,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
              children: [
                _IdentityHeader(viewModel: viewModel),
                const SizedBox(height: 16),
                _ConsolidatedCard(viewModel: viewModel),
                _ContactInfoCard(viewModel: viewModel),
                _AdminToolsCard(),
                const SizedBox(height: 8),
                ProfileSignOutRow(
                  label: AppLocalizations.of(context)!.logoutButton,
                  onTap: () => _confirmSignOut(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, ProfileViewModel viewModel) async {
    final localize = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localize.signOutConfirmTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: incidentsInk,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localize.signOutConfirmBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: incidentsMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: TextButton.styleFrom(
                    backgroundColor: incidentsErrorRed,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    localize.logoutButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: incidentsInk,
                    side: const BorderSide(color: incidentsHair, width: 1),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    localize.cancel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      viewModel.logout();
    }
  }
}

class _IdentityHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _IdentityHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final fullName = _displayName(viewModel);
    final usernameLine = _usernameLine(viewModel);

    return OhtkCard(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      child: Column(
        children: [
          _Avatar(),
          if (viewModel.hasErrorForKey('uploadFail')) ...[
            const SizedBox(height: 10),
            Text(
              viewModel.error('uploadFail'),
              style: const TextStyle(
                color: incidentsErrorRed,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: incidentsInk,
              height: 1.25,
            ),
          ),
          if (usernameLine != null) ...[
            const SizedBox(height: 4),
            Text(
              usernameLine,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: incidentsMuted,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _displayName(ProfileViewModel vm) {
    final parts = [
      (vm.firstName ?? '').trim(),
      (vm.lastName ?? '').trim(),
    ].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) {
      return vm.username ?? '—';
    }
    return parts.join(' ');
  }

  String? _usernameLine(ProfileViewModel vm) {
    final username = (vm.username ?? '').trim();
    final authority = (vm.authorityName ?? '').trim();
    final bits = <String>[];
    if (username.isNotEmpty) bits.add('@$username');
    if (authority.isNotEmpty) bits.add(authority);
    if (bits.isEmpty) return null;
    return bits.join('  ·  ');
  }
}

class _Avatar extends StackedHookView<ProfileViewModel> {
  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: _profileTeal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: incidentsHair, width: 1),
              ),
              child: ClipOval(
                child: viewModel.isBusy
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _profileTeal,
                          ),
                        ),
                      )
                    : viewModel.avatarUrl == null
                        ? const _AvatarFallback()
                        : Image.network(
                            viewModel.avatarUrl!,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _AvatarFallback(),
                          ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: _profileTeal,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2.5),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: viewModel.isBusy
                    ? null
                    : () => _showAvatarSheet(context, viewModel),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarSheet(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _AvatarPickerSheet(
        onPickCamera: () async {
          Navigator.pop(sheetContext);
          final image = await _pickImage(ImageSource.camera);
          if (image != null) await viewModel.setPhoto(image);
        },
        onPickGallery: () async {
          Navigator.pop(sheetContext);
          final image = await _pickImage(ImageSource.gallery);
          if (image != null) await viewModel.setPhoto(image);
        },
      ),
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      return await picker.pickImage(source: source);
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _profileTeal.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        size: 40,
        color: _profileTeal,
      ),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  const _AvatarPickerSheet({
    required this.onPickCamera,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: incidentsHair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localize.avatarSheetTitle,
                  style: const TextStyle(
                    color: incidentsInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localize.avatarSheetSubtitle,
                  style: const TextStyle(
                    color: incidentsMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: incidentsHair),
            _SheetRow(
              icon: Icons.photo_camera_outlined,
              label: localize.avatarSheetTakePhoto,
              onTap: onPickCamera,
            ),
            _SheetRow(
              icon: Icons.photo_library_outlined,
              label: localize.avatarSheetChooseGallery,
              onTap: onPickGallery,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const fg = incidentsInk;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: incidentsHair, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsolidatedCard extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _ConsolidatedCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final isMulti = viewModel.hasMultipleAssignedVillages;
    final activeVillage =
        viewModel.selectedVillage?.name ?? viewModel.assignedVillageNames;
    final hasVillage = (activeVillage ?? '').trim().isNotEmpty;
    final languageLabel = _resolveLanguageNativeName(viewModel.language);
    final appTheme = locator<AppTheme>();

    return ProfileSectionCard(
      children: [
        if (isMulti)
          ProfileActionRow(
            icon: Icons.location_city_outlined,
            title: localize.profileLabelActiveVillage,
            value: hasVillage ? activeVillage : null,
            onTap: () => _showVillageSheet(context),
          )
        else
          ProfileDataRow(
            label: localize.registerVillageLabel,
            value: hasVillage ? activeVillage : null,
            emptyValueText: localize.profileValueNotAssigned,
          ),
        ProfileActionRow(
          icon: Icons.edit_outlined,
          title: localize.updateProfileButton,
          onTap: () => GoRouter.of(context).push('/profile/form').then((value) {
            if (value == true) viewModel.initValue();
          }),
        ),
        ProfileActionRow(
          icon: Icons.lock_outline,
          title: localize.changePasswordButton,
          onTap: () => GoRouter.of(context).push('/profile/password'),
        ),
        ProfileActionRow(
          icon: Icons.language_outlined,
          title: localize.signInChangeLanguageTitle,
          value: languageLabel,
          onTap: () => _openLanguageSheet(context),
        ),
        ProfileActionRow(
          icon: Icons.qr_code_2_outlined,
          title: localize.getLoginQrcodeButton,
          onTap: () => _openQrDialog(context),
        ),
        ProfileActionRow(
          icon: Icons.palette_outlined,
          title: 'Theme',
          value: _themePresetLabel(appTheme.preset),
          onTap: () => _openThemeSheet(context),
          isLast: true,
        ),
      ],
    );
  }

  String _resolveLanguageNativeName(String code) {
    final match = supportedLanguages.firstWhere(
      (e) => e[1] == code,
      orElse: () => const ['English', 'en'],
    );
    return match[0];
  }

  void _showVillageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _ActiveVillageSheet(
        viewModel: viewModel,
        onPicked: (id) async {
          Navigator.pop(sheetContext);
          await viewModel.selectVillage(id);
        },
      ),
    );
  }

  void _openLanguageSheet(BuildContext context) {
    LanguagePickerSheet.show(
      context,
      currentLanguage: viewModel.language,
      onPicked: (code) async {
        Navigator.of(context).pop();
        if (code == viewModel.language) return;
        await _confirmRestart(context, code);
      },
    );
  }

  Future<void> _confirmRestart(BuildContext context, String code) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          AppLocalizations.of(context)?.restartApp ??
              'The app needs to restart to apply the new language.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: incidentsInk,
            height: 1.45,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              await viewModel.changeLanguage(code);
              if (dialogContext.mounted) {
                RestartWidget.restartApp(dialogContext);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: _profileTeal,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              AppLocalizations.of(context)?.ok ?? 'OK',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQrDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'qr',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _QrLoginDialog(viewModel: viewModel),
    );
  }

  void _openThemeSheet(BuildContext context) {
    final appTheme = locator<AppTheme>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _ThemePresetSheet(
        currentPreset: appTheme.preset,
        onPicked: (preset) async {
          Navigator.pop(sheetContext);
          await appTheme.setPreset(preset);
        },
      ),
    );
  }
}

class _ThemePresetSheet extends StatelessWidget {
  final OhtkThemePreset currentPreset;
  final ValueChanged<OhtkThemePreset> onPicked;

  const _ThemePresetSheet({
    required this.currentPreset,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: media.viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.78),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: incidentsHair,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Theme',
                    style: TextStyle(
                      color: incidentsInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: incidentsHair),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: OhtkThemePreset.values.length,
                  itemBuilder: (context, index) {
                    final preset = OhtkThemePreset.values[index];
                    return _ThemePresetRow(
                      preset: preset,
                      selected: currentPreset == preset,
                      isLast: index == OhtkThemePreset.values.length - 1,
                      onTap: () => onPicked(preset),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePresetRow extends StatelessWidget {
  final OhtkThemePreset preset;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  const _ThemePresetRow({
    required this.preset,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette;
    return Material(
      color: selected ? palette.teal700.withValues(alpha: 0.06) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: incidentsHair, width: 1),
                  ),
          ),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              _ThemeSwatches(palette: palette),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _themePresetLabel(preset),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                ),
              ),
              _RadioRing(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatches extends StatelessWidget {
  final OhtkBrandPalette palette;

  const _ThemeSwatches({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 24,
      child: Stack(
        children: [
          _SwatchDot(color: palette.teal900, left: 0),
          _SwatchDot(color: palette.teal700, left: 12),
          _SwatchDot(color: palette.teal100, left: 24),
        ],
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  final Color color;
  final double left;

  const _SwatchDot({required this.color, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveVillageSheet extends StatelessWidget {
  final ProfileViewModel viewModel;
  final ValueChanged<int> onPicked;
  const _ActiveVillageSheet({
    required this.viewModel,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: incidentsHair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localize.villageSheetTitle,
                  style: const TextStyle(
                    color: incidentsInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localize.villageSheetBody,
                  style: const TextStyle(
                    color: incidentsMuted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: incidentsHair),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: viewModel.assignedVillages.length,
                itemBuilder: (context, index) {
                  final village = viewModel.assignedVillages[index];
                  final selected = viewModel.selectedVillageId == village.id;
                  return _VillageRow(
                    name: village.displayName,
                    selected: selected,
                    isLast: index == viewModel.assignedVillages.length - 1,
                    onTap: () => onPicked(village.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VillageRow extends StatelessWidget {
  final String name;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;
  const _VillageRow({
    required this.name,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _profileTeal.withValues(alpha: 0.06) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: incidentsHair, width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Icon(
                Icons.location_city_outlined,
                size: 20,
                color: _profileTeal,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                ),
              ),
              _RadioRing(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioRing extends StatelessWidget {
  final bool selected;
  const _RadioRing({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _profileTeal : Colors.transparent,
        border: Border.all(
          color: selected ? _profileTeal : incidentsHair,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _QrLoginDialog extends StatefulWidget {
  final ProfileViewModel viewModel;
  const _QrLoginDialog({required this.viewModel});

  @override
  State<_QrLoginDialog> createState() => _QrLoginDialogState();
}

class _QrLoginDialogState extends State<_QrLoginDialog> {
  final GlobalKey _captureKey = GlobalKey();
  bool _saving = false;

  Future<void> _saveToGallery(AppLocalizations localize) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('capture boundary missing');
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('encode failed');
      await Gal.putImageBytes(
        byteData.buffer.asUint8List(),
        album: 'OHTK',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _profileTeal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            localize.qrSaveSuccess,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('QR save failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: incidentsErrorRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text(
            localize.qrSaveFailed,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: widget.viewModel.downloadLoginQrCode(),
      builder: (context, snapshot) {
        final qrReady = snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            (snapshot.data ?? '').isNotEmpty;
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localize.qrDialogEyebrow.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: _profileTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localize.qrDialogTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: incidentsInk,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localize.qrDialogBody,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: incidentsMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: incidentsHair),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QrPanel(
                      snapshot: snapshot,
                      viewModel: widget.viewModel,
                      captureKey: _captureKey,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                      decoration: BoxDecoration(
                        color: _profileTeal.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 13,
                            color: _profileTealMid,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localize.qrKeepPrivate,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _profileTealMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: (qrReady && !_saving)
                        ? () => _saveToGallery(localize)
                        : null,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download_outlined, size: 16),
                    label: Text(
                      localize.qrSaveToGallery.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: _profileTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _profileTeal.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QrPanel extends StatelessWidget {
  final AsyncSnapshot<String> snapshot;
  final ProfileViewModel viewModel;
  final GlobalKey captureKey;
  const _QrPanel({
    required this.snapshot,
    required this.viewModel,
    required this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    const size = 220.0;
    if (snapshot.connectionState != ConnectionState.done ||
        !snapshot.hasData ||
        (snapshot.data ?? '').isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _profileTeal.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: CustomPaint(
          painter: _DashedRectPainter(
            color: _profileTeal.withValues(alpha: 0.3),
            radius: 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: _profileTeal,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localize.qrLoading.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: _profileTeal,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final caption = [
      if ((viewModel.username ?? '').isNotEmpty) '@${viewModel.username}',
      if ((viewModel.authorityName ?? '').isNotEmpty) viewModel.authorityName!,
    ].join('  ·  ');
    return RepaintBoundary(
      key: captureKey,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: incidentsHair, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size - 28,
              height: size - 28,
              child: QrImageView(
                data: snapshot.data!,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: incidentsMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) =>
      old.color != color || old.radius != radius;
}

class _ContactInfoCard extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _ContactInfoCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final email = (viewModel.email ?? '').trim();
    final phone = (viewModel.telephone ?? '').trim();
    final address = (viewModel.address ?? '').trim();
    final allEmpty = email.isEmpty && phone.isEmpty && address.isEmpty;
    final notProvided = localize.profileValueNotProvided;

    return Column(
      children: [
        if (allEmpty)
          ProfileDashedPrompt(
            title: localize.profileCompleteContactTitle,
            body: localize.profileCompleteContactBody,
          ),
        ProfileSectionCard(
          eyebrow: localize.profileSectionContactInfo,
          children: [
            ProfileDataRow(
              label: localize.emailLabel,
              value: email.isEmpty ? null : email,
              emptyValueText: notProvided,
            ),
            ProfileDataRow(
              label: localize.telephoneLabel,
              value: phone.isEmpty ? null : phone,
              emptyValueText: notProvided,
            ),
            ProfileDataRow(
              label: localize.addressLabel,
              value: address.isEmpty ? null : address,
              emptyValueText: notProvided,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}

// TODO: role-gate behind `user.role in (admin, author)` once the User model
// exposes that field. Today it renders for everyone, matching legacy QR
// scanner visibility on the report-type chooser.
class _AdminToolsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ProfileSectionCard(
      eyebrow: localize.adminToolsSectionLabel,
      children: [
        ProfileActionRow(
          icon: Icons.shield_outlined,
          title: localize.testDraftFormLabel,
          onTap: () => _scanDraftForm(context),
          isLast: true,
        ),
      ],
    );
  }

  Future<void> _scanDraftForm(BuildContext context) async {
    final localize = AppLocalizations.of(context);
    final result = await Navigator.push<ReportType>(
      context,
      MaterialPageRoute(builder: (_) => const QrReportTypeView()),
    );
    if (!context.mounted) return;
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FormSimulatorView(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localize?.invalidReportTypeQrcode ?? 'Invalid QR'),
          backgroundColor: incidentsErrorRed,
        ),
      );
    }
  }
}
