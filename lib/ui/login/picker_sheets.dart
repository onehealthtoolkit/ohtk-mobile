import 'package:flutter/material.dart';
import 'package:podd_app/components/language_dropdown.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';

Color get _tealHero => OhtkTheme.palette.teal700;
Color get _tealMuted => OhtkTheme.palette.teal50;
Color get _ink => OhtkColor.ink900;
Color get _muted => OhtkColor.ink500;
Color get _hair => OhtkColor.line;
Color get _placeholder => OhtkColor.ink300;
Color get _disabled => OhtkColor.line;
Color get _disabledFg => OhtkColor.ink300;
const _fontFamily = OhtkType.family;
const _fontFamilyFallback = OhtkType.fallback;

const _romanizedFallback = <String, String>{
  'en': 'EN',
  'th': 'Thai',
  'km': 'Khmer',
  'lo': 'Lao',
  'fr': 'French',
  'es': 'Spanish',
  'my': 'Burmese',
};

const _shortNativeName = <String, String>{
  'en': 'English',
  'th': 'ไทย',
  'km': 'ខ្មែរ',
  'lo': 'ລາວ',
  'fr': 'Français',
  'es': 'Español',
  'my': 'မြန်မာ',
};

class LanguagePickerSheet extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onPicked;

  const LanguagePickerSheet({
    Key? key,
    required this.currentLanguage,
    required this.onPicked,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String currentLanguage,
    required ValueChanged<String> onPicked,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LanguagePickerSheet(
        currentLanguage: currentLanguage,
        onPicked: onPicked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            _SheetHeader(
              title: l10n.signInChangeLanguageTitle,
              onClose: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 158 / 60,
                children: supportedLanguages.map((option) {
                  final code = option[1];
                  final selected = currentLanguage == code;
                  return _LightSelectableCard(
                    selected: selected,
                    onTap: () => onPicked(code),
                    child: Row(
                      children: [
                        _LightRadio(selected: selected),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _shortNativeName[code] ?? option[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontFamilyFallback: _fontFamilyFallback,
                                  color: _ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _romanizedFallback[code] ?? '',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontFamilyFallback: _fontFamilyFallback,
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _hair, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              alignment: Alignment.center,
              child: Text(
                l10n.signInChangeLanguageHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontFamilyFallback: _fontFamilyFallback,
                  color: _placeholder,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerPickerSheet extends StatefulWidget {
  final String currentServerDomain;
  final List<Map<String, String>> servers;
  final ValueChanged<String> onConfirmed;

  const ServerPickerSheet({
    Key? key,
    required this.currentServerDomain,
    required this.servers,
    required this.onConfirmed,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String currentServerDomain,
    required List<Map<String, String>> servers,
    required ValueChanged<String> onConfirmed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ServerPickerSheet(
        currentServerDomain: currentServerDomain,
        servers: servers,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<ServerPickerSheet> createState() => _ServerPickerSheetState();
}

class _ServerPickerSheetState extends State<ServerPickerSheet> {
  late String _selectedDomain;

  @override
  void initState() {
    super.initState();
    _selectedDomain = widget.currentServerDomain;
  }

  bool get _hasChange => _selectedDomain != widget.currentServerDomain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DragHandle(),
              _SheetHeader(
                title: l10n.signInChangeServerTitle,
                subtitle: l10n.signInChangeServerHint,
                onClose: () => Navigator.pop(context),
              ),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  shrinkWrap: true,
                  itemCount: widget.servers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final server = widget.servers[index];
                    final domain = server['domain'] ?? '';
                    final label = server['label'] ?? domain;
                    final selected = _selectedDomain == domain;
                    final isCurrent = widget.currentServerDomain == domain;
                    return _LightSelectableCard(
                      selected: selected,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      onTap: () => setState(() => _selectedDomain = domain),
                      child: Row(
                        children: [
                          _LightRadio(selected: selected, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: _fontFamily,
                                          fontFamilyFallback:
                                              _fontFamilyFallback,
                                          color: _ink,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      _CurrentBadge(
                                          label: l10n.signInServerCurrentBadge),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  domain,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontFamilyFallback: _fontFamilyFallback,
                                    color: _muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: _hair, width: 1)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.signInCancelButton,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontFamilyFallback: _fontFamilyFallback,
                          color: _muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: _hasChange
                            ? () => widget.onConfirmed(_selectedDomain)
                            : null,
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? _disabled
                                : _tealHero,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? _disabledFg
                                : Colors.white,
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.signInConfirmServerButton,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontFamilyFallback: _fontFamilyFallback,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: _hair,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.title,
    required this.onClose,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontFamilyFallback: _fontFamilyFallback,
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontFamilyFallback: _fontFamilyFallback,
                      color: _muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CloseButton(onPressed: onClose),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF1EFEA),
          ),
          child: Icon(Icons.close, size: 18, color: _muted),
        ),
      ),
    );
  }
}

class _LightSelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  const _LightSelectableCard({
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            color: selected ? _tealMuted : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _tealHero : _hair,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LightRadio extends StatelessWidget {
  final bool selected;
  final double size;
  const _LightRadio({required this.selected, this.size = 18});

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
          color: selected ? _tealHero : _hair,
          width: ringWidth,
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  final String label;
  const _CurrentBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _tealMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFamilyFallback,
          color: _tealHero,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
