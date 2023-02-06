import 'package:flutter/material.dart';

import 'settings_service.dart';
export 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    final locale = await _settingsService.locale();
    if (locale != null) {
      _locale = Locale.fromSubtags(languageCode: locale);
    }
    notifyListeners();
  }

  Future<void> changeLocale(Locale? locale) async {
    if (locale == null) return;
    if (locale == _locale) return;

    _locale = locale;
    notifyListeners();
    await _settingsService.updateLocale(locale);
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }
}
