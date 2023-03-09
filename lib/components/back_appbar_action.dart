import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackAppBarAction extends StatelessWidget {
  const BackAppBarAction({Key? key, this.onPressed})
      : super(
          key: key,
        );

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.keyboard_backspace,
        color: Theme.of(context).primaryColor,
        size: 17.w,
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
