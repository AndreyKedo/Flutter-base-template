import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_utils;
import 'package:starter_template/core/entity/localizable_exception.dart';
import 'package:starter_template/core/logger.dart';
import 'package:starter_template/core/network/app_http_client.dart';
import 'package:starter_template/core/utils/json_parser.dart';

sealed class AppHttpException extends ClientException with LocalizableException {
  AppHttpException(super.message, [super.uri]);
}

/// Mixin для предоставления кода статуса HTTP ответа.
mixin StatusCodeMixin {
  /// Код статуса HTTP ответа.
  int get statusCode;
}

/// Исключение для ошибок HTTP.
abstract class AppHttpExceptionStatusCode extends AppHttpException with StatusCodeMixin {
  AppHttpExceptionStatusCode(this.statusCode, super.message, [super.uri]);

  @override
  final int statusCode;
}

class ServerException extends AppHttpExceptionStatusCode {
  ServerException(int statusCode, [Uri? url])
    : super(statusCode, 'Server exception; Request to $url failed with status $statusCode.', url);
}

class ApiException extends AppHttpExceptionStatusCode {
  ApiException(int statusCode, [Uri? url])
    : super(statusCode, 'Client exception; Request failed with status $statusCode.', url);
}

/// Исключение для ошибок соединения по сокету
class SocketConnectionException extends AppHttpException {
  SocketConnectionException([Uri? url]) : super('Socket connection failed.', url);
}

/// Исключение для ошибок соединения по сокету
class SocketTlsException extends AppHttpException {
  SocketTlsException([Uri? url]) : super('Socket connection failed.', url);
}

/// Исключение для ошибок соединения по сокету
class ConnectionTimeoutException extends AppHttpException {
  ConnectionTimeoutException(Uri url) : super('Request timeout for $url');
}

/// {@template rest_api}
/// Абстрактный класс, который предоставляет точку входа в API, HTTP методы для выполнения запросов к API.
/// {@endtemplate}
abstract class RestApi {
  /// {@macro rest_api}
  RestApi({
    required this.client,
    required this.baseUri,
    this.debugName = 'RestApi',
    this.headers = const {
      HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    },
  }) : assert(baseUri.isScheme('https') || baseUri.isScheme('http'), 'Базовый URI должен быть http или https');

  final AppHttpClient client;
  final Uri baseUri;
  final Map<String, String> headers;
  final String debugName;

  late final log = AppLogger.named(debugName);

  late final _context = path_utils.Context(current: baseUri.toString(), style: .url);

  @protected
  Uri combineUri(String to) {
    // Убираем все ведущие слэши, чтобы путь был относительным к baseUri
    to = to.replaceFirst(RegExp(r'^/+'), '');
    return _context.toUri(_context.join(_context.canonicalize(to)));
  }

  @protected
  Map<String, String> mergeHeaders(Map<String, String>? value) {
    if (value == null) return headers;
    return Map.of(headers)..addAll(value);
  }

  Future<Response> get(String path, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final response = await safeRequest(() => client.get(uri, headers: mergeHeaders(headers)), uri);
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final response = await safeRequest(
      () => client.post(uri, headers: mergeHeaders(headers), body: body, encoding: encoding),
      uri,
    );
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> postForm(
    String path, {
    List<MultipartFile> files = const [],
    Map<String, String> fields = const {},
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final stream = await safeRequest(() {
      final request = MultipartRequest('POST', uri)
        ..headers.addAll(mergeHeaders(headers))
        ..files.addAll(files)
        ..fields.addAll(fields);
      return client.send(request);
    }, uri);
    final response = await Response.fromStream(stream);
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> pathForm(
    String path, {
    List<MultipartFile> files = const [],
    Map<String, String> fields = const {},
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final stream = await safeRequest(() {
      final request = MultipartRequest('PATCH', uri)
        ..headers.addAll(mergeHeaders(headers))
        ..files.addAll(files)
        ..fields.addAll(fields);
      return client.send(request);
    }, uri);
    final response = await Response.fromStream(stream);
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final response = await safeRequest(
      () => client.put(uri, headers: mergeHeaders(headers), body: body, encoding: encoding),
      uri,
    );
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> delete(String path, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final response = await safeRequest(() => client.delete(uri, headers: mergeHeaders(headers)), uri);
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);
    final response = await safeRequest(
      () => client.patch(uri, headers: mergeHeaders(headers), body: body, encoding: encoding),
      uri,
    );
    checkResponseSuccess(uri, response);
    return response;
  }

  @protected
  void checkResponseSuccess(Uri url, BaseResponse response) {
    if (response.statusCode < 400) return;

    final message =
        'Request to $url failed with status ${response.statusCode}'
        '${response.reasonPhrase != null ? ': ${response.reasonPhrase}' : ''}';

    bool isJson(String value) =>
        (value.startsWith('{') && value.endsWith('}')) || (value.startsWith('[') && value.endsWith(']'));

    log.d(message);
    if (response case final Response response when isJson(response.body)) {
      log.d(appJsonCodec.decode(response.body));
    }

    if (response.statusCode >= 500) {
      throw ServerException(response.statusCode, url);
    } else if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, url);
    }
  }

  @protected
  Future<T> safeRequest<T extends BaseResponse>(Future<T> Function() request, Uri url) async {
    try {
      return await request();
    } on SocketException {
      throw SocketConnectionException(url);
    } on TimeoutException {
      throw ConnectionTimeoutException(url);
    } on TlsException {
      throw SocketTlsException(url);
    } catch (e, s) {
      Error.throwWithStackTrace(GeneralExceptionWrapper(e), s);
    }
  }
}
