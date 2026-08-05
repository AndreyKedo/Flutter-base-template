import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:starter_template/core/services/platform_info/platform_info_provider.dart';
import 'package:unique_device_identifier/unique_device_identifier.dart';

class PlatformInfoProviderImpl implements PlatformInfoProvider {
  PlatformInfoProviderImpl({required this.package, required this.device});

  static Future<PlatformInfoProvider> ensureInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final uniquePlatformId = await UniqueDeviceIdentifier.getUniqueIdentifier();

    Never throwUnsupportedPlatform() => throw UnsupportedError('Platform $defaultTargetPlatform is not support');

    return PlatformInfoProviderImpl(
      package: Package(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      ),
      device: Device(
        uniqueIdentifier: uniquePlatformId ?? '<not_provided>',
        model: switch (deviceInfo) {
          AndroidDeviceInfo(:final model) => model,
          IosDeviceInfo(:final utsname) => utsname.machine,
          _ => throwUnsupportedPlatform(),
        },
        os: switch (deviceInfo) {
          AndroidDeviceInfo() => 'Android',
          IosDeviceInfo() => 'iOS',
          _ => throwUnsupportedPlatform(),
        },
        osVersion: switch (deviceInfo) {
          AndroidDeviceInfo(:final version) => version.release,
          IosDeviceInfo(:final systemVersion) => systemVersion,
          _ => throwUnsupportedPlatform(),
        },
      ),
    );
  }

  @override
  final Package package;

  @override
  final Device device;
}
