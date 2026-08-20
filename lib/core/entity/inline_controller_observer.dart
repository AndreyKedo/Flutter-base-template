import 'package:control/control.dart';
import 'package:flutter/foundation.dart';

typedef HandleControllerErrorCallback = void Function(Controller controller, Object error, StackTrace stackTrace);

class InlineControllerObserver({
  ValueSetter<Controller>? didCreate,
  ValueSetter<Controller>? didDispose,
  HandleControllerErrorCallback? didError,
}) implements IControllerObserver {
  @protected
  final ValueSetter<Controller>? onCreateCallback = didCreate;

  @protected
  final ValueSetter<Controller>? onDisposeCallback = didDispose;

  @protected
  final HandleControllerErrorCallback? onErrorCallback = didError;

  @override
  void onCreate(Controller controller) {
    onCreateCallback?.call(controller);
  }

  @override
  void onDispose(Controller controller) {
    onDisposeCallback?.call(controller);
  }

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    onErrorCallback?.call(controller, error, stackTrace);
  }

  @override
  void onHandler(HandlerContext context) {}

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {}
}
