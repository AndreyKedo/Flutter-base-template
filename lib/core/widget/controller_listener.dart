import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'controller_scope.dart';

typedef ControllerWidgetListener<S> = void Function(BuildContext context, S state);

final class ControllerListener<Controller extends ValueListenable<S>, S extends Object> extends StatelessWidget {
  const ControllerListener({super.key, required this.child, required this.listener, this.listenable});

  final Widget child;
  final ControllerWidgetListener<S> listener;
  final Controller? listenable;

  @override
  Widget build(BuildContext context) => child;

  @override
  StatelessElement createElement() => ControllerListenerElement<Controller, S>(this, listenable, listener);
}

class ControllerListenerElement<Controller extends ValueListenable<State>, State extends Object>
    extends StatelessElement {
  ControllerListenerElement(super.widget, this.listenable, this.listener);

  Controller? listenable;
  ControllerWidgetListener<State> listener;

  Controller get controller => listenable ??= controllerOf<Controller>();

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    final cont = controller;

    cont.addListener(_listener);
  }

  @override
  void update(covariant ControllerListener<Controller, State> newWidget) {
    super.update(newWidget);

    final newListener = newWidget.listener;

    if (!identical(listener, newListener)) {
      updateListener(newListener);
    }

    final newListenable = newWidget.listenable;

    if (!identical(listenable, newListenable)) {
      if (listenable == null && newListenable != null) {
        controller.removeListener(_listener);
        listenable = newListenable;
        newListenable.addListener(_listener);
      } else if (listenable != null && newListenable == null) {
        listenable?.removeListener(_listener);
        listenable = null;
        controller.addListener(_listener);
      } else if (listenable != null && newListenable != null) {
        listenable?.removeListener(_listener);
        listenable = newListenable;
        newListenable.addListener(_listener);
      }
    }
  }

  @override
  void unmount() {
    final cont = controller;
    cont.removeListener(_listener);
    super.unmount();
  }

  void updateListener(ControllerWidgetListener<State> newListener) {
    controller.removeListener(_listener);
    listener = newListener;
    controller.addListener(_listener);
  }

  void _listener() {
    listener(this, controller.value);
  }
}
