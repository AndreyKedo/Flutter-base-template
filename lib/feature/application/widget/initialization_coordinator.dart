import 'package:flutter/material.dart';
import 'package:starter_template/core/build_context_ext.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/feature/application/controller/initialization_controller.dart';
import 'package:starter_template/feature/application/di/app_dep_container.dart';

/// Координатор инициализации приложения.
///
/// Отвечает за отображение splash заставки или экрана ошибки инициализации
final class InitializationCoordinator extends StatelessWidget {
  const InitializationCoordinator({required this.child, required this.splashScreen, super.key});

  final Widget child;
  final Widget splashScreen;

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
