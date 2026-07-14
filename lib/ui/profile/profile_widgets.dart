import 'package:flutter/material.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

const double _cardRadius = 16;
Color get _profileTeal => OhtkTheme.palette.teal700;

class ProfileSectionCard extends StatelessWidget {
  final String? eyebrow;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const ProfileSectionCard({
    super.key,
    this.eyebrow,
    required this.children,
    this.trailing,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      eyebrow!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: incidentsMuted,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          OhtkCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: OhtkRadius.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDataRow extends StatelessWidget {
  final String label;
  final String? value;
  final String emptyValueText;
  final bool isLast;

  const ProfileDataRow({
    super.key,
    required this.label,
    required this.value,
    required this.emptyValueText,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: incidentsHair, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: incidentsMuted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hasValue ? value! : emptyValueText,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
              fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
              color: hasValue ? incidentsInk : incidentsMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;
  final bool danger;

  const ProfileActionRow({
    super.key,
    this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.isLast = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = danger ? incidentsErrorRed : incidentsInk;
    final iconColor = danger ? incidentsErrorRed : incidentsMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: incidentsHair, width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    height: 1.25,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: incidentsMuted,
                    ),
                  ),
                ),
              ],
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: trailing,
                )
              else if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: incidentsMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSignOutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const ProfileSignOutRow({
    super.key,
    this.icon = Icons.logout,
    required this.label,
    required this.onTap,
    this.margin = const EdgeInsets.fromLTRB(14, 8, 14, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: OhtkCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: incidentsErrorRed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: incidentsErrorRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDashedPrompt extends StatelessWidget {
  final String title;
  final String body;
  final EdgeInsetsGeometry margin;

  const ProfileDashedPrompt({
    super.key,
    required this.title,
    required this.body,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _profileTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: _profileTeal.withValues(alpha: 0.45),
          radius: _cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: _profileTeal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: incidentsInk,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: incidentsBody,
                        height: 1.45,
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

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? helper;
  final String? optionalLabel;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffix;

  const ProfileTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    this.helper,
    this.optionalLabel,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = false,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: incidentsInk,
                height: 1.3,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: incidentsErrorRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (optionalLabel != null)
                  TextSpan(
                    text: '  ·  $optionalLabel',
                    style: const TextStyle(
                      color: incidentsMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? const Color(0xFFE8B6AB) : incidentsHair,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: maxLines > 1 ? 8 : 0,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            obscureText: obscureText,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            maxLines: obscureText ? 1 : maxLines,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: incidentsInk,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 6 : 13,
              ),
              suffixIcon: suffix,
              suffixIconConstraints: const BoxConstraints(minHeight: 0),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _InlineErrorPill(message: errorText!),
          ),
        ] else if (helper != null && helper!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helper!,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: incidentsMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineErrorPill extends StatelessWidget {
  final String message;
  const _InlineErrorPill({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAE5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 13, color: incidentsErrorRed),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: incidentsErrorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
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
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
