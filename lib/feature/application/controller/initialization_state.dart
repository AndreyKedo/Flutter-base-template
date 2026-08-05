part of 'initialization_controller.dart';

sealed class InitializationState {
  const InitializationState();
}

class InitializationInitialState extends InitializationState {
  const InitializationInitialState();
}

class InitializationIdleState extends InitializationState {
  const InitializationIdleState({required this.container});

  final ApplicationDependency container;
}

class InitializationErrorState extends InitializationState {
  final Object error;
  final StackTrace stackTrace;

  const InitializationErrorState({required this.error, required this.stackTrace});
}
