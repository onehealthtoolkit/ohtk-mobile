import 'package:flutter/widgets.dart';

class TestId extends StatelessWidget {
  const TestId({
    super.key,
    required this.id,
    required this.child,
    this.button = false,
    this.textField = false,
    this.liveRegion = false,
  });

  final String id;
  final Widget child;
  final bool button;
  final bool textField;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      identifier: id,
      button: button,
      textField: textField,
      liveRegion: liveRegion,
      child: child,
    );
  }
}
