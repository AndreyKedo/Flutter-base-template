/// Обёртка для опционального типа.
///
/// Позволяет реализовать трёхзначную логику присвоения.
class Optional<T> {
  ///
  const Optional(this.value);

  /// Значение опционального типа
  final T? value;

  /// Создаёт nullable опциональный тип
  factory Optional.toNull() => const Optional(null);

  /// Возвращает обёртку типа исходя из значения.
  static Optional<T>? from<T>(T? value) {
    if (value == null) {
      return Optional.toNull();
    }
    return Optional(value);
  }

  @override
  String toString() {
    return 'Optional(value: $value)';
  }
}

/// Расширение [Optional].
extension OptionalMapperExtension<T> on Optional<T>? {
  /// {@macro optional_extension.if_absent_nullable}
  T? operator |(T? other) => ifAbsentNullable(other);

  /// {@template optional_extension.if_absent_nullable}
  ///
  ///
  /// - if null -> not change
  /// - if Optional(null) -> change to null
  /// - if Optional(value) -> change to [other]
  /// {@endtemplate}
  T? ifAbsentNullable([T? other]) {
    if (this case Optional<T>(value: null)) {
      return null;
    }
    if (this == null) {
      return other;
    }
    return this?.value;
  }

  ///
  T ifAbsent(T other) {
    return this?.value ?? other;
  }
}
