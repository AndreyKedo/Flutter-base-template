import 'package:flutter/foundation.dart' show kDebugMode;

typedef Flavor = String;

sealed class EnvironmentConfig {
  static const Flavor kFlavor = String.fromEnvironment('FLAVOR');

  static const kDebug = kDebugMode;
}

extension FlavorX on Flavor {
  bool get production => this == 'PROD';
  bool get beta => this == 'BETA';
  bool get develop => this == 'DEV';
}
