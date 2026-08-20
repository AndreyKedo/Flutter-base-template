import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

typedef RunnableCallback<T> = Future<T> Function();

abstract class WorkQueueBase(final QueueProxy<TaskBase<Object?>> _queue) {
  Future<void>? _current;

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

abstract class TaskBase<T>({required final RunnableCallback<T> function}) {
  final _completer = Completer<T>();

  Future<T> get future => _completer.future;

  Future<void> execute() async {
    if (_completer.isCompleted) return;
    try {
      final result = await function();
      if (_completer.isCompleted) return;
      _completer.complete(result);
    } catch (exception, stackTrace) {
      _completer.completeError(exception, stackTrace);
    }
  }
}

final class PriorityWorkQueue() extends WorkQueueBase {
  this : super(_PriorityQueueProxy());
  static final main = PriorityWorkQueue();

  @override
  Future<R> schedule<R>(RunnableCallback<R> callback, {WorkPriority priority = WorkPriority.low}) {
    final task = _PriorityTask<R>(priority: priority, function: callback);
    _queue.add(task);
    _schedule().ignore();
    return task.future;
  }
}

class _PriorityTask<T>({required final WorkPriority priority, required super.function})
    extends TaskBase<T>
    implements Comparable<_PriorityTask> {
  @override
  int compareTo(_PriorityTask other) => priority.compareTo(other.priority);
}

enum WorkPriority(final int value) implements Comparable<WorkPriority> {
  hight(3),
  middle(2),
  low(1);

  @override
  int compareTo(WorkPriority other) => index.compareTo(other.index);
}

class WorkQueue() extends WorkQueueBase {
  this : super(_SequentialWorkQueue());

  static final main = WorkQueue();

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

class WorkQueueTask<T>({required super.function}) extends TaskBase<T>;

abstract interface class QueueProxy<T> {
  bool get isEmpty;

  void add(T task);

  T removeFirst();

  void clear();
}

class _PriorityQueueProxy<T extends TaskBase>([super.comparison]) extends HeapPriorityQueue<T> implements QueueProxy<T>;

class _SequentialWorkQueue<T extends TaskBase> implements QueueProxy<T> {
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
