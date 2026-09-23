extension AppNullStringExtension on String? {
  bool get isBlank {
    return switch (this) {
      String value when value.trim().isNotEmpty => false,
      _ => true,
    };
  }

  bool get isNotBlank => !isBlank;

  String? capitalize() {
    final self = this;
    if (self == null) return null;
    return self.capitalize();
  }
}

extension AppStringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    final firstChar = substring(0, 1).toUpperCase();
    return replaceRange(0, 1, firstChar);
  }
}
