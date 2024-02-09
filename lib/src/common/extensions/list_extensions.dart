import 'dart:math';

import 'dart:collection';

export 'dart:collection' show UnmodifiableListView;

final class SeparatedUnmodifiableList<T> extends UnmodifiableListView<T> {
  SeparatedUnmodifiableList(List<T> source, T separator) : super(source.separated(separator));
}

extension CollectionExtensionX<Item> on Iterable<Item> {
  List<Item> separated(Item separator) => List<Item>.generate(max(0, length * 2 - 1), (index) {
        final int itemIndex = index ~/ 2;
        if (index.isEven) {
          return elementAt(itemIndex);
        }
        return separator;
      });

  List<Item> get mutable => toList();

  List<Item> get immutable => List.of(this, growable: false);

  List<Item> diff(List<Item> other) {
    final source = toList();
    List<Item> difference = source.toSet().difference(other.toSet()).toList();
    if (difference.isEmpty) {
      return source;
    }
    for (var element in difference) {
      source.remove(element);
    }
    return source;
  }
}
