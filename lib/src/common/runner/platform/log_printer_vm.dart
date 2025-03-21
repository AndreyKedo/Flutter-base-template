import 'dart:developer';
import 'dart:io';

import 'package:logging/logging.dart' show LogRecord;

import 'log_printer_interface.dart';

ILogPrinter mapRecord(LogRecord record) => _LogRecordVM(
      record.level,
      record.message,
      record.loggerName,
      record.error,
      record.stackTrace,
      record.zone,
      record.object,
    );

final class _LogRecordVM extends ILogPrinter {
  _LogRecordVM(
    super.level,
    super.message,
    super.loggerName, [
    super.error,
    super.stackTrace,
    super.zone,
    super.object,
  ]);

  @override
  String strColorWrapper(String src) {
    if (Platform.isIOS) return src;
    return super.strColorWrapper(src);
  }

  @override
  void print() {
    log(
      toString(),
      name: loggerName,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level.value,
      zone: zone,
      error: errorObj,
      stackTrace: stackTrace,
    );
  }
}
