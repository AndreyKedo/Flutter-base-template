import 'dart:async';
import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails;
import 'package:flutter/widgets.dart' show Widget, WidgetsBinding, WidgetsFlutterBinding;
import 'package:logging/logging.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'dart:developer';

import 'logger_printer.dart';
import 'model/runner_config.dart';

export 'model/runner_config.dart';

typedef ShowWidget = void Function(Widget splash);
typedef DependencyFactory<Storage extends IDependenciesStorage> = Storage Function();

mixin IRunner {
  FutureOr<DependencyFactory?> initialization(RunnerConfig config) {
    return null;
  }

  void onAppRun(DependencyFactory? factoryDependency);
  void onLoading(ShowWidget show) {}
  void onError(Object error, StackTrace stackTrace, ShowWidget show) {}

  abstract final Logger log;

  void run([RunnerConfig config = const RunnerConfig()]) {
    hierarchicalLoggingEnabled = true;
    log.level = Level.OFF;
    assert(() {
      log.level = Level.ALL;
      log.onRecord.map((event) => CustomPrint(event)).listen(CustomPrint.write);

      FlutterError.onError = (FlutterErrorDetails error) {
        log.severe('Flutter error', error.toStringShort(), error.stack);
      };
      return true;
    }());
    final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
    void showWidget(Widget splash) {
      binding
        ..attachRootWidget(splash)
        ..scheduleForcedFrame();
    }

    onLoading(showWidget);
    runZonedGuarded(() async {
      final stopwatch = Stopwatch()..start();
      final flow = Flow.begin();
      Timeline.startSync('Initialization', flow: flow);
      try {
        final dependency = await initialization(config);
        onAppRun(dependency);
        Timeline.finishSync();
        Flow.end(flow.id);
      } on Object catch (error, stackTrace) {
        assert(() {
          log.severe('Dependency init fail', error, stackTrace);
          return true;
        }());
        rethrow;
      } finally {
        log.info('time to start ${stopwatch.elapsedMilliseconds} ms');
        stopwatch.stop();
      }
    }, (error, stack) {
      onError(error, stack, showWidget);
    });
  }
}
