import 'dart:async';

import 'package:flutter/material.dart';

import 'scope.dart';

typedef DependencyFactory<Storage extends IDependenciesStorage> = Storage Function(BuildContext context);

// ignore: one_member_abstracts
abstract class IDependenciesStorage {
  FutureOr<void> close();
}

abstract base class DependenciesScope<Storage extends IDependenciesStorage> extends Scope {
  final DependencyFactory<Storage> create;

  const DependenciesScope._({
    required super.child,
    required this.create,
    super.key,
  });

  const factory DependenciesScope({
    required DependencyFactory<Storage> create,
    required Widget child,
    Key key,
  }) = _DependenciesScopeFactory<Storage>;

  /// Do not use this
  factory DependenciesScope.value({
    required Storage value,
    required Widget child,
    Key key,
  }) = _DependenciesScopeValue<Storage>;

  static Storage of<Storage extends IDependenciesStorage>(
    BuildContext context, {
    bool listen = false,
  }) =>
      Scope.delegateOf<DependenciesScope<Storage>, _DependenciesScopeDelegate<Storage>>(
        context,
        listen: listen,
      ).storage;

  @override
  ScopeDelegate<DependenciesScope<Storage>> createDelegate() => _DependenciesScopeDelegate<Storage>();
}

final class _DependenciesScopeDelegate<Storage extends IDependenciesStorage>
    extends ScopeDelegate<DependenciesScope<Storage>> {
  late final Storage storage = widget.create(context);

  @override
  void dispose() {
    if (widget is _DependenciesScopeFactory<Storage>) {
      storage.close();
    }

    super.dispose();
  }
}

final class _DependenciesScopeFactory<Storage extends IDependenciesStorage> extends DependenciesScope<Storage> {
  const _DependenciesScopeFactory({
    required super.create,
    required super.child,
    super.key,
  }) : super._();
}

final class _DependenciesScopeValue<Storage extends IDependenciesStorage> extends DependenciesScope<Storage> {
  _DependenciesScopeValue({
    required Storage value,
    required super.child,
    super.key,
  }) : super._(
          create: (_) => value,
        );
}
