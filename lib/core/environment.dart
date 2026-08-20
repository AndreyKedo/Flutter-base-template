import 'dart:io';

import 'package:flutter/services.dart';

enum Flavor {
  staging,
  production;

  static Flavor get current => switch (appFlavor) {
    'staging' => Flavor.staging,
    'production' => Flavor.production,
    _ => Flavor.staging,
  };
}

abstract base class const Environment() {
  static Environment get current => const DartDefineEnvironment();

  Uri get host;

  HttpClientCredentials get httpCredentials;

  /// Название защищённого файла shared preferences.
  ///
  /// **При изменение наименование сделайте тоже самое в** [backup_rules](./android/app/src/main/res/xml/backup_rules.xml)
  String get secureSharedPrefName;

  String get databaseName;
}

final class const DartDefineEnvironment() extends Environment {
  @override
  Uri get host => Uri.parse(const String.fromEnvironment('HOST'));

  @override
  String get databaseName => 'flutter_base';

  @override
  HttpClientCredentials get httpCredentials {
    const raw = String.fromEnvironment('HTTP_AUTH');
    final [login, password] = raw.split(':');
    return HttpClientBasicCredentials(login, password);
  }

  @override
  String get secureSharedPrefName => 'flutter_base_private';

  @override
  String toString() =>
      'DartDefineEnvironment->\n'
      '\thost: $host\n'
      '\thttp_credentials: ${const String.fromEnvironment('HTTP_AUTH')}';
}
