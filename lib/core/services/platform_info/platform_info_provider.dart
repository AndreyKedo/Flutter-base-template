/// Синглтон-провайдер, синхронно предоставляющий информацию о приложении и устройстве.
///
/// Обязательно вызовете [PlatformInfoProvider.initialize] перед тем как использовать.
abstract class PlatformInfoProvider {
  Package get package;
  Device get device;
}

/// Хранит информацию о пакете приложения.
class const Package({
  required final String appName,
  required final String packageName,
  required final String version,
  required final String buildNumber,
}) {
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
class Device({
  required final String model,
  required final String os,
  required final String osVersion,
  required final String uniqueIdentifier,
}) {
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
