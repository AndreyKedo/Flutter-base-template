import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:starter_template/core/widget/inherited_scope.dart';

/// Обратный вызова шага инициализации зависимости.
typedef DependencyStepCallback<Context extends DependencyBuilderContext> = FutureOr<void> Function(Context context);

/// Обратный вызов построения контейнера зависимостей из контекста.
typedef DependencyBuilderFactory<Context extends DependencyBuilderContext, DC extends DependencyContainer> =
    FutureOr<DC> Function(Context context);

/// Шаг инициализации зависимости.
typedef DependencyStep<Context extends DependencyBuilderContext> = ({
  String? name,
  DependencyStepCallback<Context> callback,
});

/// Контекст зависимостей.
abstract class const DependencyBuilderContext() {
  const factory empty() = _EmptyContext;
}

final class const _EmptyContext() extends DependencyBuilderContext;

abstract class const DependencyContainer() {
  static InheritedScope<D> wrap<D extends DependencyContainer>({
    required ModelFactory<D> create,
    required Widget child,
  }) => InheritedScope<D>(create: create, dispose: (value) => value.dispose(), child: child);

  void dispose() {}
}

/// Построитель зависимостей.
///
/// Реализует алгоритм прохода по [DependencyBuilder.steps], вызывает конструктор [DependencyBuilder.create]
/// который возвращает контейнер с проинициализированными зависимостями. В каждом шаге доступен [Context], который
/// может являться контрактом между шагами и конечным результатом - контейнером. [Context] может содержать любую логику.
abstract class DependencyBuilder<DC extends DependencyContainer, Context extends DependencyBuilderContext>({
  required final DependencyBuilderFactory<Context, DC> create,
  required final Context context,
  final Iterable<DependencyStep<Context>> steps = const [],
}) {
  /// Шаги инициализации. Список может быть пустым, тогда в этом случае
  /// строитель перейдёт к [create].
  /// Метод который выполняет логику обработки шагов и строит контейнер с зависимостями.
  FutureOr<DC> build() async {
    if (steps.isNotEmpty) {
      var i = 0;
      String? name;
      try {
        for (
          var item = steps.first;
          i < steps.length;
          i++, i < steps.length ? {item = steps.elementAt(i), name = item.name} : Never
        ) {
          final result = item.callback(context);
          if (result is Future) await result;
        }
      } catch (e, stackTrace) {
        Error.throwWithStackTrace(DependencyBuilderException(stepIndex: i, original: e, stepName: name), stackTrace);
      }
    }

    try {
      final result = await create(context);

      return result;
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(DependencyBuilderException(original: e), stackTrace);
    }
  }
}

class DependencyBuilderException({
  required final Object original,
  final int? stepIndex,
  final String? stepName,
}) {
  @override
  String toString() {
    var label = '';

    if (stepName != null) {
      label = 'name: $stepName, ';
    } else if (stepIndex != null) {
      label = 'index: $stepIndex, ';
    }

    return 'DependencyBuilderException(${label}original: $original)';
  }
}
