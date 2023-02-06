import 'package:flutter/material.dart' show ThemeMode, Locale;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this.store);

  final SharedPreferences store;

  Future<String?> locale() async => store.getString('locale');

  Future<void> updateLocale(Locale locale) async {
    await store.setString('locale', locale.toString());
  }

  Future<ThemeMode> themeMode() async {
    final themeIndex = store.getInt('themeMode');
    if (themeIndex == null || ThemeMode.values.length < themeIndex + 1) {
      store.setInt('themeMode', ThemeMode.system.index);
      return ThemeMode.system;
    }
    return ThemeMode.values[themeIndex];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    store.setInt('themeMode', theme.index);
  }
}
