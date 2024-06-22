import 'package:flutter/foundation.dart' show kDebugMode;

/// {@template enviroment}
/// EnvironmentConfig is general config of project.
/// {@endtemplate}
sealed class EnvironmentConfig {
  /// Getting currently [EnvironmentType].
  ///
  /// Available types [EnvironmentType.dev], [EnvironmentType.qa], [EnvironmentType.prod],
  static const EnvironmentType env = String.fromEnvironment('ENVIRONMENT') as EnvironmentType;

  /// Returned true is if currently running app is debug mode.
  static const kDebug = kDebugMode;
}

extension type const EnvironmentType(String value) implements String {
  static const EnvironmentType dev = EnvironmentType('DEV');
  static const EnvironmentType qa = EnvironmentType('QA');
  static const EnvironmentType prod = EnvironmentType('PROD');

  bool get isProduction => this == prod;
  bool get isQA => this == qa;
  bool get isDevelop => this == dev;
}
