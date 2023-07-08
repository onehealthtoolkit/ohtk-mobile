/*
 * hotfix: @todo fix this later
 * ScreenUtil is a Flutter library for adapting screen and font size.
 * but when upgrade to flutter 3.10.5 with dart version3,  
 * there are a problem that cause the app to rebuild when keyboard show/hide
 * so we need to make if not rebuild when keyboard show/hide by wrapping with builder that return the same widget
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixScreenUtilAppWrapper extends StatelessWidget {
  final Widget child;
  const FixScreenUtilAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var mediaQueryData = MediaQuery.of(context);
      ScreenUtil.configure(
        data: mediaQueryData,
        designSize: getScreenSize(mediaQueryData),
        minTextAdapt: true,
        splitScreenMode: true,
      );

      return child;
    });
  }

  Size getScreenSize(MediaQueryData data) {
    if (data.size.shortestSide < 550) {
      // Phone
      return const Size(360, 640);
    } else {
      // Tablet
      return const Size(768, 1024);
    }
  }
}
