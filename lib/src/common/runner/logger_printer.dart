/*
* logger_printer.dart
* Logger printer. Base mapping log message and format message
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:logging/logging.dart' show LogRecord;

import 'platform/log_printer_interface.dart';

import 'package:starter_template/src/common/runner/platform/log_printer_vm.dart'
    if (dart.library.html) 'package:sberdevices/src/common/runner/platform/log_printer_js.dart';

sealed class LogRecordPrinter {
  static ILogPrinter map(LogRecord record) => mapRecord(record);

  static void write(ILogPrinter printer) {
    final StringBuffer trace = StringBuffer();
    trace.write(printer);
    if (printer.isError) {
      final validError = printer.errorObj;
      trace
        ..write(' ')
        ..writeln(printer.message)
        ..writeln('\nDetails:\n')
        ..writeln(printer.strColorWrapper(printer.level, '${validError ?? ''}'));
      // trace.writeln(
      //     ' ${printer.message} \n\n Details:\n\n ${printer.strColorWrapper(printer.level, '${validError ?? ''}')}');
      if (printer.stackTrace != null) {
        trace.writeln(printer.stackTrace);
      }
    } else {
      trace.write(' ${printer.strColorWrapper(printer.level, printer.message)}');
    }
    debugPrint(trace.toString());
  }
}
