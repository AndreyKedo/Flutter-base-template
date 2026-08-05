import 'package:starter_template/core/di.dart';
import 'package:starter_template/core/services/platform_info/platform_info_provider.dart';

abstract class ApplicationDependency extends DependencyContainer {
  PlatformInfoProvider get appInfoProvider;
}
