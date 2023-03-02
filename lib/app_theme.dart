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
  // medium gray 2
  Color sub2 = const Color.fromRGBO(173, 181, 194, 1);
  // light gray 3
  Color sub3 = const Color.fromRGBO(200, 205, 212, 1);
  // orange
  Color warn = const Color.fromRGBO(243, 149, 95, 1);

  ThemeData get themeData => ThemeData.light().copyWith(
      primaryColor: primary,
      appBarTheme: AppBarTheme(
        backgroundColor: bg1,
        iconTheme: IconThemeData(
          color: primary,
        ),
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
            bodySmall: TextStyle(color: bg1),
            bodyMedium: TextStyle(color: bg1),
            bodyLarge: TextStyle(color: bg1),
            titleSmall: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: bg1,
        selectedIconTheme: IconThemeData(color: primary),
        backgroundColor: Colors.white,
        unselectedIconTheme: IconThemeData(color: sub2),
        unselectedItemColor: sub3,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: bg1,
        unselectedLabelColor: sub3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: warn, width: 2),
        ),
      ));
}
