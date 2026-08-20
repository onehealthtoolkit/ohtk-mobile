import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/register/register_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

// Brand / surface colors follow the active OhtkTheme preset (LAHIS, lagoon, …).
Color get _tealHero => OhtkTheme.palette.teal700;
Color get _tealDeep => OhtkTheme.palette.teal900;
Color get _sand => OhtkColor.cream;
Color get _sand2 => OhtkColor.creamHi;
Color get _ink => OhtkColor.ink900;
Color get _muted => OhtkColor.ink500;
Color get _hair => OhtkColor.line;
Color get _placeholder => OhtkColor.ink300;
Color get _errBg => OhtkColor.dangerBg;
Color get _errBorder => OhtkColor.danger.withValues(alpha: 0.35);
Color get _errFg => OhtkColor.danger;
Color get _errInputBg => OhtkColor.dangerBg;
Color get _errInputFg => OhtkColor.danger;
Color get _errStroke => OhtkColor.danger;
Color get _autoBg => OhtkColor.warningBg;
Color get _autoBorder => OhtkColor.warning.withValues(alpha: 0.45);
Color get _autoFg => OhtkColor.warning;
const _fontFamily = OhtkType.family;
const _fontFamilyFallback = OhtkType.fallback;

const _codeLength = 7;

class RegisterView extends StackedView<RegisterViewModel> {
  static const String route = '/register';

  const RegisterView({Key? key}) : super(key: key);

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) =>
      RegisterViewModel();

  @override
  Widget builder(
      BuildContext context, RegisterViewModel viewModel, Widget? child) {
    final isDetail = viewModel.state == RegisterState.detail;
    return ConfirmPopScope(
      onWillPop: () => _willPop(context, isDetail),
      child: Scaffold(
        backgroundColor: isDetail ? _sand : Colors.white,
        appBar: _RegisterAppBar(),
        body: Column(
          children: [
            _StepIndicator(step: isDetail ? 2 : 1),
            Expanded(
              child: isDetail ? const _DetailStep() : const _CodeStep(),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _willPop(BuildContext context, bool isDetail) {
    if (!isDetail) return Future.value(true);
    return confirm(context,
        content: Text(
          AppLocalizations.of(context)!.confirmExit,
          textAlign: TextAlign.center,
        ));
  }
}

class _RegisterAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: _tealDeep,
      foregroundColor: Colors.white,
      surfaceTintColor: _tealDeep,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        l10n.registerTitle,
        style: const TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFamilyFallback,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = step == 1 ? l10n.registerStep1Eyebrow : l10n.registerStep2Eyebrow;
    final progress = step == 1 ? 0.5 : 1.0;
    final isStep2 = step == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isStep2
            ? Border(bottom: BorderSide(color: _hair, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _tealHero,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: _hair,
                valueColor: AlwaysStoppedAnimation(_tealHero),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Step 1 — invitation code
// ============================================================

class _CodeStep extends StackedHookView<RegisterViewModel> {
  const _CodeStep();

  @override
  Widget builder(BuildContext context, RegisterViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final code = useState<String>('');
    final hasError = viewModel.hasErrorForKey('invitationCode');

    void setCode(String next) {
      code.value = next;
      viewModel.setInvitationCode(next);
      if (next.length == _codeLength && !viewModel.isBusy) {
        HapticFeedback.selectionClick();
        viewModel.checkInvitationCode();
      }
    }

    void onDigit(String d) {
      if (viewModel.isBusy) return;
      if (code.value.length >= _codeLength) return;
      if (hasError) {
        viewModel.setErrorForObject('invitationCode', null);
        setCode(d);
      } else {
        setCode(code.value + d);
      }
    }

    void onBackspace() {
      if (viewModel.isBusy) return;
      if (hasError) {
        viewModel.setErrorForObject('invitationCode', null);
        setCode('');
        return;
      }
      if (code.value.isEmpty) return;
      setCode(code.value.substring(0, code.value.length - 1));
    }

    final isComplete = code.value.length == _codeLength;
    final showVerifying = viewModel.isBusy;
    final focusIndex = code.value.length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.registerCodeTitle,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.registerCodeSubtitle,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 13,
                    color: _muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                _DigitBoxes(
                  value: code.value,
                  focusIndex: focusIndex,
                  error: hasError,
                ),
                if (hasError) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(
                    message: viewModel.error('invitationCode').isNotEmpty
                        ? viewModel.error('invitationCode')
                        : l10n.registerCodeError,
                  ),
                ],
                if (showVerifying) ...[
                  const SizedBox(height: 14),
                  _VerifyingRow(label: l10n.registerCodeChecking),
                ],
                const SizedBox(height: 24),
                _PrimaryButton(
                  label: showVerifying
                      ? l10n.registerCodeContinueChecking
                      : l10n.registerCodeContinue,
                  enabled: isComplete && !showVerifying,
                  onPressed: isComplete && !showVerifying
                      ? viewModel.checkInvitationCode
                      : null,
                ),
                const SizedBox(height: 14),
                _HelpLink(
                  prefix: l10n.registerCodeHelp,
                  link: l10n.registerCodeHelpLink,
                ),
              ],
            ),
          ),
        ),
        if (!showVerifying) _NumPad(onDigit: onDigit, onBackspace: onBackspace),
      ],
    );
  }
}

class _DigitBoxes extends StatelessWidget {
  final String value;
  final int focusIndex;
  final bool error;

  const _DigitBoxes({
    required this.value,
    required this.focusIndex,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < _codeLength; i++) {
      final d = i < value.length ? value[i] : '';
      final filled = d.isNotEmpty;
      final focused = i == focusIndex && !error;
      final borderColor = error
          ? _errStroke
          : focused
              ? _tealHero
              : filled
                  ? _ink
                  : _hair;
      children.add(_DigitBox(
        digit: d,
        focused: focused,
        error: error,
        borderColor: borderColor,
      ));
      if (i == 2) {
        children.add(const SizedBox(width: 6));
        children.add(Container(
          width: 8,
          height: 2,
          decoration: BoxDecoration(
            color: _hair,
            borderRadius: BorderRadius.circular(1),
          ),
        ));
        children.add(const SizedBox(width: 6));
      } else if (i < _codeLength - 1) {
        children.add(const SizedBox(width: 6));
      }
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}

class _DigitBox extends StatelessWidget {
  final String digit;
  final bool focused;
  final bool error;
  final Color borderColor;

  const _DigitBox({
    required this.digit,
    required this.focused,
    required this.error,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        color: error ? _errInputBg : Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: _tealHero.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: digit.isNotEmpty
          ? Text(
              digit,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontFamilyFallback: _fontFamilyFallback,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: error ? _errInputFg : _ink,
              ),
            )
          : focused
              ? Container(width: 1.5, height: 22, color: _tealHero)
              : null,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _errBg,
        border: Border.all(color: _errBorder, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline,
                size: 16, color: Color(0xFFB83333)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontFamilyFallback: _fontFamilyFallback,
                fontSize: 12,
                color: _errFg,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyingRow extends StatelessWidget {
  final String label;
  const _VerifyingRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_tealHero),
            backgroundColor: _hair,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            fontSize: 13,
            color: _muted,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? _hair : _tealHero),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? _placeholder : Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 15),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HelpLink extends StatelessWidget {
  final String prefix;
  final String link;
  const _HelpLink({required this.prefix, required this.link});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            fontSize: 12,
            color: _muted,
            height: 1.5,
          ),
          children: [
            TextSpan(text: '$prefix '),
            TextSpan(
              text: link,
              style: TextStyle(
                color: _tealHero,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Container(
      decoration: BoxDecoration(
        color: _sand2,
        border: Border(top: BorderSide(color: _hair, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        6,
        8,
        6,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 2.4,
        children: keys.map((k) {
          if (k.isEmpty) {
            return const SizedBox.shrink();
          }
          return _NumPadKey(
            label: k,
            isBackspace: k == '⌫',
            onTap: () {
              if (k == '⌫') {
                onBackspace();
              } else {
                onDigit(k);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _NumPadKey extends StatelessWidget {
  final String label;
  final bool isBackspace;
  final VoidCallback onTap;

  const _NumPadKey({
    required this.label,
    required this.isBackspace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _hair, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: isBackspace
              ? Icon(Icons.backspace_outlined, size: 20, color: _ink)
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================================
// Step 2 — registration form
// ============================================================

class _DetailStep extends StackedHookView<RegisterViewModel> {
  const _DetailStep();

  @override
  Widget builder(BuildContext context, RegisterViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final username = useTextEditingController(text: viewModel.username);
    final firstName = useTextEditingController(text: viewModel.firstName);
    final lastName = useTextEditingController(text: viewModel.lastName);
    final phone = useTextEditingController(text: viewModel.phone);
    final email = useTextEditingController(text: viewModel.email);
    final address = useTextEditingController(text: viewModel.address);
    final age = useTextEditingController(
      text: viewModel.age != null ? '${viewModel.age}' : '',
    );

    // Explicit focus chain: keyboard "next" must not rely on FocusScope.nextFocus()
    // (default onEditingComplete already moves once; a second nextFocus skips a field).
    // Also skip non-text widgets (gender dropdown, consent, sticky CTA).
    final usernameNode = useFocusNode();
    final firstNameNode = useFocusNode();
    final lastNameNode = useFocusNode();
    final phoneNode = useFocusNode();
    final emailNode = useFocusNode();
    final addressNode = useFocusNode();
    final ageNode = useFocusNode();
    final consentCheckboxNode = useFocusNode();

    Future<void> onSubmit() async {
      FocusManager.instance.primaryFocus?.unfocus();
      final result = await viewModel.register();
      if (result is RegisterSuccess && context.mounted) {
        // Do not Navigator.pop → login (flashes login under register).
        // Defer go() one frame so auth Listenable / GoRouter redirect settle
        // before we replace the stack — avoids fighting concurrent navigations.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go('/reports');
        });
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 14, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ContextCard(
                  authority: viewModel.authorityName ?? '',
                  village: viewModel.hasVillages ? viewModel.villageNames : '',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RegisterField(
                        label: l10n.usernameLabel,
                        controller: username,
                        focusNode: usernameNode,
                        onChanged: viewModel.setUsername,
                        textInputAction: TextInputAction.next,
                        onMoveFocus: () => firstNameNode.requestFocus(),
                        hint: l10n.registerUsernameHint,
                        errorText: _errorOrNull(viewModel, 'username'),
                        suffixIcon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.firstNameLabel,
                        controller: firstName,
                        focusNode: firstNameNode,
                        onChanged: viewModel.setFirstName,
                        placeholder: l10n.registerFirstNamePlaceholder,
                        textInputAction: TextInputAction.next,
                        onMoveFocus: () => lastNameNode.requestFocus(),
                        errorText: _errorOrNull(viewModel, 'firstName'),
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.lastNameLabel,
                        controller: lastName,
                        focusNode: lastNameNode,
                        onChanged: viewModel.setLastName,
                        placeholder: l10n.registerLastNamePlaceholder,
                        textInputAction: TextInputAction.next,
                        onMoveFocus: () => phoneNode.requestFocus(),
                        errorText: _errorOrNull(viewModel, 'lastName'),
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.telephoneLabel,
                        controller: phone,
                        focusNode: phoneNode,
                        onChanged: viewModel.setPhone,
                        placeholder: l10n.registerPhonePlaceholder,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onMoveFocus: () => emailNode.requestFocus(),
                        errorText: _errorOrNull(viewModel, 'phone'),
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.emailLabel,
                        controller: email,
                        focusNode: emailNode,
                        onChanged: viewModel.setEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onMoveFocus: () => addressNode.requestFocus(),
                        // Auto badge/hint only when backend pre-filled
                        // (features.auto_generate_email = enable).
                        autoBadge: viewModel.emailAutoGenerated
                            ? l10n.registerAuto
                            : null,
                        hint: viewModel.emailAutoGenerated
                            ? l10n.registerEmailHint
                            : null,
                        placeholder: viewModel.emailAutoGenerated
                            ? null
                            : l10n.emailHint,
                        optional: l10n.registerOptional,
                        errorText: _errorOrNull(viewModel, 'email'),
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.addressLabel,
                        controller: address,
                        focusNode: addressNode,
                        onChanged: viewModel.setAddress,
                        placeholder: l10n.registerAddressPlaceholder,
                        textInputAction: TextInputAction.next,
                        // Skip gender dropdown (not a text input).
                        onMoveFocus: () => ageNode.requestFocus(),
                        optional: l10n.registerOptional,
                        errorText: _errorOrNull(viewModel, 'address'),
                      ),
                      const SizedBox(height: 14),
                      _GenderField(
                        value: viewModel.gender,
                        onChanged: viewModel.setGender,
                        optionalLabel: viewModel.genderRequired
                            ? null
                            : l10n.registerOptional,
                        errorText: _errorOrNull(viewModel, 'gender'),
                      ),
                      const SizedBox(height: 14),
                      _RegisterField(
                        label: l10n.ageLabel,
                        controller: age,
                        focusNode: ageNode,
                        onChanged: viewModel.setAge,
                        placeholder: l10n.registerAgePlaceholder,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onMoveFocus: () => ageNode.unfocus(),
                        optional: viewModel.ageRequired
                            ? null
                            : l10n.registerOptional,
                        errorText: _errorOrNull(viewModel, 'age'),
                      ),
                      if (viewModel.showConsent) ...[
                        const SizedBox(height: 14),
                        _ConsentSection(
                          accepted: viewModel.consentAccepted,
                          termsRead: viewModel.consentTermsRead,
                          checkboxFocusNode: consentCheckboxNode,
                          onAcceptedChanged: viewModel.setConsentAccepted,
                          onTermsRead: viewModel.markConsentTermsRead,
                          checkboxLabel: viewModel.consentCheckboxLabel,
                          sectionTitle: l10n.registerConsentSectionTitle,
                          sectionSubtitle: l10n.registerConsentSectionSubtitle,
                          readButtonLabel: l10n.registerConsentReadButton,
                          viewAgainLabel: l10n.registerConsentViewAgain,
                          reviewedLabel: l10n.registerConsentReviewed,
                          confirmReadLabel: l10n.registerConsentConfirmRead,
                          readFirstHint: l10n.registerConsentReadFirst,
                          sheetAcceptNote: viewModel.consentAcceptText,
                          consentContent: viewModel.consentContent,
                          errorText: _errorOrNull(viewModel, 'consent'),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _NoPasswordCard(message: l10n.registerNoPasswordInfo),
                      if (viewModel.hasErrorForKey('submit')) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: viewModel.error('submit')),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _StickyCta(
          label: viewModel.isBusy ? l10n.registerCreating : l10n.registerSubmit,
          enabled: viewModel.canSubmitRegistration,
          busy: viewModel.isBusy,
          helperText: viewModel.isSubmitBlockedByConsent
              ? l10n.registerConsentSubmitBlocked
              : null,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  String? _errorOrNull(RegisterViewModel vm, String key) {
    if (!vm.hasErrorForKey(key)) return null;
    final value = vm.error(key);
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}

class _ContextCard extends StatelessWidget {
  final String authority;
  final String village;
  const _ContextCard({required this.authority, required this.village});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Match OhtkCard paper tone used on profile / observation info cards:
    // solid paper surface + hairline, not a washed teal gradient on cream.
    return OhtkCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      tone: OhtkCardTone.paper,
      borderColor: OhtkColor.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Same family as profile village rows / OhtkIconTile soft brand chip.
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OhtkTheme.palette.teal100,
              borderRadius: OhtkRadius.tile,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_city_outlined,
              size: 20,
              color: _tealHero,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: _tealHero),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.registerCodeAccepted.toUpperCase(),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontFamilyFallback: _fontFamilyFallback,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: _tealHero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ContextRow(
                  label: l10n.authorityLabel,
                  value: authority,
                  bold: true,
                ),
                if (village.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _ContextRow(
                    label: l10n.registerVillageLabel,
                    value: village,
                    bold: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _ContextRow({
    required this.label,
    required this.value,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: _muted,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final String? hint;
  final String? optional;
  final String? autoBadge;
  final String? errorText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  /// Called from [onEditingComplete] so Flutter's default nextFocus is not
  /// also applied (which would skip a field when combined with another move).
  final VoidCallback? onMoveFocus;

  const _RegisterField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.textInputAction,
    this.focusNode,
    this.onMoveFocus,
    this.placeholder,
    this.hint,
    this.optional,
    this.autoBadge,
    this.errorText,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            if (optional != null) ...[
              const SizedBox(width: 8),
              _Pill(
                label: optional!,
                bg: _hair,
                fg: _muted,
              ),
            ],
            if (autoBadge != null) ...[
              const SizedBox(width: 8),
              _Pill(
                label: autoBadge!,
                bg: _autoBg,
                fg: _autoFg,
                borderColor: _autoBorder,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: hasError ? _errStroke : _hair,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  // Providing onEditingComplete replaces Flutter's default
                  // nextFocus/unfocus so we move exactly once along our chain.
                  onEditingComplete: onMoveFocus,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 15,
                    color: _ink,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontFamily: _fontFamily,
                      fontFamilyFallback: _fontFamilyFallback,
                      color: _placeholder,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                Icon(suffixIcon, size: 16, color: _tealHero),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              fontSize: 11,
              color: _errStroke,
              height: 1.4,
            ),
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: 5),
          Text(
            hint!,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              fontSize: 11,
              color: _muted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? borderColor;
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFamilyFallback,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? optionalLabel;
  final String? errorText;

  const _GenderField({
    required this.value,
    required this.onChanged,
    this.optionalLabel,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final options = <String, String>{
      RegisterGender.male: l10n.registerGenderMale,
      RegisterGender.female: l10n.registerGenderFemale,
      RegisterGender.other: l10n.registerGenderOther,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                l10n.genderLabel,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            if (optionalLabel != null) ...[
              const SizedBox(width: 8),
              _Pill(
                label: optionalLabel!,
                bg: _hair,
                fg: _muted,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: hasError ? _errStroke : _hair,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                l10n.registerGenderPlaceholder,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  color: _placeholder,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              icon: Icon(Icons.expand_more, color: _muted, size: 22),
              style: TextStyle(
                fontFamily: _fontFamily,
                fontFamilyFallback: _fontFamilyFallback,
                fontSize: 15,
                color: _ink,
                fontWeight: FontWeight.w500,
              ),
              items: options.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              fontSize: 11,
              color: _errStroke,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Consent block: read terms first (primary action), then short checkbox.
class _ConsentSection extends StatelessWidget {
  final bool accepted;
  final bool termsRead;
  final FocusNode checkboxFocusNode;
  final ValueChanged<bool?> onAcceptedChanged;
  final VoidCallback onTermsRead;
  final String checkboxLabel;
  final String sectionTitle;
  final String sectionSubtitle;
  final String readButtonLabel;
  final String viewAgainLabel;
  final String reviewedLabel;
  final String confirmReadLabel;
  final String readFirstHint;
  final String sheetAcceptNote;
  final String consentContent;
  final String? errorText;

  const _ConsentSection({
    required this.accepted,
    required this.termsRead,
    required this.checkboxFocusNode,
    required this.onAcceptedChanged,
    required this.onTermsRead,
    required this.checkboxLabel,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.readButtonLabel,
    required this.viewAgainLabel,
    required this.reviewedLabel,
    required this.confirmReadLabel,
    required this.readFirstHint,
    required this.sheetAcceptNote,
    required this.consentContent,
    this.errorText,
  });

  void _focusConsentCheckbox() {
    // Wait for sheet dismiss + rebuild that enables the checkbox.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!checkboxFocusNode.canRequestFocus) return;
        checkboxFocusNode.requestFocus();
        final focusContext = checkboxFocusNode.context;
        if (focusContext == null) return;
        Scrollable.ensureVisible(
          focusContext,
          duration: const Duration(milliseconds: 200),
          alignment: 0.35,
          curve: Curves.easeOut,
        );
      });
    });
  }

  Future<void> _openTerms(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final height = MediaQuery.of(sheetContext).size.height * 0.8;
        final note = sheetAcceptNote.trim();
        return SafeArea(
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sectionTitle,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontFamilyFallback: _fontFamilyFallback,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: _muted),
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: _hair),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Html(data: consentContent),
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _sand2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _hair),
                            ),
                            child: Text(
                              note,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontFamilyFallback: _fontFamilyFallback,
                                fontSize: 13,
                                color: _muted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: _hair),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _tealHero,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmReadLabel,
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontFamilyFallback: _fontFamilyFallback,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      onTermsRead();
      _focusConsentCheckbox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final canCheck = termsRead;
    final checkboxColor = canCheck ? _ink : _placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: hasError ? _errStroke : _hair,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sectionSubtitle,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  fontSize: 12,
                  color: _muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              if (termsRead) ...[
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: _tealHero),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reviewedLabel,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontFamilyFallback: _fontFamilyFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _tealDeep,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openTerms(context),
                      style: TextButton.styleFrom(
                        foregroundColor: _tealHero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        viewAgainLabel,
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontFamilyFallback: _fontFamilyFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _openTerms(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _tealHero,
                      side: BorderSide(color: _tealHero, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          readButtonLabel,
                          style: const TextStyle(
                            fontFamily: _fontFamily,
                            fontFamilyFallback: _fontFamilyFallback,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  readFirstHint,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 12,
                    color: _muted,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(height: 1, color: _hair),
              CheckboxListTile(
                value: accepted,
                focusNode: checkboxFocusNode,
                // Only focusable after terms are confirmed as read.
                onChanged: canCheck ? onAcceptedChanged : null,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: _tealHero,
                autofocus: false,
                title: Text(
                  checkboxLabel,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: checkboxColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              fontSize: 11,
              color: _errStroke,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _NoPasswordCard extends StatelessWidget {
  final String message;
  const _NoPasswordCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _hair, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline, size: 16, color: _tealHero),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontFamilyFallback: _fontFamilyFallback,
                fontSize: 12,
                color: _muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool busy;
  final String? helperText;
  final VoidCallback onPressed;

  const _StickyCta({
    required this.label,
    required this.enabled,
    required this.busy,
    required this.onPressed,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final showHelper =
        !enabled && !busy && helperText != null && helperText!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _hair, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHelper) ...[
            Text(
              helperText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontFamilyFallback: _fontFamilyFallback,
                fontSize: 12,
                color: _muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(0),
                // Disabled must look inert (gray), not faded teal.
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return _hair;
                  }
                  return _tealHero;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return _placeholder;
                  }
                  return Colors.white;
                }),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 15),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontFamilyFallback: _fontFamilyFallback,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: enabled ? Colors.white : _placeholder,
                          ),
                        ),
                        if (enabled) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
