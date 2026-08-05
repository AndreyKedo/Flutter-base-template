import 'package:flutter/widgets.dart';
import 'package:starter_template/core/localizations/app_localizations.dart';

extension type ApplicationLocalizationWrapper._(AppLocalizations _context) implements AppLocalizations {
  /// Создает обертку для локализации приложения на основе контекста.
  ///
  /// Выбрасывает исключение, если в дереве виджетов отсутствует [AppLocalizations].
  factory ApplicationLocalizationWrapper(BuildContext context) {
    final delegate = AppLocalizations.of(context);
    assert(delegate != null, 'Do not have AppLocalizations into elements tree');
    return ApplicationLocalizationWrapper._(delegate!);
  }

  /// Список поддерживаемых локалей.
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Список делегатов локализации.
  List<LocalizationsDelegate> get localizationsDelegates => AppLocalizations.localizationsDelegates;
}
