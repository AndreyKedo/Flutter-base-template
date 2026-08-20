import 'package:material_ui/material_ui.dart';
import 'package:starter_template/feature/application/controller/initialization_controller.dart';
import 'package:starter_template/feature/application/di/app_dep_builder.dart';
import 'package:starter_template/feature/application/widget/application.dart';

void main() {
  runApp(
    ApplicationWidget(
      create: () {
        final controller = InitializationController(AppDependencyBuilder());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.initialize();
        });
        return controller;
      },
    ),
  );
}
