import 'package:http_middleware_client/http_middleware_client.dart';

class AppHttpClient extends HttpMiddlewareClient {
  AppHttpClient({super.client, super.middlewares});
}
