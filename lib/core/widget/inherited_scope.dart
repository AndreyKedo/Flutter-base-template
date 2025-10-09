import 'package:flutter/widgets.dart';

typedef ModelFactory<Model> = Model Function(BuildContext context);

extension InheritedScopeContextExtension on BuildContext {
  T getScoped<T>() => InheritedScope.of<T>(this);
}

class InheritedScope<Model> extends InheritedWidget {
  /// Создавайте экземпляр и избавляйтесь от него при необходимости.
  ///
  /// **ПЛОХО**
  /// ```
  /// final value = Model();
  /// InheritedScope(
  ///   create: (BuildContext context) => value // this is potential memory leak
  /// );
  /// ```
  ///
  /// **ХОРОШО**
  /// ```
  /// InheritedScope(
  ///   create: (BuildContext context) => Model(),
  ///   dispose: (Model object) => object.dispose(),
  /// );
  /// ```
  InheritedScope({
    required Model Function(BuildContext context) create,
    ValueSetter<Model>? dispose,
    Widget? child,
    bool lazy = true,
    super.key,
  }) : _dependency = _ScopedModelCreate<Model>(create: create, dispose: dispose, lazy: lazy),
       super(child: child ?? const SizedBox.shrink());

  /// Provide already created object.
  InheritedScope.value({required Model value, Widget? child, super.key})
    : _dependency = _ScopedModelValue<Model>(value),
      super(child: child ?? const SizedBox.shrink());

  final _ScopedModel<Model> _dependency;

  /// Состояние ближайшего экземпляра этого класса,
  /// охватывающего заданный контекст, если таковой имеется.
  /// Например, `InheritedScope.maybeOf<Model>(context)`.
  static S? maybeOf<S>(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InheritedScope<S>>();
    return element is InheritedScopeElement<S> ? element.storage : null;
  }

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a InheritedScope of the exact type',
    'out_of_scope',
  );

  /// Состояние ближайшего экземпляра этого класса,
  /// охватывающего заданный контекст.
  /// Например, `InheritedScope.of<Model>(context)`.
  static C of<C>(BuildContext context) => maybeOf<C>(context) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant InheritedScope oldWidget) => false;

  @override
  InheritedElement createElement() => InheritedScopeElement<Model>(this);
}

final class InheritedScopeElement<Model> extends InheritedElement {
  InheritedScopeElement(InheritedScope<Model> super.widget);

  _ScopedModel<Model> get _dependency => (widget as InheritedScope<Model>)._dependency;

  Model? _model;

  Model get storage => _model ??= _initStorage();

  bool _dirty = false;

  Model _initStorage() {
    if (_model != null) {
      assert(false, 'Storage already initialized');
      return _model!;
    }
    return switch (_dependency) {
      final _ScopedModelCreate<Model> d => d.create(this),
      final _ScopedModelValue<Model> d => d.model,
    };
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    if (_model == null) {
      switch (_dependency) {
        case final _ScopedModelCreate<Model> d:
          if (!d.lazy) _model = d.create(this);
          break;
        case final _ScopedModelValue<Model> d:
          _model = d.model;
          break;
      }
    }
    super.mount(parent, newSlot);
  }

  @override
  @mustCallSuper
  void update(covariant InheritedScope<Model> newWidget) {
    final oldDependency = _dependency;
    final newDependency = newWidget._dependency;
    if (!identical(oldDependency, newDependency)) {
      switch (newDependency) {
        case final _ScopedModelCreate<Model> d:
          assert(oldDependency is _ScopedModelCreate<Model>, 'Cannot change scope type');
          if (_model == null && !d.lazy) {
            _model = d.create(this);
          }
        case final _ScopedModelValue<Model> d:
          assert(oldDependency is _ScopedModelValue<Model>, 'Cannot change scope type');
          final newStorage = d.model;
          if (!identical(_model, newStorage)) {
            _model = newStorage;
          }
      }
    }
    super.update(newWidget);
  }

  @override
  @mustCallSuper
  void notifyClients(covariant InheritedScope<Model> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  @mustCallSuper
  void unmount() {
    if (_dependency case final _ScopedModelCreate<Model> create) {
      final model = _model;
      if (model == null) return;

      create.dispose?.call(model);
      _model = null;
    }
    super.unmount();
  }

  @override
  Widget build() {
    if (_dirty) notifyClients(widget as InheritedScope<Model>);
    return super.build();
  }
}

sealed class _ScopedModel<Model> {
  const _ScopedModel();
}

@immutable
final class _ScopedModelCreate<Model> extends _ScopedModel<Model> {
  const _ScopedModelCreate({required this.create, required this.dispose, required this.lazy});

  final Model Function(BuildContext context) create;
  final ValueSetter<Model>? dispose;

  final bool lazy;

  @override
  int get hashCode => create.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ScopedModelCreate && identical(create, other.create);
}

@immutable
final class _ScopedModelValue<Model> extends _ScopedModel<Model> {
  const _ScopedModelValue(this.model);

  final Model model;

  @override
  int get hashCode => model.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ScopedModelValue && identical(model, other.model);
}
