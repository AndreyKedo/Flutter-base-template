import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:starter_template/core/environment.dart';

/// Переопределение поведения HTTP для приложения
class AppHttpOverrides(
  final ValueGetter<String> userAgentResolver, {
  final Map<String, String>? systemProxyEnvironment,
}) extends HttpOverrides {
  /// Применить переопределения.
  factory ensure({
    required ValueGetter<String> userAgentResolver,
    Map<String, String>? systemProxyEnvironment,
  }) => HttpOverrides.global = AppHttpOverrides(userAgentResolver, systemProxyEnvironment: systemProxyEnvironment);

  static AppHttpOverrides get instance => HttpOverrides.current as AppHttpOverrides;

  late final userAgent = userAgentResolver();

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    final credentials = Environment.current.httpCredentials;
    client.authenticate = (Uri url, String scheme, String? realm) {
      if (scheme.toLowerCase() == 'basic') {
        client.addCredentials(url, realm ?? '', credentials);
        return .syncValue(true);
      }
      return .syncValue(false);
    };

    client.userAgent = userAgent;

    if (systemProxyEnvironment != null) {
      client.findProxy = (url) => HttpClient.findProxyFromEnvironment(url, environment: systemProxyEnvironment);
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }
}
