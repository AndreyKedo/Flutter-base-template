import 'package:flutter/widgets.dart';
import 'package:starter_template/src/common/extensions/build_context.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'dependency_scope.dart';

typedef DependencyFactory<DependencyStorage extends IDependenciesStorage> = DependencyStorage Function();

@immutable
abstract class AppWrapper<DependencyStorage extends IDependenciesStorage> extends StatelessWidget {
  const AppWrapper({
    super.key,
    required this.dependencyFactory,
  });

  final DependencyFactory<DependencyStorage> dependencyFactory;

  @protected
  Widget buildApp(DependencyStorage storage);

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      create: (_) => dependencyFactory(),
      child: Builder(
        builder: (context) => buildApp(context.dependency<DependencyStorage>()),
      ),
    );
  }
}
