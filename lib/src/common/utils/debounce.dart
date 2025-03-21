import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' as framework;

final _debounceMap = <WeakReference<Object>, Debouncing>{};

class Debouncing {
  Timer? timer;

  void call(framework.VoidCallback callback, {Duration timeout = const Duration(milliseconds: 300)}) {
    timer?.cancel();
    timer = null;
    timer ??= Timer(timeout, () {
      callback();
      timer = null;
    });
  }
}

extension DebouncingExtension on Object {
  void debounce(framework.VoidCallback callback, {Duration timeout = const Duration(milliseconds: 500)}) {
    _debounceMap.removeWhere((key, _) => key.target == null);

    final ref = _debounceMap.entries.singleWhereOrNull((entry) => entry.key.target.hashCode == hashCode)?.value;

    return (ref ?? (_debounceMap[WeakReference(this)] ??= Debouncing())).call(
      callback,
      timeout: timeout,
    );
  }
}
