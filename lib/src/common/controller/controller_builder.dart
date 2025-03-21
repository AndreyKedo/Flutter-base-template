import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:starter_template/src/common/controller/controller_provider.dart';

/// Builds a [Widget] when given a concrete value of a [ValueListenable<T>].
typedef ValueWidgetBuilder<State> = Widget Function(BuildContext context, State state);

final class ControllerBuilder<Controller extends ValueListenable<State>, State extends Object> extends StatelessWidget {
  const ControllerBuilder({
    required this.builder,
    super.key,
    this.listenable,
  });

  final Controller? listenable;
  final ValueWidgetBuilder<State> builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<State>(
        valueListenable: listenable ?? context.controllerOf<Controller>(),
        builder: (context, value, child) => builder(context, value),
      );
}
