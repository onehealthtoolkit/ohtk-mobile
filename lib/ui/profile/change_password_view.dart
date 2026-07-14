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

import 'change_password_view_model.dart';

Color get _profileTeal => OhtkTheme.palette.teal700;

class ChangePasswordView extends StatelessWidget {
  static const String route = '/profile/password';

  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: incidentsSand,
        resizeToAvoidBottomInset: true,
        appBar: FormChromeAppBar(
          // existing key: changePasswordTitle
          title: AppLocalizations.of(context)?.changePasswordTitle ??
              'Change password',
          onBack: () => Navigator.of(context).pop(false),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: _PasswordForm(viewModel: viewModel),
              ),
              _StickyFooter(viewModel: viewModel),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordForm extends StackedHookView<ChangePasswordViewModel> {
  // ignore: prefer_const_constructors_in_immutables
  _PasswordForm({required this.viewModel});

  final ChangePasswordViewModel viewModel;

  @override
  Widget builder(BuildContext context, ChangePasswordViewModel vm) {
    final localize = AppLocalizations.of(context);
    final newPwd = useTextEditingController();
    final confirmPwd = useTextEditingController();
    final newPwdNode = useFocusNode();
    final confirmPwdNode = useFocusNode();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
        children: [
          const _PasswordHeader(),
          const SizedBox(height: 16),
          if (vm.hasErrorForKey('generalChangePassword'))
            _GeneralErrorBanner(
              message: vm.error('generalChangePassword'),
            ),
          ProfileTextField(
            controller: newPwd,
            focusNode: newPwdNode,
            label: localize?.newPasswordLabel ?? 'New password',
            isRequired: true,
            obscureText: vm.obscurePassword,
            textInputAction: TextInputAction.next,
            onChanged: vm.setPassword,
            onSubmitted: (_) => confirmPwdNode.requestFocus(),
            errorText: vm.error('password'),
            helper: localize?.passwordHelperTip,
            suffix: _EyeToggle(
              obscured: vm.obscurePassword,
              onTap: () => vm.setObscurePassword(!vm.obscurePassword),
            ),
          ),
          const SizedBox(height: 14),
          ProfileTextField(
            controller: confirmPwd,
            focusNode: confirmPwdNode,
            label: localize?.confirmPasswordLabel ?? 'Confirm new password',
            isRequired: true,
            obscureText: vm.obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onChanged: vm.setConfirmPassword,
            onSubmitted: (_) => confirmPwdNode.unfocus(),
            errorText: vm.error('confirmPassword'),
            suffix: _EyeToggle(
              obscured: vm.obscureConfirmPassword,
              onTap: () =>
                  vm.setObscureConfirmPassword(!vm.obscureConfirmPassword),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordHeader extends StatelessWidget {
  const _PasswordHeader();

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _profileTeal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.lock_outline, size: 22, color: _profileTeal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localize.changePasswordTitle,
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: incidentsInk,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                localize.passwordIntroBody,
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: incidentsMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EyeToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;
  const _EyeToggle({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(
          obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: incidentsMuted,
        ),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashRadius: 18,
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAE5),
        border: Border.all(color: const Color(0xFFE8B6AB), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child:
                Icon(Icons.error_outline, size: 18, color: incidentsErrorRed),
          ),
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

class _StickyFooter extends StackedHookView<ChangePasswordViewModel> {
  // ignore: prefer_const_constructors_in_immutables
  _StickyFooter({required this.viewModel});

  final ChangePasswordViewModel viewModel;

  @override
  Widget builder(BuildContext context, ChangePasswordViewModel vm) {
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

  Future<void> _save(BuildContext context, ChangePasswordViewModel vm) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await vm.changePassword();
    if (!context.mounted) return;
    if (result is ProfileSuccess && result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _profileTeal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context)?.passwordUpdatedSuccess ??
                'Password changed',
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
