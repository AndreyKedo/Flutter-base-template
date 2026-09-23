/// Регулярные выражения
extension type RegularExpression(RegExp v) implements RegExp {
  factory email() => RegularExpression(
    RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ),
  );

  factory url() => RegularExpression(
    RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'),
  );
}
