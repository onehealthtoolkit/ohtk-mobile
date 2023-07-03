import 'package:flutter/material.dart';
import 'package:podd_app/locator.dart';
import 'package:stacked/stacked_annotations.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    const String environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: Environment.dev,
    );
    setupLocator(environment);
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
