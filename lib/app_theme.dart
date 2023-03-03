import 'package:flutter/material.dart';

class AppTheme {
  // teal color
  Color primary = const Color.fromRGBO(0, 173, 181, 1);
  // soft teal color
  Color secondary = const Color.fromRGBO(208, 242, 238, 1);
  // dark almost black
  Color bg1 = const Color.fromRGBO(57, 62, 70, 1);
  // soft white
  Color bg2 = const Color.fromRGBO(57, 62, 70, 1);
  // gray 1
  Color sub1 = const Color.fromRGBO(57, 62, 70, 1);
  // light gray 2
  Color sub2 = const Color.fromRGBO(173, 181, 194, 1);
  // lighter gray 3
  Color sub3 = const Color.fromRGBO(200, 205, 212, 1);
  // orange
  Color warn = const Color.fromRGBO(243, 149, 95, 1);

  // default font
  String font = 'NotoSansThai';

  var defaultTheme = ThemeData.light();

  ThemeData get themeData => ThemeData(
      fontFamily: font,
      colorScheme: defaultTheme.colorScheme,
      primaryColor: primary,
      appBarTheme: defaultTheme.appBarTheme.copyWith(
        backgroundColor: bg1,
        iconTheme: IconThemeData(
          color: primary,
        ),
      ),
      textTheme: defaultTheme.textTheme.copyWith(
        bodySmall: TextStyle(fontFamily: font, color: bg1),
        bodyMedium: TextStyle(fontFamily: font, color: bg1),
        bodyLarge: TextStyle(fontFamily: font, color: bg1),
        titleSmall: TextStyle(
          fontFamily: font,
          color: primary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: font,
          color: primary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: font,
          color: primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          textStyle: TextStyle(
            fontFamily: font,
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
      bottomNavigationBarTheme: defaultTheme.bottomNavigationBarTheme.copyWith(
        selectedItemColor: bg1,
        selectedIconTheme: IconThemeData(color: primary),
        backgroundColor: Colors.white,
        unselectedIconTheme: IconThemeData(color: sub2),
        unselectedItemColor: sub3,
      ),
      tabBarTheme: defaultTheme.tabBarTheme.copyWith(
        labelColor: bg1,
        unselectedLabelColor: sub3,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: font,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: warn, width: 3),
        ),
      ));
}
