import 'package:flutter/foundation.dart' show debugPrint;
import 'package:logging/logging.dart' show LogRecord, Level;

extension on DateTime {
  String get formatted => [hour, minute, second].map(CustomPrint._timeFormat).join(':');
}

class CustomPrint {
  CustomPrint(this._record);
  final LogRecord _record;

  static String _timeFormat(int input) => input.toString().padLeft(2, '0');

  String _mapLevel(Level level) =>
      {Level.SEVERE: '🐞', Level.WARNING: '⚠️', Level.INFO: 'ℹ️', Level.FINE: '❕'}[level] ?? '🤨';
  static String _colorByLevel(Level level) =>
      {Level.SEVERE: '\x1B[31m', Level.WARNING: '\x1B[33m', Level.INFO: '\x1B[32m', Level.FINE: '\x1B[37m'}[level] ??
      '\x1B[34m';

  static String _strColorWrapper(Level level, String src) => '${_colorByLevel(level)}$src\x1B[0m';

  String get _loggerName => _record.loggerName;
  String get _message => _record.message;
  DateTime get _time => _record.time;

  Level get level => _record.level;
  Object? get error => _record.error is Exception || _record.error is Error ? _record.error : null;
  StackTrace? get stackTrace => _record.stackTrace;

  static write(CustomPrint e) {
    final StringBuffer trace = StringBuffer();
    trace.writeln(e);
    if (e.error != null && e.stackTrace != null) {
      trace
        ..writeln(_strColorWrapper(e.level, '${e.error ?? ''}'))
        ..writeln(e.stackTrace);
    }
    debugPrint(trace.toString());
  }

  @override
  String toString() {
    return '${_mapLevel(level)} ${_strColorWrapper(level, _time.formatted)} ${_strColorWrapper(level, '[$_loggerName]: $_message')}';
  }
}
