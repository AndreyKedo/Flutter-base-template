import 'package:meta/meta.dart';

/// [Date] расширение типа [DateTime] для работы с датой без времени.
extension type const Date._(DateTime _date) implements DateTime {
  Date(int year, int month, int day) : _date = DateTime(year, month, day);

  static final today = Date.now();

  /// Текущая дата
  factory Date.now() => Date.of(DateTime.now());

  /// Создать [Date] из [DateTime].
  factory Date.of(DateTime date) {
    // Если дата уже в UTC повторного преобразования не будет.
    final DateTime(:year, :month, :day) = date;
    return Date(year, month, day);
  }

  /// Создаёт [Date] из компактного формата в виде целого числа.
  Date.value(int value)
    : _date = DateTime(
        value >> 9, // year (12 bit)
        (value >> 5) & 0xf, // month (4 bit)
        value & 0x1F, // day (5 bit)
      );

  /// Возвращает дату в компактном формате в виде целого числа.
  int get value {
    // YYYYYYYYYYYY (0-4095) | MMMM (1-12) | (1-31)
    return (_date.year << 9) | (_date.month << 5) | _date.day;
  }

  bool operator >=(Date other) => isAfter(other) || isAtSameMomentAs(other);

  bool operator <=(Date other) => isBefore(other) || isAtSameMomentAs(other);

  @redeclare
  Date add(Duration value) {
    final datetime = _date.add(value);
    return Date(datetime.year, datetime.month, datetime.day);
  }

  @redeclare
  Date subtract(Duration value) {
    final datetime = _date.subtract(value);
    return Date(datetime.year, datetime.month, datetime.day);
  }

  Date copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return Date(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
    );
  }
}

extension StringDateParseNullExtension on String? {
  Date? toDate() {
    if (this == null) return null;

    final tryParseValue = DateTime.tryParse(this!);
    if (tryParseValue == null) return null;

    return Date.of(tryParseValue);
  }
}

extension StringDateParseExtension on String {
  Date toDate() => Date.of(.parse(this));
}
