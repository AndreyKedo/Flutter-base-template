import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:flutter/services.dart';

/// The signature of a function that processes events events from [Isolate] using [StreamQueue].
typedef AppIsolateMessageQueueHandler = Future<void> Function(StreamQueue queue);

/// The extension type of [Isolate].
///
/// Declaring a simple API for interacting with an isolate instance.
extension type AppIsolate(Isolate isolate) implements Isolate {
  static final _expandoReceivePort = Expando<ReceivePort>('AppIsolate[ReceivePort]');
  static final _expandoExternalSendPort = Expando<SendPort>('AppIsolate[SendPort]');

  /// Create new isolate.
  ///
  /// * [handler] - the callback where you must handle events from a isolate.
  /// Used [StreamQueue].
  ///
  /// For other params See [Isolate.spawn].
  static Future<AppIsolate> create(
    void Function((RootIsolateToken?, SendPort) message) entryPoint,
    AppIsolateMessageQueueHandler handler, {
    bool paused = false,
    bool errorsAreFatal = true,
    SendPort? onExit,
    SendPort? onError,
    String? debugName,
  }) async {
    final receivePort = ReceivePort('${debugName ?? ''}[ReceivePort]');
    final rootIsolate = await Isolate.spawn(
      entryPoint,
      (RootIsolateToken.instance, receivePort.sendPort),
      paused: paused,
      errorsAreFatal: errorsAreFatal,
      onExit: onExit ?? receivePort.sendPort,
      onError: onError ?? receivePort.sendPort,
      debugName: debugName,
    );
    _expandoReceivePort[rootIsolate] = receivePort;

    final queue = StreamQueue(receivePort);

    final sendPort = await queue.next as SendPort;
    _expandoExternalSendPort[rootIsolate] = sendPort;

    unawaited(handler(queue));

    return AppIsolate(rootIsolate);
  }

  /// To send a [message] to current isolate.
  void send(Object? message) => _expandoExternalSendPort[isolate]?.send(message);

  /// Close receiver.
  void close() => _expandoReceivePort[isolate]?.close();
}
