import 'package:flutter/foundation.dart';

/// Тип функции "Трансформер", которая преобразует значение.
typedef PropertyTransformer<Input, Output> = Output Function(Input input);

/// Трансформер [ValueListenable].
///
/// Преобразует значение [ValueListenable.value] в другое значение [Result].
///
/// - [ValueTransformerListenable.merge] - позволяет трансформировать значение на основе коллекции [ValueListenable].
/// - [ValueTransformerListenable.new] - стандартный конструктор.
abstract interface class ValueTransformerListenable<Source, Result> implements ValueListenable<Result> {
  factory merge({
    required List<ValueListenable<Source>> listenables,
    required PropertyTransformer<List<ValueListenable<Source>>, Result> transformer,
  }) => _MergingValueListenableTransformer<Source, Result>(
    listenables: listenables,
    transformer: transformer,
  );

  factory({
    required ValueListenable<Source> source,
    required PropertyTransformer<Source, Result> transformer,
  }) {
    return _ValueListenableTransformer<Source, Result>(
      source: source,
      transformer: transformer,
    );
  }
}

/// Трансформер [ValueListenable].
///
/// Преобразует значение [ValueListenable.value] в другое значение [Result].
///
/// * [listenables] - коллекция [ValueListenable].
/// * [transformer] - функция, которая преобразует значение источника [ValueListenable.value].
class _MergingValueListenableTransformer<Source, Result>({
  /// Источник значения.
  required final List<ValueListenable<Source>> listenables,

  /// Функция, которая преобразует значение источника [ValueListenable.value].
  required final PropertyTransformer<List<ValueListenable<Source>>, Result> transformer,
}) implements ValueTransformerListenable<Source, Result> {
  @override
  void addListener(VoidCallback listener) {
    for (final listenable in listenables) {
      listenable.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (final listenable in listenables) {
      listenable.removeListener(listener);
    }
  }

  @override
  Result get value => transformer(listenables);
}

/// Трансформер [ValueListenable].
///
/// Преобразует значение [ValueListenable.value] в другое значение [Result].
///
/// * [source] - исодный [ValueListenable].
/// * [transformer] - функция, которая преобразует значение источника [ValueListenable.value].
class _ValueListenableTransformer<Source, Result>({
  /// Источник значения.
  required final ValueListenable<Source> source,

  /// Функция, которая преобразует значение источника [ValueListenable.value].
  required final PropertyTransformer<Source, Result> transformer,
}) implements ValueTransformerListenable<Source, Result> {
  @override
  void addListener(VoidCallback listener) {
    source.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    source.removeListener(listener);
  }

  @override
  Result get value => transformer(source.value);
}

/// Расширение для [ValueListenable].
extension ValueListenableExtension<Value> on ValueListenable<Value> {
  /// Трансформирует значение источника [ValueListenable.value].
  ///
  /// * [transformer] - функция, которая преобразует значение источника [ValueListenable.value].
  ValueListenable<T> transform<T>(PropertyTransformer<Value, T> transformer) {
    return _ValueListenableTransformer(
      source: this,
      transformer: transformer,
    );
  }
}

extension CollectionValueListenableExtension<Source> on List<ValueListenable<Source>> {
  /// Трансформирует значения на основе коллекции [List<ValueListenable<Source>>].
  ValueListenable<Result> transform<Result>(PropertyTransformer<List<ValueListenable<Source>>, Result> transformer) {
    return _MergingValueListenableTransformer(
      listenables: this,
      transformer: transformer,
    );
  }
}
