/*
* log_printer_js.dart
* Log formatter web implementation
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'package:logging/logging.dart' show LogRecord;
import 'log_printer_interface.dart';

ILogPrinter mapRecord(LogRecord record) {
  return _LogRecordJS(
      record.level, record.message, record.loggerName, record.error, record.stackTrace, record.zone, record.object);
}

final class _LogRecordJS extends ILogPrinter {
  _LogRecordJS(super.level, super.message, super.loggerName, [super.error, super.stackTrace, super.zone, super.object]);
}
