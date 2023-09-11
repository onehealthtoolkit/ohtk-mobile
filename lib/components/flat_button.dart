import 'package:flutter/material.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

class FlatButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color forgroundColor;
  final Color borderColor;
  final double borderRadius;
  final Color? overlayColor;

  const FlatButton(
      {required this.child,
      required this.backgroundColor,
      required this.forgroundColor,
      required this.borderColor,
      required this.borderRadius,
      this.onPressed,
      this.padding,
      this.overlayColor,
      Key? key})
      : super(key: key);

  factory FlatButton.primary({
    required VoidCallback? onPressed,
    required Widget child,
    EdgeInsets? padding,
    Key? key,
    Color? backgroundColor,
  }) {
    final AppTheme apptheme = locator<AppTheme>();
    return FlatButton(
      onPressed: onPressed,
      padding: padding,
      key: key,
      backgroundColor: backgroundColor ?? apptheme.primary,
      forgroundColor: Colors.white,
      borderColor: backgroundColor ?? apptheme.primary,
      borderRadius: apptheme.borderRadius,
      overlayColor: Colors.black12,
      child: child,
    );
  }

  factory FlatButton.outline({
    required VoidCallback? onPressed,
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    Key? key,
  }) {
    final AppTheme apptheme = locator<AppTheme>();
    return FlatButton(
      onPressed: onPressed,
      padding: padding,
      key: key,
      backgroundColor: backgroundColor ?? Colors.transparent,
      forgroundColor: apptheme.primary,
      borderColor: apptheme.primary,
      borderRadius: apptheme.borderRadius,
      overlayColor: apptheme.primary.withOpacity(0.1),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    var padding = this.padding ?? const EdgeInsets.fromLTRB(40, 10, 40, 10);

    return TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            padding,
          ),
          overlayColor: overlayColor != null
              ? MaterialStateProperty.all<Color>(overlayColor!)
              : null,
          foregroundColor: MaterialStateProperty.all<Color>(forgroundColor),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child);
  }
}
