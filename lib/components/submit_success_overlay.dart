import 'package:flutter/material.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

class SubmitSuccessOverlay extends StatefulWidget {
  final String message;
  final Duration holdDuration;

  const SubmitSuccessOverlay({
    required this.message,
    this.holdDuration = const Duration(milliseconds: 800),
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    Duration holdDuration = const Duration(milliseconds: 800),
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => SubmitSuccessOverlay(
        message: message,
        holdDuration: holdDuration,
      ),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<SubmitSuccessOverlay> createState() => _SubmitSuccessOverlayState();
}

class _SubmitSuccessOverlayState extends State<SubmitSuccessOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _checkCtrl;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _cardCtrl.forward();
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) _checkCtrl.forward();
    });

    final dismissAfter =
        const Duration(milliseconds: 280) + widget.holdDuration;
    Future.delayed(dismissAfter, () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _cardCtrl,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: _cardCtrl,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: OhtkTheme.palette.teal700
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                        ),
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _checkCtrl,
                            curve: Curves.easeOutCubic,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: OhtkTheme.palette.teal700,
                            size: 46,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: incidentsInk,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
