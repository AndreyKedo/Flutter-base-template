import 'package:http/http.dart';
import 'package:http_middleware_client/http_middleware_client.dart';
import 'package:starter_template/core/logger.dart';
import 'package:starter_template/core/network/interceptor/base_interceptor.dart';

final class const LoggerInterceptor() extends HttpInterceptor {
  static final logger = AppLogger.named('LogHttp');

  @override
  Future<StreamedResponse> handle(BaseRequest request, Map<String, Object?> context, Handler handler) {
    logger.d(makeCurlString(request));

    return handler(request, context);
  }

  /// Создает строку для выполнения запроса с помощью curl.
  String makeCurlString(BaseRequest request) {
    final stringBuffer = StringBuffer();
    stringBuffer.write('curl -X ${request.method}');

    // Добавляем заголовки
    request.headers.forEach((key, value) {
      stringBuffer.write(' -H "$key: $value"');
    });

    // Добавляем тело запроса, если оно есть
    if (request case Request(:final body)) {
      if (body.length < 100) {
        stringBuffer.write(" --data '${body.replaceAll("'", "'\"'\"'")}'");
      }
    }

    // Добавляем URL
    stringBuffer.write(' "${request.url}"');

    return stringBuffer.toString();
  }
}
