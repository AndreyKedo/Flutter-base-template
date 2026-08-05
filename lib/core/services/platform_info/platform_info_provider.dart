/// Синглтон-провайдер, синхронно предоставляющий информацию о приложении и устройстве.
///
/// Обязательно вызовете [PlatformInfoProvider.initialize] перед тем как использовать.
abstract class PlatformInfoProvider {
  Package get package;
  Device get device;
}

/// Хранит информацию о пакете приложения.
class Package {
  const Package({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  final String appName;

  /// Имя пакета.
  final String packageName;

  /// Версия приложения.
  final String version;

  /// Номер сборки.
  final String buildNumber;

  @override
  String toString() {
    return 'Package(\n'
        '\tappName: $appName\n'
        '\tpackageName: $packageName\n'
        '\tversion: $version\n'
        '\tbuildNumber: $buildNumber\n'
        ')';
  }
}

/// Базовый класс для метаданных устройства. Используется для унификации доступа.
class Device {
  Device({
    required this.model,
    required this.os,
    required this.osVersion,
    required this.uniqueIdentifier,
  });

  final String uniqueIdentifier;

  final String model;

  final String os;

  final String osVersion;

  @override
  String toString() {
    return 'Device(\n'
        '\tuniqueIdentifier: $uniqueIdentifier,\n'
        '\tmodel: $model\n'
        '\tos: $os\n'
        '\tosVersion: $osVersion\n'
        ')';
  }
}
