/*
* runner.dart
* Base application runner implementation. 
* Contains capturing of initialization metrics  and  exception handler.
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'dart:async';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:logging/logging.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'dart:developer';

import 'logger_printer.dart';
export 'package:flutter/foundation.dart' show Factory;

abstract class IRunner<DS extends IDependenciesStorage> {
  Factory<DS>? _$initializeDependency;

  FutureOr<Factory<DS>> initialization();

  void onAppRun(Factory<DS> factoryDependency);
  void onLoading() {}
  void onError(Object error, StackTrace stackTrace) {}

  abstract final Logger log;

  void run() async {
    hierarchicalLoggingEnabled = true;
    log.level = Level.OFF;
    assert(() {
      log.level = Level.ALL;
      log.onRecord.map(LogRecordPrinter.map).listen(LogRecordPrinter.write);
      return true;
    }());
    final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    onLoading();
    final stopwatch = Stopwatch()..start();
    final flow = Flow.begin();
    try {
      _$initializeDependency ??= await Timeline.timeSync<FutureOr<Factory<DS>>>(
          'Initialization dependency', initialization,
          flow: Flow.step(flow.id));

      Timeline.timeSync('UI loading', () {
        onAppRun(_$initializeDependency!);
      }, flow: Flow.end(flow.id));
    } on Object catch (error, stackTrace) {
      assert(() {
        log.severe('Dependency init fail', error, stackTrace);
        return true;
      }());
      onError(error, stackTrace);
    } finally {
      stopwatch.stop();
      log.info('time to start ${stopwatch.elapsedMilliseconds} ms');
      binding.addPostFrameCallback((_) {
        binding.allowFirstFrame();
      });
      _$initializeDependency = null;
    }
  }
}
