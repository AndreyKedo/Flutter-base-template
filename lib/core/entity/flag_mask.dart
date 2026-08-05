extension type const FlagMask<T extends int>(int value) implements int {
  static int composite(Iterable<int> components) {
    return components.fold(0, (value, issue) => value | issue);
  }

  bool get isEmpty => value == 0;

  bool contains(T flag) => (value & flag) != 0;

  bool containsAny(T flags) => (value & flags) != 0;

  bool containsAll(T flags) => (value & flags) == flags;
}
