import 'package:flutter/material.dart';

import 'settings_service.dart';
export 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  ThemeMode get themeMode => _settingsService.theme;
  Locale? get locale => _settingsService.locale;

  void changeLocale(Locale? locale) {
    if (locale == null) return;

    _settingsService.locale = locale;
    notifyListeners();
  }

  void updateThemeMode(ThemeMode newThemeMode) {
    _settingsService.theme = newThemeMode;
    notifyListeners();
  }
}
