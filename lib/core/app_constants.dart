abstract final class AppConstants {
  static const handshakeTimeout = Duration(minutes: 1);
}

abstract final class ApplicationExceptionCode {
  static const timeout = 'NETWORK_TIMEOUT';
  static const socketConnectionFailed = 'SOCKET_CONNECTION_FAILED';
}
