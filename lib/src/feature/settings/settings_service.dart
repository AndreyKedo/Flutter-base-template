import 'package:flutter/material.dart' show ThemeMode, Locale;
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsService {
  SettingsService(this.store, Locale defaultLocale) {
    _locale = defaultLocale;
  }

  final SharedPreferencesAsync store;

  late Locale _locale;
  ThemeMode _theme = ThemeMode.system;

  Future<Locale> get locale async {
    final localeStr = await store.getString('locale');
    if (localeStr == null) return _locale;

    return _locale = Locale.fromSubtags(languageCode: localeStr);
  }

  Future<void> setLocale(Locale value) async {
    if (value == _locale) return;
    _locale = value;
    await store.setString('locale', value.languageCode);
  }

  Future<ThemeMode> get theme async {
    final themeIndex = await store.getInt('themeMode');
    if (themeIndex == null || ThemeMode.values.length < themeIndex + 1) {
      await store.setInt('themeMode', ThemeMode.system.index);
      return _theme = ThemeMode.system;
    }
    return _theme = ThemeMode.values[themeIndex];
  }

  void setTheme(ThemeMode value) async {
    if (value == _theme) return;

    await store.setInt('themeMode', value.index);
  }
}
