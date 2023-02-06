import 'package:flutter/widgets.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'dependency_scope.dart';

typedef DependencyFactory<DependencyStorage extends IDependenciesStorage> = DependencyStorage Function();

abstract class AppWrapper<DependencyStorage extends IDependenciesStorage> extends StatelessWidget {
  const AppWrapper({
    super.key,
    required this.dependencyFactory,
  });

  final DependencyFactory<DependencyStorage> dependencyFactory;

  @override
  StatelessElement createElement() => _AppWrapperElement(this, dependencyFactory);
}

class _AppWrapperElement<DependencyStorage extends IDependenciesStorage> extends StatelessElement {
  _AppWrapperElement(super.widget, this.dependencyFactory);
  final DependencyFactory<DependencyStorage> dependencyFactory;
  @override
  Widget build() => DependenciesScope(create: (_) => dependencyFactory(), child: super.build());
}
