/*
* log_printer_interface.dart
* Message formatting 
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'package:logging/logging.dart' show LogRecord, Level;

abstract class ILogPrinter extends LogRecord {
  ILogPrinter(
    super.level,
    super.message,
    super.loggerName, [
    super.error,
    super.stackTrace,
    super.zone,
    super.object,
  ]);

  static final Map<Level, String> _levelEmojiMap = {
    Level.SHOUT: '🫣', //исключение
    Level.SEVERE: '🔥', //ошибка
    Level.WARNING: '❗️', //предупреждение
    Level.INFO: 'ℹ️', // информация
    Level.FINE: '✅', // больше информации
  };
  static const String _defaultEmoji = '🤨';

  static final Map<Level, String> _colorConsoleCodes = {
    Level.SEVERE: '\x1B[31m',
    Level.WARNING: '\x1B[33m',
    Level.INFO: '\x1B[32m',
    Level.FINE: '\x1B[37m',
  };
  static const String _defaultConsoleColor = '\x1B[34m';

  Object? get errorObj => error is Exception || error is Error || error is String ? error : null;

  bool get isError => error != null || stackTrace != null;

  String _colorByLevel(Level level) => _colorConsoleCodes[level] ?? _defaultConsoleColor;

  String get levelEmoji => _levelEmojiMap[level] ?? _defaultEmoji;
  String strColorWrapper(String src) => '${_colorByLevel(level)}$src\x1B[0m';

  void print();

  @override
  String toString() => '$levelEmoji ${strColorWrapper('[${level.name}]')} ${strColorWrapper(message)}';
}
