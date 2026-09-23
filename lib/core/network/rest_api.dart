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

sealed class AppHttpException(super.message, [super.uri]) extends ClientException with LocalizableException;

/// Mixin для предоставления кода статуса HTTP ответа.
mixin StatusCodeMixin {
  /// Код статуса HTTP ответа.
  int get statusCode;
}

/// Mixin ошибки сетевого характера.
mixin ConnectionException;

/// Исключение для ошибок HTTP.
abstract class AppHttpExceptionStatusCode(@override final int statusCode, super.message, [super.uri])
    extends AppHttpException
    with StatusCodeMixin;

class ServerException(int statusCode, [Uri? url]) extends AppHttpExceptionStatusCode {
  this : super(statusCode, 'Server exception; Request failed with status $statusCode.', url);
}

class ApiException(int statusCode, [Uri? url]) extends AppHttpExceptionStatusCode {
  this : super(statusCode, 'Client exception; Request failed with status $statusCode.', url);
}

/// Исключение для ошибок соединения по сокету
class SocketConnectionException([Uri? url]) extends AppHttpException with ConnectionException {
  this : super('Socket connection failed.', url);
}

/// Исключение для ошибок соединения по сокету
class SocketTlsException([Uri? url]) extends AppHttpException with ConnectionException {
  this : super('Socket connection failed.', url);
}

/// Исключение для ошибок соединения по сокету
class ConnectionTimeoutException(Uri url) extends AppHttpException with ConnectionException {
  this : super('Request timeout for $url');
}

/// {@template rest_api}
/// Абстрактный класс, который предоставляет точку входа в API, HTTP методы для выполнения запросов к API.
/// {@endtemplate}
abstract class RestApi({
  required final AppHttpClient client,
  required final Uri baseUri,
  final String debugName = 'RestApi',
  final Map<String, String> headers = const {
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
  },
}) {
  /// {@macro rest_api}
  this
    : assert(
        baseUri.isScheme('https') || baseUri.isScheme('http'),
        'Базовый URI должен быть http или https',
      );

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

  Future<Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    // Формируем URI с параметрами запроса.
    final requestUri = combineUri(path);
    final uri = requestUri.replace(queryParameters: queryParameters);

    // Отправляем запрос и полностью считываем ответ с обработкой ошибок.
    final response = await safeRequest(
      () async {
        // Используем стандартный GET, если отмена не требуется.
        if (abortTrigger == null) {
          return client.get(uri, headers: mergeHeaders(headers));
        }

        // Считываем поток внутри safeRequest, включая возможную отмену.
        final stream = await client.send(
          abortableRequest(
            'GET',
            uri,
            headers: headers,
            abortTrigger: abortTrigger,
          ),
        );
        return await Response.fromStream(stream);
      },
      uri,
    );

    // Проверяем статус ответа.
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Encoding? encoding,
    Future<void>? abortTrigger,
  }) async {
    final uri = combineUri(path).replace(queryParameters: queryParameters);

    // Отправляем запрос и полностью считываем ответ с обработкой ошибок.
    final response = await safeRequest(
      () async {
        // Используем стандартный POST, если отмена не требуется.
        if (abortTrigger == null) {
          return client.post(uri, headers: mergeHeaders(headers), body: body, encoding: encoding);
        }

        // Считываем поток внутри safeRequest, включая возможную отмену.
        final stream = await client.send(
          abortableRequest(
            'POST',
            uri,
            headers: headers,
            body: body,
            encoding: encoding,
            abortTrigger: abortTrigger,
          ),
        );
        return await Response.fromStream(stream);
      },
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
    final stream = await safeRequest(
      () {
        final request = MultipartRequest('POST', uri)
          ..headers.addAll(mergeHeaders(headers))
          ..files.addAll(files)
          ..fields.addAll(fields);
        return client.send(request);
      },
      uri,
    );
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
    final stream = await safeRequest(
      () {
        final request = MultipartRequest('PATCH', uri)
          ..headers.addAll(mergeHeaders(headers))
          ..files.addAll(files)
          ..fields.addAll(fields);
        return client.send(request);
      },
      uri,
    );
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
    Future<void>? abortTrigger,
  }) async {
    // Формируем URI с параметрами запроса.
    final requestUri = combineUri(path);
    final uri = requestUri.replace(queryParameters: queryParameters);

    // Отправляем запрос и полностью считываем ответ с обработкой ошибок.
    final response = await safeRequest(
      () async {
        // Используем стандартный PUT, если отмена не требуется.
        if (abortTrigger == null) {
          return client.put(uri, headers: mergeHeaders(headers), body: body, encoding: encoding);
        }

        // Считываем поток внутри safeRequest, включая возможную отмену.
        final stream = await client.send(
          abortableRequest(
            'PUT',
            uri,
            headers: headers,
            body: body,
            encoding: encoding,
            abortTrigger: abortTrigger,
          ),
        );
        return await Response.fromStream(stream);
      },
      uri,
    );

    // Проверяем статус ответа.
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    // Формируем URI с параметрами запроса.
    final requestUri = combineUri(path);
    final uri = requestUri.replace(queryParameters: queryParameters);

    // Отправляем запрос и полностью считываем ответ с обработкой ошибок.
    final response = await safeRequest(
      () async {
        // Используем стандартный DELETE, если отмена не требуется.
        if (abortTrigger == null) {
          return client.delete(uri, headers: mergeHeaders(headers));
        }

        // Считываем поток внутри safeRequest, включая возможную отмену.
        final stream = await client.send(
          abortableRequest(
            'DELETE',
            uri,
            headers: headers,
            abortTrigger: abortTrigger,
          ),
        );
        return await Response.fromStream(stream);
      },
      uri,
    );

    // Проверяем статус ответа.
    checkResponseSuccess(uri, response);
    return response;
  }

  Future<Response> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Encoding? encoding,
    Future<void>? abortTrigger,
  }) async {
    // Формируем URI с параметрами запроса.
    final requestUri = combineUri(path);
    final uri = requestUri.replace(queryParameters: queryParameters);

    // Отправляем запрос и полностью считываем ответ с обработкой ошибок.
    final response = await safeRequest(
      () async {
        // Используем стандартный PATCH, если отмена не требуется.
        if (abortTrigger == null) {
          return client.patch(uri, headers: mergeHeaders(headers), body: body, encoding: encoding);
        }

        // Считываем поток внутри safeRequest, включая возможную отмену.
        final stream = await client.send(
          abortableRequest(
            'PATCH',
            uri,
            headers: headers,
            body: body,
            encoding: encoding,
            abortTrigger: abortTrigger,
          ),
        );
        return await Response.fromStream(stream);
      },
      uri,
    );

    // Проверяем статус ответа.
    checkResponseSuccess(uri, response);
    return response;
  }

  /// Establish abortable request.
  ///
  /// Implementation from [BaseClient].
  AbortableRequest abortableRequest(
    String method,
    Uri uri, {
    required Future<void> abortTrigger,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    // Setup headers
    final request = AbortableRequest(method, uri, abortTrigger: abortTrigger);
    final requestHeaders = request.headers;
    requestHeaders.addAll(mergeHeaders(headers));
    if (encoding != null) request.encoding = encoding;

    // Fill body
    switch (body) {
      case null:
        break;
      case String body:
        request.body = body;
      case List body:
        request.bodyBytes = body.cast<int>();
      case Map body:
        request.bodyFields = body.cast<String, String>();
      default:
        throw ArgumentError.value(body, 'body', 'Unsupported request body');
    }

    return request;
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
    } on RequestAbortedException {
      rethrow;
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

extension ResponseExtension on Response {
  Map<String, Object?> bodyAsJson() => appJsonCodec.decode(body).toMapUnSafe();
}
