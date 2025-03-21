import 'dart:convert';

import '_vm.dart' if (dart.library.js_interop) '_js.dart';

abstract class JsonParser {
  factory JsonParser() => getParser();

  static const JsonCodec jsonCodec = JsonCodec(reviver: reviver);

  static Object? reviver(Object? key, Object? value) {
    if (value is List<dynamic>) return List<Object>.from(value);
    if (value is Map<String, dynamic>) return Map<String, Object?>.from(value);
    return value;
  }

  Future<Map<String, Object?>> strDecodeJson(String data, {bool useIsolate = false, String? debugPrint});

  Future<String> objEncode(Map<String, Object?> data, {bool useIsolate = false, String? debugPrint});
}
