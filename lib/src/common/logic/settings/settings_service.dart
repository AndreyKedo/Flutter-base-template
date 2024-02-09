import 'package:flutter/material.dart' show ThemeMode, Locale;
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsService {
  SettingsService(this.store, this.defaultLocale) {
    locale ??= defaultLocale;
  }

  final SharedPreferences store;
  final Locale defaultLocale;

  ///Return cached locale if exist, else sets default locale and returns.
  Locale? get locale {
    final localeStr = store.getString('locale');
    if (localeStr == null) return null;
    return Locale.fromSubtags(languageCode: localeStr);
  }

  set locale(Locale? value) {
    if (value == locale) return;

    if (value != null) {
      store.setString('locale', value.languageCode);
    }
  }

  ThemeMode get theme {
    final themeIndex = store.getInt('themeMode');
    if (themeIndex == null || ThemeMode.values.length < themeIndex + 1) {
      store.setInt('themeMode', ThemeMode.system.index);
      return ThemeMode.system;
    }
    return ThemeMode.values[themeIndex];
  }

  set theme(ThemeMode theme) {
    if (theme == this.theme) return;

    store.setInt('themeMode', theme.index);
  }
}
