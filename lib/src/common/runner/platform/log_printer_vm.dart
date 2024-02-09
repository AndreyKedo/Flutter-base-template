/*
* log_printer_vm.dart
* Log formatter VM implementation
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'dart:io';

import 'log_printer_interface.dart';
import 'package:logging/logging.dart' show LogRecord, Level;

ILogPrinter mapRecord(LogRecord record) {
  return _LogRecordVM(
      record.level, record.message, record.loggerName, record.error, record.stackTrace, record.zone, record.object);
}

final class _LogRecordVM extends ILogPrinter {
  _LogRecordVM(super.level, super.message, super.loggerName, [super.error, super.stackTrace, super.zone, super.object]);

  @override
  String strColorWrapper(Level level, String src) {
    if (Platform.isIOS) return src;
    return super.strColorWrapper(level, src);
  }
}
