extension type const Options(String value) implements String {
  static const newName = Options('new-name');
  static const oldName = Options('old-name');
}

extension LocalizedOptions on Options {
  String? get abbr => switch (this) {
    Options.newName => 'n',
    Options.oldName => 'o',
    _ => null,
  };

  ({String text, String valueHelp})? get help => switch (this) {
    Options.newName => (
      text: 'The new package name to replace with',
      valueHelp: '',
    ),
    Options.oldName => (
      text:
          'The old package name to replace (optional, will be extracted from pubspec.yaml if not provided)',
      valueHelp: '',
    ),
    _ => null,
  };
}
