import 'package:starter_template/core/di.dart';

abstract class ApplicationDi extends DependencyContainer {}

final class ApplicationDiContainer extends ApplicationDi {
  ApplicationDiContainer._();

  factory ApplicationDiContainer.create() {
    return ApplicationDiContainer._();
  }
}
