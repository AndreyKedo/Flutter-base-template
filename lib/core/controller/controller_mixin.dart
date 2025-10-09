import 'package:flutter/foundation.dart';

mixin ControllerMixin on ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!hasListeners || _disposed) return;

    super.notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;

    super.dispose();
    _disposed = true;
  }
}
