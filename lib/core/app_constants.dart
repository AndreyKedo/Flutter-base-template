abstract final class AppConstants {
  static const handshakeTimeout = Duration(minutes: 1);
}

abstract final class ApplicationExceptionCode {
  static const timeout = 'NETWORK_TIMEOUT';
}
