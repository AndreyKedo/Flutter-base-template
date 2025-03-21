import 'dart:async';
import 'dart:convert' show JsonCodec;

import 'json_codec.dart';

JsonParser getParser() => WebJsonParser();

final class WebJsonParser implements JsonParser {
  static const WebJsonParser _internalSingleton = WebJsonParser._internal();
  factory WebJsonParser() => _internalSingleton;
  const WebJsonParser._internal();

  final JsonCodec _jsonCodec = JsonParser.jsonCodec;

  @override
  @pragma('dart2js:tryInline')
  Future<Map<String, Object?>> strDecodeJson(String data, {bool useIsolate = false, String? debugPrint}) async {
    // From flutter/foundation/_isolates_web.dart
    //
    // To avoid blocking the UI immediately for an expensive function call, we
    // pump a single frame to allow the framework to complete the current set
    // of work.

    await Future<void>.delayed(Duration.zero);
    return _jsonCodec.decode(data) as Map<String, Object?>;
  }

  @override
  @pragma('dart2js:tryInline')
  Future<String> objEncode(Map<String, Object?> data, {bool useIsolate = false, String? debugPrint}) async {
    // From flutter/foundation/_isolates_web.dart
    //
    // To avoid blocking the UI immediately for an expensive function call, we
    // pump a single frame to allow the framework to complete the current set
    // of work.

    await Future<void>.delayed(Duration.zero);
    return _jsonCodec.encode(data);
  }
}
