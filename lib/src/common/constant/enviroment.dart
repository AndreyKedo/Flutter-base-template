import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode, kProfileMode;

typedef Flavor = String;

/// {@template enviroment}
/// EnvironmentConfig is general config of project.
/// {@endtemplate}
sealed class EnvironmentConfig {
  /// Getting currently [EnvironmentType].
  ///
  /// Available types [EnvironmentType.dev], [EnvironmentType.qa], [EnvironmentType.prod],
  static final EnvironmentType env = EnvironmentType.fromValue(const String.fromEnvironment('ENVIRONMENT'));

  /// Returned true is if currently running app is debug mode.
  static const kDebug = kDebugMode;
}

/// {@template enviroment_types}
/// Application EnvironmentType flavor.
/// {@endtemplate}
enum EnvironmentType implements Comparable<EnvironmentType> {
  /// Develop.
  dev('dev'),

  /// QA or demo or beta, minor.
  qa('qa'),

  /// Production, combat version
  prod('prod');

  /// {@macro enviroment_types}
  const EnvironmentType(this.value);

  /// Parse env from string value
  static EnvironmentType fromValue(String? value) => switch (value?.trim().toLowerCase()) {
        'dev' => dev,
        'qa' => qa,
        'prod' => prod,
        _ when kReleaseMode => prod,
        _ when kProfileMode => qa,
        _ => dev
      };

  final String value;

  bool get isDev => this == dev;
  bool get isQa => this == qa;
  bool get isProd => this == prod;

  @override
  int compareTo(EnvironmentType other) => index.compareTo(other.index);

  @override
  String toString() => value.toUpperCase();
}
