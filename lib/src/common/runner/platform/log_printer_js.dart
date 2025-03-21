import 'dart:js_interop';

import 'package:logging/logging.dart' show Level, LogRecord;
import 'package:web/web.dart';
import 'log_printer_interface.dart';

ILogPrinter mapRecord(LogRecord record) => _LogRecordJS(
      record.level,
      record.message,
      record.loggerName,
      record.error,
      record.stackTrace,
      record.zone,
      record.object,
    );

final class _LogRecordJS extends ILogPrinter {
  _LogRecordJS(
    super.level,
    super.message,
    super.loggerName, [
    super.error,
    super.stackTrace,
    super.zone,
    super.object,
  ]);

  @override
  void print() {
    final trace = StringBuffer();
    trace.write(this);
    final console = const WebConsole();
    if (isError) {
      final validError = errorObj;
      if (validError != null) {
        trace
          ..writeln('\nDetails:\n')
          ..writeln(strColorWrapper(validError.toString()));

        if (stackTrace != null) {
          trace.writeln(stackTrace);
        }
      } else {
        trace.writeln('Without details');
      }
      console.error(trace.toString());
    } else {
      trace.write(strColorWrapper(message));
      if (level == Level.INFO) {
        console.info(trace.toString());
      } else if (level == Level.WARNING) {
        console.warn(trace.toString());
      } else {
        console.log(trace.toString());
      }
    }
  }
}

class WebConsole {
  const WebConsole();

  void error(String str) => console.error(str.toJS);

  void info(String str) => console.info(str.toJS);

  void log(String str) => console.log(str.toJS);

  void warn(String str) => console.warn(str.toJS);
}
