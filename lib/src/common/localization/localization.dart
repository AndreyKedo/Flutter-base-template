import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starter_template/src/common/localization/localization.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

const fallback = Locale('en');

Locale computeDefaultLocale() {
  final locale = PlatformDispatcher.instance.locale;

  if (AppLocalizations.delegate.isSupported(locale)) return Locale.fromSubtags(languageCode: locale.languageCode);

  return fallback;
}

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

  /// Format [DateTime] value by [DateFormat] formatter.
  /// If [DateTime.isUtc] equal true, before format [DateTime] object to be is converted to local time.
  /// If [DateTime.isUtc] equal true and isConverted false, [DateTime] object not  converted to local time.
  ///
  /// If [dateTime] equal null will be take [DateTime.now()].
  /// If [formatter] equal null will be take this [DateFormat.yMd().add_Hm()] formatter pattern.
  String formatDateTime({
    DateTime? dateTime,
    DateFormat? formatter,
  }) {
    dateTime ??= DateTime.now();
    formatter ??= DateFormat.yMd(locale.languageCode).add_Hm();

    return switch (dateTime) {
      final DateTime value when value.isUtc => formatter.format(value.toLocal()),
      final DateTime value => formatter.format(value)
    };
  }
}
