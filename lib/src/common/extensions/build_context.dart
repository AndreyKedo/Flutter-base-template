import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DeviceType {
  tablet,
  mobile,
  desktop;
}

extension BuildContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);

  bool get isMobile => _deviceType == DeviceType.mobile;

  bool get isTablet => _deviceType == DeviceType.tablet;

  /// Getting value by current [DeviceType]
  /// or [orElse] value
  T valueByDeviceType<T extends Object?>({
    required ValueGetter<T> orElse,
    ValueGetter<T>? table,
    ValueGetter<T>? mobile,
    ValueGetter<T>? desktop,
  }) {
    final callback = switch (_deviceType) {
          DeviceType.mobile => mobile,
          DeviceType.tablet => table,
          DeviceType.desktop => desktop
        } ??
        orElse;
    return callback.call();
  }

  DeviceType get _deviceType {
    final size = screenSize;

    final result = _mathDeviceBySize(
        kIsWeb ? size.width : switch (size.aspectRatio) { <= 0.0 => size.width, _ => size.shortestSide });
    return result;
  }

  DeviceType _mathDeviceBySize(final double width) => switch (width) {
        <= 600.0 => DeviceType.mobile,
        >= 600.0 && < 1024.0 => DeviceType.tablet,
        _ => DeviceType.desktop
      };
}
