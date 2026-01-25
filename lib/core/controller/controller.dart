import 'package:flutter/foundation.dart';
import 'controller_mixin.dart';

abstract class StateController<State extends Object> extends ValueNotifier<State> with ControllerMixin {
  StateController(super._value);

  @protected
  @override
  set value(State newValue) => super.value = newValue;
}
