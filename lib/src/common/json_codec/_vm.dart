import 'dart:async';
import 'dart:convert' show JsonCodec;
import 'dart:isolate';

import 'json_codec.dart';

JsonParser getParser() => IOJsonParser();

final class IOJsonParser implements JsonParser {
  static const IOJsonParser _internalSingleton = IOJsonParser._internal();
  factory IOJsonParser() => _internalSingleton;
  const IOJsonParser._internal();

  final JsonCodec _jsonCodec = JsonParser.jsonCodec;

  @override
  @pragma('vm:prefer-inline')
  Future<Map<String, Object?>> strDecodeJson(String data, {bool useIsolate = false, String? debugPrint}) async {
    Map<String, Object?> decode(String json) => _jsonCodec.decode(json) as Map<String, Object?>;

    if (useIsolate) {
      return Isolate.run<Map<String, Object?>>(() => decode(data), debugName: debugPrint);
    }
    await Future<void>.delayed(Duration.zero);
    return decode(data);
  }

  @override
  @pragma('vm:prefer-inline')
  Future<String> objEncode(Map<String, Object?> data, {bool useIsolate = false, String? debugPrint}) async {
    String encode(Map<String, Object?> jsonMap) => _jsonCodec.encode(jsonMap);

    if (useIsolate) {
      return Isolate.run<String>(() => encode(data), debugName: debugPrint);
    }

    await Future<void>.delayed(Duration.zero);
    return encode(data);
  }
}
