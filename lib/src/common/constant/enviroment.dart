import 'package:flutter/foundation.dart' as framework;
import 'package:flutter/services.dart' as services;

extension type const EnvironmentType(String value) implements String {
  static const EnvironmentType dev = EnvironmentType('DEV');
  static const EnvironmentType qa = EnvironmentType('QA');
  static const EnvironmentType prod = EnvironmentType('PROD');

  bool get isProduction => this == prod;
  bool get isQA => this == qa;
  bool get isDevelop => this == dev;
}

/// EnvironmentConfig is general config of project.
sealed class EnvironmentConfig {
  /// Getting currently [EnvironmentType].
  ///
  /// Available types [EnvironmentType.dev], [EnvironmentType.qa], [EnvironmentType.prod],
  static const EnvironmentType env = (services.appFlavor ?? String.fromEnvironment('FLAVOR')) as EnvironmentType;

  /// Returned true is if currently running app is debug mode.
  static const kDebug = framework.kDebugMode;

  static const kIsWeb = framework.kIsWeb || framework.kIsWasm;
}
