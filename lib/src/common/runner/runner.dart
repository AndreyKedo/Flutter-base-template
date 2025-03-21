/*
* runner.dart
* Base application runner implementation. 
* Contains capturing of initialization metrics  and  exception handler.
* Dashkevich Andrey <dashkevich@ittest-team.ru>, 17 January 2024
*/

import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:logging/logging.dart';

import 'logger_printer.dart';

export 'package:flutter/foundation.dart' show Factory;

abstract interface class RunnerInitialization<DS> {
  void initializeAndRun();
  Logger createRunnerLogger();
  Future<DS> initialization();

  void onApp(DS dependency);

  void onError(Object error, StackTrace stackTrace);
}

abstract class Runner<DS> implements RunnerInitialization<DS> {
  static Logger logger = Logger.root;

  @override
  void initializeAndRun() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.deferFirstFrame();

    logger = createRunnerLogger();

    final rootLogger = Logger.root;
    assert(() {
      rootLogger.level = Level.ALL;
      return true;
    }());
    rootLogger.onRecord.map(LogRecordPrinter.map).listen(LogRecordPrinter.write);

    final stopwatch = Stopwatch()..start();
    final flow = Flow.begin();

    Future<void> initialize() async {
      try {
        final dependency = await Timeline.timeSync<Future<DS>>(
          'Initialization dependency',
          () => initialization(),
          flow: Flow.end(flow.id),
        );

        onApp(dependency);
      } catch (error, stackTrace) {
        onError(
          error,
          stackTrace,
        );
        rethrow;
      } finally {
        stopwatch.stop();
        binding.allowFirstFrame();

        logger.info('Time to start ${stopwatch.elapsedMilliseconds} ms');
      }
    }

    await initialize();
  }
}
