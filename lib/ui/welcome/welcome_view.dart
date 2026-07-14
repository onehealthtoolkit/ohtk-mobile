import 'package:flutter/material.dart';
import 'package:podd_app/components/language_dropdown.dart';
import 'package:podd_app/keys/application_keys.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/welcome/welcome_view_model.dart';
import 'package:stacked/stacked.dart';

Color get _tealDeep => OhtkTheme.palette.teal900;
Color get _tealAccent => OhtkTheme.palette.teal100;
const _onDark = Colors.white;
const _onDarkMuted = Color(0xB3FFFFFF); // 70% white
const _cardBg = Color(0x0AFFFFFF); // 4% white
const _cardBgSel = Color(0x1FFFFFFF); // 12% white
const _cardBorder = Color(0x1FFFFFFF); // 12% white
const _radioBorderIdle = Color(0x4DFFFFFF); // 30% white
const _footerBg = Color(0x26000000); // 15% black
const _footerBorder = Color(0x1AFFFFFF); // 10% white
const _disabledBg = Color(0x26FFFFFF); // 15% white
const _disabledFg = Color(0x66FFFFFF); // 40% white
const _fontFamily = OhtkType.family;
const _fontFamilyFallback = OhtkType.fallback;

class WelcomeView extends StackedView<WelcomeViewModel> {
  final VoidCallback? onContinue;

  const WelcomeView({Key? key, this.onContinue}) : super(key: key);

  @override
  WelcomeViewModel viewModelBuilder(BuildContext context) => WelcomeViewModel();

  @override
  Widget builder(
      BuildContext context, WelcomeViewModel viewModel, Widget? child) {
    return Localizations.override(
      context: context,
      locale: viewModel.selectedLanguage != null
          ? Locale(viewModel.selectedLanguage!, '')
          : null,
      child: Builder(
        builder: (innerContext) {
          final l10n = AppLocalizations.of(innerContext)!;
          return Scaffold(
            key: K.welcomeKeys.view,
            backgroundColor: _tealDeep,
            body: SafeArea(
              child: Column(
                children: [
                  _BrandStrip(),
                  _TitleBlock(l10n: l10n),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Section(
                            number: '1',
                            title: l10n.welcomeLanguageTitle,
                            child: _LanguageGrid(viewModel: viewModel),
                          ),
                          const SizedBox(height: 18),
                          _Section(
                            number: '2',
                            title: l10n.welcomeServerTitle,
                            child:
                                _ServerList(viewModel: viewModel, l10n: l10n),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _ContinueFooter(
                    viewModel: viewModel,
                    l10n: l10n,
                    onContinue: onContinue,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 44,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final AppLocalizations l10n;

  const _TitleBlock({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        children: [
          Text(
            l10n.welcomeTitle,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              color: _onDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontFamilyFallback: _fontFamilyFallback,
              color: _onDarkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final Widget child;

  const _Section({
    required this.number,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tealAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    color: _tealDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  color: _onDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _LanguageGrid extends StatelessWidget {
  final WelcomeViewModel viewModel;
  const _LanguageGrid({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 158 / 44,
      children: supportedLanguages.map((option) {
        final label = option[0];
        final code = option[1];
        final selected = viewModel.selectedLanguage == code;
        return _SelectableCard(
          selected: selected,
          onTap: () => viewModel.selectLanguage(code),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _Radio(selected: selected, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    color: _onDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ServerList extends StatelessWidget {
  final WelcomeViewModel viewModel;
  final AppLocalizations l10n;
  const _ServerList({required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (viewModel.busy('tenants') && viewModel.servers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: _tealAccent,
              strokeWidth: 2.4,
            ),
          ),
        ),
      );
    }

    if (viewModel.servers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          viewModel.loadFailed
              ? l10n.welcomeCannotLoadServers
              : l10n.welcomeNoServersText,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontFamilyFallback: _fontFamilyFallback,
            color: _onDarkMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < viewModel.servers.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ServerCard(
            label: viewModel.servers[i]['label'] ?? '',
            domain: viewModel.servers[i]['domain'] ?? '',
            selected:
                viewModel.selectedServerId == viewModel.servers[i]['domain'],
            onTap: () =>
                viewModel.selectServer(viewModel.servers[i]['domain'] ?? ''),
          ),
        ],
      ],
    );
  }
}

class _ServerCard extends StatelessWidget {
  final String label;
  final String domain;
  final bool selected;
  final VoidCallback onTap;

  const _ServerCard({
    required this.label,
    required this.domain,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectableCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _Radio(selected: selected, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    color: _onDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (domain.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontFamilyFallback: _fontFamilyFallback,
                      color: _onDarkMuted,
                      fontSize: 12,
                    ),
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

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Widget child;

  const _SelectableCard({
    required this.selected,
    required this.onTap,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? _cardBgSel : _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _tealAccent : _cardBorder,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  final double size;
  const _Radio({required this.selected, required this.size});

  @override
  Widget build(BuildContext context) {
    final ringWidth = selected ? (size <= 18 ? 5.0 : 6.0) : 1.5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: selected ? _tealAccent : _radioBorderIdle,
          width: ringWidth,
        ),
      ),
    );
  }
}

class _ContinueFooter extends StatelessWidget {
  final WelcomeViewModel viewModel;
  final AppLocalizations l10n;
  final VoidCallback? onContinue;

  const _ContinueFooter({
    required this.viewModel,
    required this.l10n,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final ready = viewModel.continueEnabled && !viewModel.isBusy;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: _footerBg,
        border: Border(top: BorderSide(color: _footerBorder, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          key: K.welcomeKeys.continueButton,
          onPressed: ready
              ? () async {
                  await viewModel.submit();
                  if (onContinue != null) onContinue!();
                }
              : null,
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 15),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? _disabledBg
                  : Colors.white,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? _disabledFg
                  : _tealDeep,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.isBusy
                    ? l10n.welcomeSavingLabel
                    : l10n.welcomeContinueButton,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (ready) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
