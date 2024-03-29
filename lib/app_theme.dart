import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // teal color
  Color primary = const Color(0xFF00ADB5);
  // soft teal color
  Color secondary = const Color(0xFFAAD8D3);
  // lighter teal color
  Color tertiary = const Color(0xFFD0F2EE);
  // dark almost black
  Color bg1 = const Color(0xFF393E46);
  // soft white
  Color bg2 = const Color(0xFFF9F9F9);
  // gray 1
  Color sub1 = const Color(0xFF393E46);
  // light gray 2
  Color sub2 = const Color(0xFFADB5C2);
  // lighter gray 3
  Color sub3 = const Color(0xFFC8CDC4);
  // lightest gray (placeholder)
  Color sub4 = const Color(0xFFe3e7ed);
  // orange
  Color warn = const Color(0xFFF3955F);
  // seashell soft white yellow
  Color hilight = const Color(0xFFFFF0E0);
  // pastel red
  Color tag1 = const Color(0xFFFFB5B5);
  // pastel yellow
  Color tag2 = const Color(0xFFFFE0A4);

  double borderRadius = 6;

  Color inputTextColor = Colors.black;

  // default font
  String font = 'NotoSansThai';

  var defaultTheme = ThemeData.light();

  ThemeData get themeData => ThemeData(
        fontFamily: font,
        colorScheme: defaultTheme.colorScheme,
        primaryColor: primary,
        highlightColor: hilight,
        appBarTheme: defaultTheme.appBarTheme.copyWith(
          backgroundColor: bg1,
          iconTheme: IconThemeData(
            color: primary,
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22.sp,
            fontFamily: font,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: defaultTheme.textTheme.copyWith(
          bodySmall: TextStyle(
            fontFamily: font,
            color: bg1,
            fontSize: 10.sp,
            fontWeight: FontWeight.w200,
          ),
          bodyMedium: TextStyle(
            fontFamily: font,
            color: bg1,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
          bodyLarge: TextStyle(
            fontFamily: font,
            color: bg1,
            fontSize: 15.sp,
            fontWeight: FontWeight.normal,
          ),
          titleSmall: TextStyle(
            fontFamily: font,
            color: primary,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            // also use by textinputfield
            // this is conflict between report list view and textinputfield
            fontFamily: font,
            color: sub1,
            fontWeight: FontWeight.normal,
          ),
          titleLarge: TextStyle(
            fontFamily: font,
            color: primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
          fillColor: bg2,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: sub3),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: warn),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          labelStyle: TextStyle(
            fontFamily: font,
            color: sub2,
            fontSize: 13.sp,
          ),
          hintStyle: TextStyle(
            fontFamily: font,
            color: sub2,
          ),
          errorStyle: TextStyle(
            fontFamily: font,
            color: Colors.red,
            fontSize: 10.sp,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            textStyle: TextStyle(
              fontFamily: font,
              color: Colors.white,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: TextStyle(
              fontFamily: font,
            ),
          ),
        ),
        bottomNavigationBarTheme:
            defaultTheme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: bg1,
          selectedIconTheme: IconThemeData(color: primary),
          backgroundColor: Colors.white,
          unselectedIconTheme: IconThemeData(color: sub2),
          unselectedItemColor: sub3,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            fontFamily: font,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        tabBarTheme: defaultTheme.tabBarTheme.copyWith(
          labelColor: bg1,
          unselectedLabelColor: sub3,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            fontFamily: font,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            fontFamily: font,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: warn, width: 3),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return primary;
            }
            return null;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return primary;
            }
            return null;
          }),
        ),
      );
}
