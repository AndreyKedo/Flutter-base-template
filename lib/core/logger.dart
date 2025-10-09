import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

extension type AppLogger._(Logger _logger) {
  factory AppLogger.named(String name) => AppLogger._(Logger(name));

  /// Позволяет получить залогированные события.
  static final collector = LogCollector._();

  /// Root logger
  static final r = AppLogger._(Logger.root);
  static StreamSubscription? _loggerSub;

  static void enableLogger() {
    final logger = r._logger;
    logger.level = Level.ALL;
    _loggerSub = logger.onRecord.listen((record) {
      collector.addRecord(record);
      dev.log(
        record.message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
  }

  /// Pause log sequence
  static void pause() => _loggerSub?.pause();

  /// Resume log sequence
  static void resume() => _loggerSub?.resume();

  void setLogLevel(Level value) => _logger.level = value;

  /// Info
  void i(Object? message, [Object? error, StackTrace? stackTrace]) => _logger.info(message, error, stackTrace);

  /// Debug
  void d(Object? message, [Object? error, StackTrace? stackTrace]) => _logger.shout(message, error, stackTrace);

  /// Error
  void e(Object? message, [Object? error, StackTrace? stackTrace]) => _logger.severe(message, error, stackTrace);

  /// Warning
  void w(Object? message, [Object? error, StackTrace? stackTrace]) => _logger.warning(message, error, stackTrace);
}

abstract final class LogCollector implements ValueListenable<UnmodifiableListView<LogRecord>> {
  factory LogCollector._() => _LogCollectorImpl._();

  @protected
  void addRecord(LogRecord value);
}

final class _LogCollectorImpl extends ChangeNotifier implements LogCollector {
  _LogCollectorImpl._();

  final _list = <LogRecord>[];

  @override
  UnmodifiableListView<LogRecord> get value => UnmodifiableListView(_list);

  @override
  void addRecord(LogRecord value) {
    _list.add(value);
    notifyListeners();
  }

  @protected
  @override
  void dispose() {
    super.dispose();
  }
}
