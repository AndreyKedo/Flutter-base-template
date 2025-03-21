import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [WindowSizeClasses](https://m3.material.io/foundations/layout/applying-layout/window-size-classes#9e94b1fb-e842-423f-9713-099b40f13922).
///
/// Defined enums of window sizes.
enum WindowSizeClasses {
  small,
  medium,
  large;
}

/// More [info](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
extension AdaptivityUtilsContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);

  bool get isMobile => windowClass == WindowSizeClasses.small;

  bool get isTablet => windowClass == WindowSizeClasses.medium;

  /// Getting value by current [WindowSizeClasses]
  /// or [orElse] value
  T valueByWindowType<T extends Object?>({
    required ValueGetter<T> orElse,
    ValueGetter<T>? medium,
    ValueGetter<T>? small,
    ValueGetter<T>? large,
  }) {
    final callback = switch (windowClass) {
          WindowSizeClasses.small => small,
          WindowSizeClasses.medium => medium,
          WindowSizeClasses.large => large
        } ??
        orElse;
    return callback();
  }

  WindowSizeClasses get windowClass {
    final size = screenSize;

    final result = _mathDeviceBySize(
      kIsWeb ? size.width : switch (size.aspectRatio) { <= 0.0 => size.width, _ => size.shortestSide },
    );
    return result;
  }

  WindowSizeClasses _mathDeviceBySize(final double width) => switch (width) {
        <= 600 => WindowSizeClasses.small,
        >= 600 && < 840 => WindowSizeClasses.medium,
        _ => WindowSizeClasses.large,
      };
}
