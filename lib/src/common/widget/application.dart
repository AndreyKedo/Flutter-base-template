import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'dependency_scope.dart';

@immutable
abstract class AppWrapper<DependencyStorage extends IDependenciesStorage> extends StatelessWidget {
  const AppWrapper({
    super.key,
    required this.dependencyFactory,
  });

  final Factory<DependencyStorage> dependencyFactory;

  @protected
  Widget buildApp(DependencyStorage storage);

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      create: (_) => dependencyFactory.constructor(),
      child: Builder(
        builder: (context) => buildApp(DependenciesScope.of<DependencyStorage>(context)),
      ),
    );
  }
}
