import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/form_chrome.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/profile/profile_widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'profile_view_model.dart';

Color get _profileTeal => OhtkTheme.palette.teal700;

class ProfileFormView extends StatelessWidget {
  static const String route = '/profile/form';

  const ProfileFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: incidentsSand,
          resizeToAvoidBottomInset: true,
          appBar: FormChromeAppBar(
            title: AppLocalizations.of(context)?.updateProfileButton ??
                'Edit profile',
            onBack: () => Navigator.of(context).pop(false),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: _ProfileForm(viewModel: viewModel),
                ),
                _StickyFooter(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileForm extends StackedHookView<ProfileViewModel> {
  // ignore: prefer_const_constructors_in_immutables
  _ProfileForm({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget builder(BuildContext context, ProfileViewModel vm) {
    final localize = AppLocalizations.of(context);

    final firstName = useTextEditingController(text: vm.firstName ?? '');
    final lastName = useTextEditingController(text: vm.lastName ?? '');
    final telephone = useTextEditingController(text: vm.telephone ?? '');
    final address = useTextEditingController(text: vm.address ?? '');

    final firstNameNode = useFocusNode();
    final lastNameNode = useFocusNode();
    final telephoneNode = useFocusNode();
    final addressNode = useFocusNode();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          _Recap(viewModel: vm),
          const SizedBox(height: 16),
          if (vm.hasErrorForKey('general'))
            _GeneralErrorBanner(message: vm.error('general')),
          ProfileTextField(
            controller: firstName,
            focusNode: firstNameNode,
            label: localize?.firstNameLabel ?? 'First name',
            isRequired: true,
            textInputAction: TextInputAction.next,
            onChanged: vm.setFirstName,
            onSubmitted: (_) => lastNameNode.requestFocus(),
            errorText: vm.error('firstName'),
          ),
          const SizedBox(height: 12),
          ProfileTextField(
            controller: lastName,
            focusNode: lastNameNode,
            label: localize?.lastNameLabel ?? 'Last name',
            isRequired: true,
            textInputAction: TextInputAction.next,
            onChanged: vm.setLastName,
            onSubmitted: (_) => telephoneNode.requestFocus(),
            errorText: vm.error('lastName'),
          ),
          const SizedBox(height: 12),
          ProfileTextField(
            controller: telephone,
            focusNode: telephoneNode,
            label: localize?.telephoneLabel ?? 'Telephone',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            helper: localize?.profilePhoneOptionalHelper ??
                'Used to reach you about your reports',
            optionalLabel: localize?.registerOptional ?? 'Optional',
            onChanged: vm.setTelephone,
            onSubmitted: (_) => addressNode.requestFocus(),
            errorText: vm.error('telephone'),
          ),
          const SizedBox(height: 12),
          ProfileTextField(
            controller: address,
            focusNode: addressNode,
            label: localize?.addressLabel ?? 'Address',
            optionalLabel: localize?.registerOptional ?? 'Optional',
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            onChanged: vm.setAddress,
            errorText: vm.error('address'),
          ),
        ],
      ),
    );
  }
}

class _Recap extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _Recap({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final username = (viewModel.username ?? '').trim();
    final email = (viewModel.email ?? '').trim();
    final fullName = _displayName(viewModel);
    final caption = [
      if (username.isNotEmpty) '@$username',
      if (email.isNotEmpty) email,
    ].join('  ·  ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsHair, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RecapAvatar(url: viewModel.avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                    height: 1.25,
                  ),
                ),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: incidentsMuted,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  (AppLocalizations.of(context)?.profileFormReadonlyEyebrow ??
                          'Set by your admin · not editable')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: incidentsMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(ProfileViewModel vm) {
    final parts = [
      (vm.firstName ?? '').trim(),
      (vm.lastName ?? '').trim(),
    ].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return vm.username ?? '—';
    return parts.join(' ');
  }
}

class _RecapAvatar extends StatelessWidget {
  final String? url;
  const _RecapAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _profileTeal.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipOval(
        child: url == null
            ? Icon(Icons.person_outline, size: 22, color: _profileTeal)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_outline,
                  size: 22,
                  color: _profileTeal,
                ),
              ),
      ),
    );
  }
}

class _GeneralErrorBanner extends StatelessWidget {
  final String message;
  const _GeneralErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAE5),
        border: Border.all(color: const Color(0xFFE8B6AB), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: incidentsErrorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: incidentsErrorRed,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StackedHookView<ProfileViewModel> {
  // ignore: prefer_const_constructors_in_immutables
  _StickyFooter({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget builder(BuildContext context, ProfileViewModel vm) {
    final media = MediaQuery.of(context);
    final localize = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: incidentsHair, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -6),
            blurRadius: 18,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + media.padding.bottom),
      child: Row(
        children: [
          OutlinedButton(
            onPressed:
                vm.isBusy ? null : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: incidentsInk,
              side: const BorderSide(color: incidentsHair, width: 1),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            child: TextButton(
              onPressed: vm.isBusy ? null : () => _save(context, vm),
              style: TextButton.styleFrom(
                backgroundColor: _profileTeal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _profileTeal.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: vm.isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      localize?.confirmUpdate ?? 'Save',
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, ProfileViewModel vm) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await vm.updateProfile();
    if (!context.mounted) return;
    if (result is ProfileSuccess && result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _profileTeal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context)?.profileUpdateSuccess ??
                'Profile saved',
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      GoRouter.of(context).pop(true);
    }
  }
}
