import 'package:flutter/material.dart';
import 'package:starter_template/src/common/controller/controller.dart';
import 'package:starter_template/src/common/localization/localization.dart' as localization;

import 'settings_service.dart';

class ApplicationSettings {
  const ApplicationSettings({
    this.locale = localization.fallback,
    this.themeMode = ThemeMode.system,
  });

  final Locale locale;
  final ThemeMode themeMode;

  ApplicationSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
  }) =>
      ApplicationSettings(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  int get hashCode => Object.hash(
        runtimeType,
        locale,
        themeMode,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationSettings &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          themeMode == other.themeMode;
}

class SettingsController extends ValueNotifier<ApplicationSettings> with Controller {
  SettingsController(this._settingsService) : super(const ApplicationSettings());

  final SettingsService _settingsService;

  Locale get locale => value.locale;

  ThemeMode get theme => value.themeMode;

  Future<void> initialize() async {
    final locale = await _settingsService.locale;
    final themeMode = await _settingsService.theme;

    value = ApplicationSettings(
      locale: locale,
      themeMode: themeMode,
    );
  }

  Future<void> changeLocale(Locale locale) async {
    await _settingsService.setLocale(locale);
    value = value.copyWith(locale: locale);
  }
}
