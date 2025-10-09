import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:starter_template/core/logger.dart';
import 'package:starter_template/core/network/app_http_client.dart';

sealed class AppHttpException extends ClientException {
  AppHttpException(this.statusCode, super.message, [super.uri]);

  final int statusCode;
}

class ServerException extends AppHttpException {
  ServerException(int statusCode, [Uri? url])
    : super(statusCode, 'Server exception; Request to $url failed with status $statusCode.', url);
}

class ApiException extends AppHttpException {
  ApiException(int statusCode, [Uri? url])
    : super(statusCode, 'Client exception; Request to $url failed with status $statusCode.', url);
}

/// Исключение для ошибок соединения по сокету
class SocketConnectionException extends AppHttpException {
  SocketConnectionException([Uri? url]) : super(-1, 'Socket connection failed.', url);
}

abstract class RestApi {
  RestApi({
    required this.client,
    required this.baseUri,
    this.headers = const {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  });

  final AppHttpClient client;
  final Uri baseUri;
  final Map<String, String> headers;

  static final logger = AppLogger.named('RestApi');

  AppLogger log = logger;

  Uri combineUri(String to) {
    return baseUri.resolveUri(Uri.parse(to));
  }

  Map<String, String> mergeHeaders(Map<String, String>? value) {
    if (value == null) return headers;
    return headers..addAll(value);
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
  void checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;

    final message =
        'Request to $url failed with status ${response.statusCode}'
        '${response.reasonPhrase != null ? ': ${response.reasonPhrase}' : ''}';

    log.d(message);

    if (response.statusCode >= 500) {
      throw ServerException(response.statusCode, url);
    } else if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, url);
    }
  }

  @protected
  /// Обёртка для выполнения запроса с обработкой SocketException
  Future<T> safeRequest<T extends Response>(Future<T> Function() request, Uri url) async {
    try {
      return await request();
    } on SocketException {
      log.d('Socket connection failed for $url');
      throw SocketConnectionException(url);
    }
  }
}
