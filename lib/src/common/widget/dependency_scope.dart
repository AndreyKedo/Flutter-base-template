import 'package:flutter/material.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'scope.dart';

class DependenciesScope<Storage extends IDependenciesStorage> extends Scope {
  static const DelegateAccess<_DependenciesScopeDelegate> _delegateOf =
      Scope.delegateOf<DependenciesScope, _DependenciesScopeDelegate>;

  final Storage Function(BuildContext context) create;

  const DependenciesScope({
    required this.create,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static Storage of<Storage>(BuildContext context, {bool listen = false}) =>
      _delegateOf(context, listen: listen).storage as Storage;

  @override
  ScopeDelegate<DependenciesScope> createDelegate() => _DependenciesScopeDelegate();
}

class _DependenciesScopeDelegate<Storage extends IDependenciesStorage> extends ScopeDelegate<DependenciesScope> {
  late final IDependenciesStorage storage = widget.create(context);

  @override
  void dispose() {
    storage.close();
    super.dispose();
  }
}
