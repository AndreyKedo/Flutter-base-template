import 'package:http/http.dart';
import 'package:http_middleware_client/http_middleware_client.dart';

abstract base class const HttpInterceptor() implements Middleware {
  @override
  Handler call(Handler innerSend) {
    return (request, context) => handle(request, context, innerSend);
  }

  Future<StreamedResponse> handle(BaseRequest request, Map<String, Object?> context, Handler handler);
}
