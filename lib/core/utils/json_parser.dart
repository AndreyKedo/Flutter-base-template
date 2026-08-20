import 'dart:convert';

/// Глобальный объект [JsonAppCodec].
///
/// {@macro json_codec}
const appJsonCodec = JsonAppCodec();

final _jsonCodec = JsonCodec.withReviver((Object? key, Object? value) {
  if (value is List<dynamic>) return List<Object>.from(value, growable: false);
  if (value is Map<String, dynamic>) return Map<String, Object?>.from(value);
  return value;
});

/// {@template json_codec}
/// Кодек для кодирования объекта типа [Map] или [List] в JSON строку и декодирования обратно.
/// {@endtemplate}
class const JsonAppCodec() extends Codec<Object, String> {
  /// {@macro json_codec}
  @override
  Converter<String, Object> get decoder => const _JsonDecoder();

  @override
  Converter<Object, String> get encoder => const _JsonEncoder();
}

final class const _JsonDecoder() extends Converter<String, Object> {
  @override
  Object convert(String input) => _jsonCodec.decode(input) as Object;
}

final class const _JsonEncoder() extends Converter<Object, String> {
  @override
  String convert(Object input) {
    if (input is List || input is Map) {
      return _jsonCodec.encode(input);
    }

    throw FormatException('Неподдерживаемый тип данных. Ожидается List или Map.', input);
  }
}

extension JsonAppCodecExtension on Object {
  /// Конвертирует объект в Map\<String, Object?>.
  ///
  /// **Примечание:**
  /// Если объект не является Map, то будет выброшено исключение.
  Map<String, Object?> toMapUnSafe() => Map.from(this as Map);
}
