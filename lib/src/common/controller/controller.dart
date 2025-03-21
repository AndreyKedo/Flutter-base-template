import 'package:flutter/foundation.dart';

mixin Controller on ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!hasListeners || _disposed) return;

    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
