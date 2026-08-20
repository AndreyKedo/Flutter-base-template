/// {@template user_agent_builder}
/// Синхронный builder для формирования строго форматированной User-Agent строки.
///
/// Пример использования:
/// ```dart
/// final userAgent = UserAgentBuilder()
///   ..appName('MyApp')
///   ..version('1.0.0')
///   ..deviceModel('iPhone10,1')
///   ..osName('iOS')
///   ..osVersion('15.0')
///   .build();
/// ```
///
/// Результат: "MyApp/1.0.0 (iPhone10,1; iOS 15.0)"
/// {@endtemplate}
class UserAgentBuilder() {
  /// {@macro user_agent_builder}
  String? _appName;
  String? _version;
  String? _deviceModel;
  String? _osName;
  String? _osVersion;

  /// Устанавливает название приложения.
  UserAgentBuilder appName(String value) {
    _appName = value;
    return this;
  }

  /// Устанавливает версию приложения.
  UserAgentBuilder version(String value) {
    _version = value;
    return this;
  }

  /// Устанавливает модель устройства.
  UserAgentBuilder deviceModel(String value) {
    _deviceModel = value;
    return this;
  }

  /// Устанавливает название операционной системы.
  UserAgentBuilder osName(String value) {
    _osName = value;
    return this;
  }

  /// Устанавливает версию операционной системы.
  UserAgentBuilder osVersion(String value) {
    _osVersion = value;
    return this;
  }

  /// Строит и возвращает User-Agent строку.
  ///
  /// Формат: `$appName/$version ($deviceModel; $osName $osVersion)`
  /// Все компоненты проходят санитаризацию для удаления нежелательных символов.
  ///
  /// @throws [StateError] если какие-либо обязательные поля не установлены.
  String build() {
    final appName = _sanitize(_appName);
    final version = _sanitize(_version);
    final deviceModel = _sanitize(_deviceModel);
    final osName = _sanitize(_osName);
    final osVersion = _sanitize(_osVersion);

    if (appName.isEmpty || version.isEmpty || deviceModel.isEmpty || osName.isEmpty || osVersion.isEmpty) {
      throw StateError(
        'Все поля должны быть установлены: appName, version, deviceModel, osName, osVersion',
      );
    }

    return '$appName/$version ($deviceModel; $osName $osVersion)';
  }

  /// Очищает строку от символов, которые могут нарушить формат User-Agent.
  String _sanitize(String? input) {
    if (input == null) return '';
    return input.replaceAll(RegExp(r'[;()]'), '').trim();
  }
}
