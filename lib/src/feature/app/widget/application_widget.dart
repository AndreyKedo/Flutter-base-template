import 'package:flutter/material.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/feature/app/di/dependency_storage.dart';
import 'package:starter_template/src/feature/home/home_screen.dart';
import 'package:starter_template/src/feature/localization/localization_scope.dart';

class ApplicationWidget extends StatelessWidget {
  const ApplicationWidget({
    required this.storage,
    super.key,
  });

  final DependencyStorage storage;

  @override
  Widget build(BuildContext context) => LocalizationScope(
        settings: storage.settingsController,
        child: Builder(
          builder: (context) {
            final currentLocale = LocalizationScope.of(context).locale;
            return MaterialApp(
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
                return fallback;
              },
              home: HomeScreen(),
            );
          },
        ),
      );
}
