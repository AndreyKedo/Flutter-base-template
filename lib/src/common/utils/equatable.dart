import 'package:collection/collection.dart';

/// Mixin class [Equatable]
///
/// Simple implementation [Equatable] library without overhead.
/// Use for implementation BLoC state and event, or object
abstract mixin class Equatable {
  const Equatable();

  static const DeepCollectionEquality _equalityHelper = DeepCollectionEquality();

  /// Collection of properties implemented class
  List<Object?> get keys => const [];

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      Object.hashAll(
        keys.map(
          (e) {
            if (e is List || e is Map || e is Set || e is Iterable) return _equalityHelper.hash(e);

            return e;
          },
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equatable && runtimeType == other.runtimeType && _equalityHelper.equals(keys, other.keys);

  @override
  String toString() => mapPropsToString(runtimeType, keys);
}

String mapPropsToString(Type runtimeType, List<Object?> props) => '$runtimeType(${props.map(
      (prop) => prop.toString(),
    ).join(', ')})';
