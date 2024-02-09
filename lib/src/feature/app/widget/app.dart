import 'package:flutter/material.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/common/widget/application.dart';
import 'package:starter_template/src/common/widget/dependency_scope.dart';
import 'package:starter_template/src/feature/app/di/dependency_storage.dart';
import 'package:starter_template/src/feature/scope/localization/localization_scope.dart';

class Application extends AppWrapper<DependencyStorage> {
  const Application({required super.dependencyFactory, super.key});

  static DependencyStorage dependencyOf(BuildContext context) => DependenciesScope.of<DependencyStorage>(context);

  @override
  Widget buildApp(DependencyStorage storage) => LocalizationScope(
        settings: storage.settingsController,
        child: Builder(builder: (context) {
          final currentLocale = LocalizationScope.of(context).locale;
          return MaterialApp.router(
            onGenerateTitle: (context) => context.localized.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: currentLocale,
            localeListResolutionCallback: basicLocaleListResolution,
            localeResolutionCallback: (final deviceLocale, final supportedLocales) {
              for (final locale in supportedLocales) {
                if (locale.languageCode == currentLocale?.languageCode) {
                  return currentLocale;
                }
              }
              for (final locale in supportedLocales) {
                if (deviceLocale == locale) {
                  return locale;
                }
              }
              return AppLocalizationsX.fallback;
            },
          );
        }),
      );
}
