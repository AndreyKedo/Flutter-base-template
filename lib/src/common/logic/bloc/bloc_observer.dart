import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

class AppBlocObserver extends BlocObserver {
  final Logger logger;

  const AppBlocObserver(this.logger);

  @override
  void onCreate(BlocBase bloc) {
    assert(() {
      logger.info('${bloc.runtimeType} is created!');
      return true;
    }());
    super.onCreate(bloc);
  }

  @override
  void onClose(BlocBase bloc) {
    assert(() {
      logger.info('${bloc.runtimeType} is closed!');
      return true;
    }());
    super.onClose(bloc);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    assert(() {
      logger.severe('Unhandled Exception by ${bloc.runtimeType}', error, stackTrace);
      return true;
    }());
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    assert(() {
      logger.info('${bloc.runtimeType} event ${event.runtimeType} sended');
      return true;
    }());
    super.onEvent(bloc, event);
  }
}
