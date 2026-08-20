import 'package:starter_template/core/entity/date.dart';

/// Диапазон дат.
extension type DateRange._(({Date begin, Date end}) instance) {
  new({required Date begin, required Date end}) : instance = (begin: begin, end: end);

  /// Диапазон дат, который содержит текущую дату. Сегодня + Завтра
  factory today() {
    final today = Date.today;
    return DateRange(begin: today, end: today.add(const Duration(days: 1)));
  }

  /// Диапазон дат текущей недели
  factory week() {
    final today = Date.today;
    return DateRange(
      begin: today.subtract(Duration(days: today.weekday - 1)),
      end: today.add(Duration(days: DateTime.daysPerWeek - today.weekday)),
    );
  }

  /// Диапазон дат месяца. По умолчанию возвращает для текущего.
  factory month([int? month]) {
    final today = Date.today.copyWith(month: month);

    return DateRange(
      begin: today.copyWith(day: 1),
      end: today.month < 12
          ? today.copyWith(month: today.month + 1, day: 0)
          : today.copyWith(month: today.month, day: 31),
    );
  }

  /// Диапазон дат текущего года
  factory year() {
    final today = Date.today;
    return DateRange(begin: Date(today.year, 1, 1), end: Date(today.year, 12, 31));
  }

  /// Начало диапазона
  Date get begin => instance.begin;

  /// Конец диапазона
  Date get end => instance.end;
}
