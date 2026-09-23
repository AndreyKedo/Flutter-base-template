import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:http_middleware_client/http_middleware_client.dart';

/// Стратегия повторных запросов
abstract class const AppHttpRetryStrategy() {
  Iterable<Duration> get delays;

  Future<bool> when(covariant BaseResponse response);
}

/// Стратегия повторных запросов по умолчанию
final class const DefaultAppHttpRetry() extends AppHttpRetryStrategy {
  static const _retryableMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  @override
  final Iterable<Duration> delays = const [
    Duration(milliseconds: 500), // 1-я попытка: 500ms
    Duration(milliseconds: 1000), // 2-я попытка: 1s
    Duration(milliseconds: 2000), // 3-я попытка: 2s
    Duration(milliseconds: 4000), // 4-я попытка: 4s
  ];

  @override
  Future<bool> when(covariant BaseResponse response) async {
    final method = response.request?.method;
    return response.statusCode == 503 && method != null && _retryableMethods.contains(method);
  }
}

final class const DisableAppHttpRetry() extends AppHttpRetryStrategy {
  @override
  final Iterable<Duration> delays = const [];

  @override
  Future<bool> when(covariant BaseResponse response) => .syncValue(false);
}

class AppHttpClient({
  Client? client,
  super.middlewares,
  AppHttpRetryStrategy retryStrategy = const DisableAppHttpRetry(),
}) extends HttpMiddlewareClient {
  this
    : super(
        client: RetryClient.withDelays(
          client ?? Client(),
          retryStrategy.delays,
          when: retryStrategy.when,
        ),
      );
}
