import 'package:material_ui/material_ui.dart';
import 'package:starter_template/core/build_context_ext.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/feature/application/controller/initialization_controller.dart';
import 'package:starter_template/feature/application/di/app_dep_container.dart';

/// Координатор инициализации приложения.
///
/// Отвечает за отображение splash заставки или экрана ошибки инициализации
final class const InitializationCoordinator({
  required final Widget child,
  required final Widget splashScreen,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final initializationController = context.watchOf<InitializationController>();

    return AnimatedSwitcher(
      duration: Durations.medium3,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: switch (initializationController.state) {
        // Инициализация прошла успешно
        InitializationIdleState(container: final container) => DependencyContainer.wrap<ApplicationDependency>(
          create: (context) => container,
          child: child,
        ),
        InitializationInitialState() => splashScreen,
        InitializationErrorState() => splashScreen,
      },
    );
  }
}
