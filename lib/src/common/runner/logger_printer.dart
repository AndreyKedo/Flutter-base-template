import 'package:logging/logging.dart' show LogRecord;
import 'package:starter_template/src/common/runner/platform/log_printer_vm.dart'
    if (dart.library.js_interop) 'package:starter_template/src/common/runner/platform/log_printer_js.dart';

import 'platform/log_printer_interface.dart';

sealed class LogRecordPrinter {
  static ILogPrinter map(LogRecord record) => mapRecord(record);

  static void write(ILogPrinter printer) => printer.print();
}
