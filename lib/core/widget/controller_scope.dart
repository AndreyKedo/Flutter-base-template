import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension ControllerScopeBuildContextExtension on BuildContext {
  C controllerOf<C extends Listenable>({bool listen = false}) => ControllerScope.of<C>(this, listen: listen);
}

class ControllerScope<C extends Listenable> extends InheritedWidget {
  ControllerScope({required C Function(BuildContext context) create, Widget? child, bool lazy = true, super.key})
    : _dependency = _ControllerDependencyCreate<C>(create: create, lazy: lazy),
      super(child: child ?? const SizedBox.shrink());

  ControllerScope.value({required C controller, Widget? child, super.key})
    : _dependency = _ControllerDependencyValue<C>(controller: controller),
      super(child: child ?? const SizedBox.shrink());

  final _ControllerDependency<C> _dependency;

  static C? maybeOf<C extends Listenable>(BuildContext context, {bool listen = false}) {
    final element = context.getElementForInheritedWidgetOfExactType<ControllerScope<C>>();
    if (listen && element != null) context.dependOnInheritedElement(element);
    return element is ControllerScopeElement<C> ? element.controller : null;
  }

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a ControllerScope of the exact type',
    'out_of_scope',
  );

  static C of<C extends Listenable>(BuildContext context, {bool listen = false}) =>
      maybeOf<C>(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant ControllerScope oldWidget) => _dependency != oldWidget._dependency;

  @override
  InheritedElement createElement() => ControllerScopeElement<C>(this);
}

final class ControllerScopeElement<C extends Listenable> extends InheritedElement {
  ControllerScopeElement(ControllerScope<C> super.widget);

  @nonVirtual
  _ControllerDependency<C> get _dependency => (widget as ControllerScope<C>)._dependency;

  @nonVirtual
  C? _controller;

  @nonVirtual
  C get controller => _controller ??= _initController();

  @nonVirtual
  Object? _state;

  @nonVirtual
  bool _dirty = false;

  @nonVirtual
  bool _subscribed = false;

  @nonVirtual
  C _initController() {
    if (_controller != null) {
      assert(false, 'Controller already initialized');
      return _controller!;
    }
    final c = switch (_dependency) {
      final _ControllerDependencyCreate<C> d => d.create(this),
      final _ControllerDependencyValue<C> d => d.controller,
    };
    return c;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    if (_controller == null) {
      switch (_dependency) {
        case final _ControllerDependencyCreate<C> d:
          if (!d.lazy) _controller = d.create(this);
          break;
        case final _ControllerDependencyValue<C> d:
          _controller = d.controller;
          break;
      }
    }
    super.mount(parent, newSlot);
  }

  @override
  @mustCallSuper
  void update(covariant ControllerScope<C> newWidget) {
    final oldDependency = _dependency;
    final newDependency = newWidget._dependency;
    if (!identical(oldDependency, newDependency)) {
      switch (newDependency) {
        case final _ControllerDependencyCreate<C> d:
          assert(oldDependency is _ControllerDependencyCreate<C>, 'Cannot change scope type');
          if (_controller == null && (!d.lazy || _subscribed)) {
            _controller = d.create(this);
          }
        case final _ControllerDependencyValue<C> d:
          assert(oldDependency is _ControllerDependencyValue<C>, 'Cannot change scope type');
          final newController = d.controller;
          if (!identical(_controller, newController)) {
            _controller?.removeListener(_handleUpdate);
            _controller = newController;
          }
      }
      if (_subscribed) _controller?.addListener(_handleUpdate);
    }
    super.update(newWidget);
  }

  @mustCallSuper
  void _handleUpdate() {
    final newState = switch (_controller) {
      final ValueListenable<Object?> c => c.value,
      _ => null,
    };
    if (identical(_state, newState)) return;
    _state = newState;
    _dirty = true;
    markNeedsBuild();
  }

  @override
  @mustCallSuper
  void updateDependencies(Element dependent, Object? aspect) {
    if (!_subscribed) {
      _subscribed = true;
      controller.addListener(_handleUpdate);
    }
    super.updateDependencies(dependent, aspect);
  }

  @override
  @mustCallSuper
  void notifyClients(covariant ControllerScope<C> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  @mustCallSuper
  void unmount() {
    final listenable = _controller;
    listenable?.removeListener(_handleUpdate);
    _subscribed = false;

    if (_dependency is _ControllerDependencyCreate<C> && listenable is ChangeNotifier) listenable.dispose();
    super.unmount();
  }

  @override
  Widget build() {
    if (_dirty && _subscribed) notifyClients(widget as ControllerScope<C>);
    return super.build();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('Controller', objectRuntimeType(_controller, 'Observable controller')));
    if (_controller case final ValueNotifier valueNotifier) {
      properties.add(StringProperty('State', objectRuntimeType(valueNotifier.value, 'unreachable')));
    }
    super.debugFillProperties(properties);
  }
}

@immutable
sealed class _ControllerDependency<C extends Listenable> {
  const _ControllerDependency();
}

final class _ControllerDependencyCreate<C extends Listenable> extends _ControllerDependency<C> {
  const _ControllerDependencyCreate({required this.create, required this.lazy});

  final C Function(BuildContext context) create;

  final bool lazy;

  @override
  int get hashCode => create.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is _ControllerDependencyCreate;
}

final class _ControllerDependencyValue<C extends Listenable> extends _ControllerDependency<C> {
  const _ControllerDependencyValue({required this.controller});

  final C controller;

  @override
  int get hashCode => controller.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ControllerDependencyValue && identical(controller, other.controller);
}
