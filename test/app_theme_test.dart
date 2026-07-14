import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OhtkThemeConfig.usePreset(OhtkThemeConfig.defaultPreset);
  });

  tearDown(() {
    OhtkThemeConfig.usePreset(OhtkThemeConfig.defaultPreset);
  });

  test('loads stored theme preset', () async {
    SharedPreferences.setMockInitialValues({
      themePresetKey: OhtkThemePreset.lahis.name,
    });

    final appTheme = AppTheme();
    await appTheme.init();

    expect(appTheme.preset, OhtkThemePreset.lahis);
    expect(OhtkTheme.palette.teal700, OhtkThemePreset.lahis.palette.teal700);
  });

  test('persists selected preset and notifies listeners', () async {
    final appTheme = AppTheme();
    await appTheme.init();

    var notifications = 0;
    appTheme.addListener(() => notifications++);

    await appTheme.setPreset(OhtkThemePreset.tide);
    final prefs = await SharedPreferences.getInstance();

    expect(appTheme.preset, OhtkThemePreset.tide);
    expect(prefs.getString(themePresetKey), OhtkThemePreset.tide.name);
    expect(notifications, 1);
  });

  test('exposes every design-system preset in picker order', () {
    expect(
      OhtkThemePreset.values.map((preset) => preset.label),
      [
        'Lagoon',
        'Tide',
        'Mist',
        'Forest',
        'Indigo',
        'Sunset',
        'Plum',
        'Slate',
        'Crimson',
        'LAHIS',
      ],
    );
  });
}
