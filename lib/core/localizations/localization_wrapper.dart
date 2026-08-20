import 'package:material_ui/material_ui.dart';
import 'package:starter_template/core/localizations/app_localizations.dart';

extension type ApplicationLocalizationWrapper._(AppLocalizations _context) implements AppLocalizations {
  /// Создает обертку для локализации приложения на основе контекста.
  ///
  /// Выбрасывает исключение, если в дереве виджетов отсутствует [AppLocalizations].
  factory(BuildContext context) {
    final delegate = AppLocalizations.of(context);
    assert(delegate != null, 'Do not have AppLocalizations into elements tree');
    return ApplicationLocalizationWrapper._(delegate!);
  }

  /// Список поддерживаемых локалей.
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Список делегатов локализации.
  Iterable<LocalizationsDelegate> get localizationsDelegates => const <LocalizationsDelegate>[
    ...GlobalMaterialLocalizations.delegates,
    AppLocalizations.delegate,
  ];
}
