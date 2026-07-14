import 'package:flutter/material.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  OhtkThemePreset get preset => OhtkThemeConfig.preset;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPreset = prefs.getString(themePresetKey);
    if (storedPreset == null || storedPreset.trim().isEmpty) return;
    OhtkThemeConfig.usePreset(OhtkThemePreset.fromName(storedPreset));
  }

  Future<void> setPreset(OhtkThemePreset preset) async {
    if (preset == this.preset) return;
    OhtkThemeConfig.usePreset(preset);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themePresetKey, preset.name);
    notifyListeners();
  }

  // teal color
  Color get primary => OhtkTheme.palette.teal700;
  // soft teal color
  Color get secondary => OhtkTheme.palette.teal100;
  // lighter teal color
  Color get tertiary => OhtkTheme.palette.teal50;
  // dark almost black
  Color get bg1 => OhtkColor.ink900;
  // soft white
  Color get bg2 => OhtkColor.cream;
  // gray 1
  Color get sub1 => OhtkColor.ink700;
  // light gray 2
  Color get sub2 => OhtkColor.ink400;
  // lighter gray 3
  Color get sub3 => OhtkColor.line;
  // lightest gray (placeholder)
  Color get sub4 => OhtkColor.lineSoft;
  // orange
  Color get warn => OhtkColor.warning;
  // seashell soft white yellow
  Color get hilight => OhtkColor.warningBg;
  // pastel red
  Color get tag1 => const Color(0xFFFFB5B5);
  // pastel yellow
  Color get tag2 => const Color(0xFFFFE0A4);

  double borderRadius = 10;

  Color get inputTextColor => OhtkColor.ink900;

  // default font
  String font = OhtkType.family;

  ThemeData get themeData => OhtkTheme.build();
}
