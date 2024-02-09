export 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:starter_template/src/common/localization/localization.dart';

///BuildContext extension for localization
extension AppLocalizationContextX on BuildContext {
  ///Current localization delegate
  AppLocalizations get localized {
    final delegate = AppLocalizations.of(this);
    assert(delegate != null, 'Do not have AppLocalizations into elements tree');
    return delegate!;
  }

  ///Current locale taked from [Localizations]
  Locale get locale => Localizations.localeOf(this);

  ///Material localizations
  ///
  ///Use if platform target is Android or other than iOS
  MaterialLocalizations get materialLocalization => MaterialLocalizations.of(this);

  ///Cupertino localizations
  ///
  ///Use if platform target is iOS or macOS
  CupertinoLocalizations get cupertinoLocalization => CupertinoLocalizations.of(this);

  ///Supported locales list
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
}

///AppLocalizations delegate extension
extension AppLocalizationsX on AppLocalizations {
  static Locale get fallback => const Locale('en');

  static Locale computeDefaultLocale() {
    final locale = PlatformDispatcher.instance.locale;

    if (AppLocalizations.delegate.isSupported(locale)) return Locale.fromSubtags(languageCode: locale.languageCode);

    return fallback;
  }

  ///Resolve multilocale
  ///
  ///Default [en]
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T localeResolver<T>({required ValueGetter<T> en, ValueGetter<T>? ru, ValueGetter<T>? zh}) {
    final map = {'en': en, 'ru': ru, 'zh': zh};

    return map[localeName]?.call() ?? en();
  }
}
