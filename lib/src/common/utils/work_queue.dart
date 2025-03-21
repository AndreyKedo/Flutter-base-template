import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

typedef RunnableCallback<T> = Future<T> Function();

abstract class WorkQueueBase {
  final _QueueProxy<_TaskBase<Object?>> _queue;

  Future<void>? _current;

  // ignore: library_private_types_in_public_api
  WorkQueueBase(this._queue);

  /// Schedule task and put in queue.
  ///
  /// * [callback] execution callback.
  Future<R> schedule<R>(RunnableCallback<R> callback);

  @visibleForTesting
  Future<void>? get active => _current;

  Future<void> _schedule() {
    final processing = _current;
    if (processing != null) return processing;

    return _current ??= Future.doWhile(() async {
      if (_queue.isEmpty) {
        _current = null;
        return false;
      }

      await _queue.removeFirst().execute();

      return true;
    });
  }

  @visibleForTesting
  Future<void> clear() async {
    _queue.clear(); // remove all future task
    await _current; // await last
  }
}

abstract class _TaskBase<T> {
  final RunnableCallback<T> function;

  final _completer = Completer<T>();

  _TaskBase({required this.function});

  Future<T> get future => _completer.future;

  Future<void> execute() async {
    if (_completer.isCompleted) return;
    try {
      final result = await function();
      if (_completer.isCompleted) return;
      _completer.complete(result);
    } catch (exception, stackTrace) {
      _completer.completeError(
        exception,
        stackTrace,
      );
    }
  }
}

/// PriorityWorkQueue class.
///
/// Schedule a priority task by use [PriorityWorkQueue.schedule].
final class PriorityWorkQueue extends WorkQueueBase {
  /// This singleton object.
  static final queue = PriorityWorkQueue();

  /// Create new instance.
  PriorityWorkQueue() : super(_PriorityQueueProxy());

  @override
  Future<R> schedule<R>(RunnableCallback<R> callback, {WorkPriority priority = WorkPriority.low}) {
    final task = _PriorityTask<R>(
      priority: priority,
      function: callback,
    );
    _queue.add(task);
    _schedule().ignore();
    return task.future;
  }
}

class _PriorityTask<T> extends _TaskBase<T> implements Comparable<_PriorityTask> {
  final WorkPriority priority;

  _PriorityTask({
    required this.priority,
    required super.function,
  });

  @override
  int compareTo(_PriorityTask other) => priority.compareTo(other.priority);
}

enum WorkPriority implements Comparable<WorkPriority> {
  hight(3),
  middle(2),
  low(1);

  const WorkPriority(this.value);

  final int value;

  @override
  int compareTo(WorkPriority other) => index.compareTo(other.index);
}

/// WorkQueue class.
///
/// Sequential queue tasks.
class WorkQueue extends WorkQueueBase {
  /// Singleton object.
  static final main = WorkQueue();

  WorkQueue() : super(_SequentialWorkQueue());

  @override
  Future<void>? get active => _current;

  @override
  Future<T> schedule<T>(RunnableCallback<T> callback) {
    final task = WorkQueueTask(function: callback);
    _queue.add(task);
    _schedule().ignore();
    return task.future;
  }
}

class WorkQueueTask<T> extends _TaskBase<T> {
  WorkQueueTask({required super.function});
}

abstract interface class _QueueProxy<T> {
  bool get isEmpty;

  void add(T task);

  T removeFirst();

  void clear();
}

class _PriorityQueueProxy<T extends _TaskBase> extends HeapPriorityQueue<T> implements _QueueProxy<T> {
  _PriorityQueueProxy([super.comparison]);
}

class _SequentialWorkQueue<T extends _TaskBase> implements _QueueProxy<T> {
  late final _queue = Queue<T>();

  @override
  bool get isEmpty => _queue.isEmpty;

  @override
  void add(T task) => _queue.add(task);

  @override
  void clear() => _queue.clear();

  @override
  T removeFirst() => _queue.removeFirst();
}
