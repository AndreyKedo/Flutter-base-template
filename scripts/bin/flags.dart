extension type const Flags(String value) implements String {
  static const initRepo = Flags('init-repo');
  static const helps = Flags('help');
}

extension LocalizedFlags on Flags {
  String? get abbr => switch (this) {
    Flags.helps => 'h',
    _ => null,
  };

  String? get help => switch (this) {
    Flags.helps => 'Print this usage information',
    Flags.initRepo => 'Initialize a new git repository after renaming',
    _ => null,
  };
}
