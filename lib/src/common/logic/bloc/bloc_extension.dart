import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';
import 'package:starter_template/src/feature/app/runner/runner.dart' as runner show logger;

///Расширяет возможности BLoC
///
///Позволяет обрабатывать ошибки и расширяет возможности управления состоянием
mixin BlocExtension<Event, State> on Bloc<Event, State> {
  void logDebug(String message) => logger.info('[DEBUG][$runtimeType] $message');
  void logError(Object error, StackTrace stackTrace) {
    assert(() {
      logger.severe('Exception by $runtimeType', error, stackTrace);
      return true;
    }());
  }

  ///Log exception
  Logger get logger => runner.logger;
}
