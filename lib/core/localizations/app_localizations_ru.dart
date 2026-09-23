// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'FlutterBase';

  @override
  String get timeoutError => 'Превышено время ожидания ответа от сервера.';

  @override
  String get socketError => 'Не удалось установить соединение. Проверьте подключение к сети интернет.';

  @override
  String get unknownError => 'Произошла неизвестная ошибка.';

  @override
  String get validationError => 'Ошибка валидации данных.';

  @override
  String get stateError => 'Некорректное внутренние состояние программы.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get authenticationError => 'Authentication failed. Please sign in again.';

  @override
  String apiError(Object statusCode) {
    return 'Request failed (code: $statusCode).';
  }

  @override
  String get socketConnectionError =>
      'This action requires an internet connection. Check your connection and try again.';
}
