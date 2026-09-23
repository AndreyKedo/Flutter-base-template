/// Обёртка для опционального типа.
///
/// Позволяет реализовать трёхзначную логику присвоения.
class const Optional<T>(final T? value) {
  ///
  /// Создаёт nullable опциональный тип
  factory absent() => Optional<T>(null);

  /// Возвращает обёртку типа исходя из значения.
  factory from(T? value) {
    if (value == null) {
      return Optional<T>.absent();
    }
    return Optional<T>(value);
  }

  bool get isPresent => value != null;

  bool get isNotPresent => value == null;

  T? get orNull => value;

  T get requiredValue {
    if (value == null) {
      throw StateError('value called on absent Optional.');
    }
    return value!;
  }

  void ifPresent(void Function(T value) ifPresent) {
    if (isPresent) {
      ifPresent(value as T);
    }
  }

  void ifAbsent(void Function() ifAbsent) {
    if (!isPresent) {
      ifAbsent();
    }
  }

  T or(T defaultValue) {
    return value ?? defaultValue;
  }

  @override
  int get hashCode => value.hashCode;

  /// Delegates to the underlying [value] operator==.
  @override
  bool operator ==(Object o) => o is Optional<T> && o.value == value;

  @override
  String toString() {
    return value == null ? 'Optional { absent }' : 'Optional { value: $value }';
  }
}

/// Расширение [Optional].
extension OptionalMapperExtension<T> on Optional<T>? {
  /// {@template optional_extension.if_absent_nullable}
  ///
  ///
  /// - if null -> not change
  /// - if Optional(null) -> change to null
  /// - if Optional(value) -> change to [other]
  /// {@endtemplate}
  T? operator |(T? other) {
    if (this case Optional<T>(value: null)) {
      return null;
    }
    if (this == null) {
      return other;
    }
    return this?.value;
  }
}
