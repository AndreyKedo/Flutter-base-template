import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Обертка для [DateFormat] с поддержкой локализации.
extension type const DateFormats(DateFormat _format) implements DateFormat {
  /// `dd.MM.yyyy HH:mm`
  static final ddMmYyHhMm = DateFormats(DateFormat('dd.MM.yyyy HH:mm'));

  /// `dd MMMM yyyy`
  static final dMMMMy = DateFormats(DateFormat('dd MMMM yyyy'));

  /// `dd.MM.yyyy`
  static final dMMy = DateFormats(DateFormat('dd.MM.yyyy'));

  /// Возвращает новый объект [DateFormats] с [locale].
  DateFormats applyLocale(Locale locale) => DateFormats(DateFormat(_format.pattern, locale.toString()));
}

extension type IntlHelperContextWrapper(BuildContext _c) {
  String formatBy(DateFormats format, DateTime value) => format.format(value);

  DateTime parseStrict(DateFormats format, String value) => format.parseStrict(value);

  /// Возвращает дату в формате [DateFormats.ddMmYyHhMm].
  String ddMmYyHhMm(DateTime value) {
    final locale = Localizations.localeOf(_c);
    return DateFormats.ddMmYyHhMm.applyLocale(locale).format(value);
  }

  /// Возвращает дату в формате [DateFormats.dMMMMMy].
  String dMMMMy(DateTime value) {
    final locale = Localizations.localeOf(_c);

    return DateFormats.dMMMMy.applyLocale(locale).format(value);
  }

  /// Возвращает дату в формате [MaterialLocalizations.formatCompactDate].
  String dMMy(DateTime value) {
    final matLocalize = MaterialLocalizations.of(_c);
    return matLocalize.formatCompactDate(value);
  }

  String currencyFormat(Object value) {
    final locale = Localizations.localeOf(_c);
    final formatter = NumberFormat.currency(locale: locale.toString(), symbol: '₽', decimalDigits: 2);
    return formatter.format(
      switch (value) {
        String str => num.parse(str),
        num number => number,
        _ => throw ArgumentError.value(
          value,
          'CurrencyFormat::value'
          'value must be a string or a number',
        ),
      },
    );
  }
}
