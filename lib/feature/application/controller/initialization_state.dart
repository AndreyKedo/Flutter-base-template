part of 'initialization_controller.dart';

sealed class const InitializationState();

class const InitializationInitialState() extends InitializationState;

class const InitializationIdleState({required final ApplicationDependency container}) extends InitializationState;

class const InitializationErrorState({required final Object error, required final StackTrace stackTrace})
    extends InitializationState;
