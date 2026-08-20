import 'package:control/control.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/feature/application/di/app_dep_builder.dart';
import 'package:starter_template/feature/application/di/app_dep_container.dart';

part 'initialization_state.dart';

/// Контроллер отвечает за инициализацию приложения и его зависимостей.
final class InitializationController(
  final DependencyBuilder<ApplicationDependency, AppDependencyContext> dependencyBuilder,
) extends StateController<InitializationState> with DroppableControllerHandler {
  this : super(initialState: const InitializationInitialState());

  Future<void> initialize() => handle(
    () async {
      final result = await dependencyBuilder.build();

      setState(InitializationIdleState(container: result));
    },
    error: (error, stackTrace) async {
      setState(InitializationErrorState(error: error, stackTrace: stackTrace));
    },
  );
}
