import 'dart:convert';

/// Кодек для кодирования объекта [Map<String, Object?>] в JSON строку и декодирования обратно.
const appJsonCodec = JsonAppCodec();

final _jsonCodec = JsonCodec.withReviver(_reviver);
Object? _reviver(Object? key, Object? value) {
  if (value is List<dynamic>) return List<Object>.from(value);
  if (value is Map<String, dynamic>) return Map<String, Object?>.from(value);
  return value;
}

class JsonAppCodec extends Codec<Map<String, Object?>, String> {
  const JsonAppCodec();

  @override
  Converter<String, Map<String, Object?>> get decoder => const _JsonDecoder();

  @override
  Converter<Map<String, Object?>, String> get encoder => const _JsonEncoder();
}

final class _JsonDecoder extends Converter<String, Map<String, Object?>> {
  const _JsonDecoder();

  @override
  Map<String, Object?> convert(String input) => _jsonCodec.decode(input) as Map<String, Object?>;
}

final class _JsonEncoder extends Converter<Map<String, Object?>, String> {
  const _JsonEncoder();

  @override
  String convert(Map<String, Object?> input) => _jsonCodec.encode(input);
}
