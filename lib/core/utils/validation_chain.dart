import 'package:flutter/widgets.dart';
import 'package:starter_template/core/utils/regular_expression.dart';
import 'package:starter_template/core/utils/string_extension.dart';

/// Функция-валидатор, принимающая nullable строку и возвращающая сообщение об ошибке
/// при неудаче, или `null` при успешной валидации.
typedef ValidatorCallback = FormFieldValidator<String>;

/// Extension type, оборачивающий [ValidatorCallback] и предоставляющий цепочные методы.
///
/// Пример использования:
/// ```dart
/// // Создание цепочки с передачей локализованных сообщений через контекст
/// final emailValidator = ValidatorChain
///     .required(message: context.lcl.requiredField)
///     .email(message: context.lcl.invalidEmail)
///     .length(min: 5, minMessage: context.lcl.tooShort)
///     .fn;
///
/// // Использование в TextFormField
/// TextFormField(
///   validator: emailValidator,
/// )
///
/// // Ручная композиция
/// final manual = ((String? v) => v?.isEmpty ?? true ? context.lcl.requiredField : null)
///     .chainWith(_email(context.lcl.invalidEmail))
///     .chainWith(_length(3, 10, null, null));
/// ```
///
extension type ValidatorChain(ValidatorCallback _fn) {
  /// Создаёт цепочку валидаторов из обычной функции.
  new from(ValidatorCallback fn) : this(fn);

  /// Возвращает цепочку валидатора обязательности заполнения.
  factory required({String? message}) => ValidatorChain(_required(message));

  /// Возвращает цепочку валидатора email.
  factory email({String? message}) => ValidatorChain(_email(message));

  factory url({String? message}) => ValidatorChain(_url(message));

  /// Возвращает цепочку валидатора длины.
  factory length({
    int min = 0,
    int max = 0,
    String? minMessage,
    String? maxMessage,
  }) => ValidatorChain(_length(min, max, minMessage, maxMessage));

  /// Возвращает цепочку валидатора по регулярному выражению.
  factory pattern(RegExp pattern, {String? message}) => ValidatorChain(_pattern(pattern, message));

  /// Возвращает цепочку валидатора с пользовательским условием.
  factory custom(
    bool Function(String?) condition, {
    String? message,
  }) => ValidatorChain(_custom(condition, message));

  /// Возвращает цепочку валидатора равенства.
  factory equals(String otherValue, {String? message}) => ValidatorChain(_equals(otherValue, message));

  /// Возвращает цепочку валидатора, который всегда проходит.
  static ValidatorChain get pass => ValidatorChain((value) => null);

  /// Выполняет валидацию переданного [value] и возвращает сообщение об ошибке или `null`.
  String? call(String? value) => _fn(value);

  /// Выполняет валидацию переданного [value] и возвращает сообщение об ошибке или `null`.
  String? validator(String? value) => _fn(value);

  /// Цепляет текущий валидатор с другим валидатором [next].
  /// Результирующий валидатор сначала запустит текущий, и если он пройдёт,
  /// запустит [next].
  ValidatorChain chain(ValidatorCallback next) {
    return ValidatorChain((value) {
      final error = _fn(value);
      if (error != null) return error;
      return next(value);
    });
  }

  /// Цепляет текущий валидатор с функцией-валидатором.
  ValidatorChain chainFn(ValidatorCallback fn) => chain(fn);

  /// Цепляет валидатор обязательности заполнения.
  ValidatorChain required({String? message}) {
    return chain(_required(message));
  }

  /// Цепляет валидатор email.
  ValidatorChain email({String? message}) {
    return chain(_email(message));
  }

  ValidatorChain url({String? message}) {
    return chain(_url(message));
  }

  /// Цепляет валидатор длины.
  ValidatorChain length({
    int min = 0,
    int max = 0,
    String? minMessage,
    String? maxMessage,
  }) {
    return chain(_length(min, max, minMessage, maxMessage));
  }

  /// Цепляет валидатор по регулярному выражению.
  ValidatorChain pattern(RegExp pattern, {String? message}) {
    return chain(_pattern(pattern, message));
  }

  /// Цепляет валидатор с пользовательским условием.
  ValidatorChain custom(bool Function(String?) condition, {String? message}) {
    return chain(_custom(condition, message));
  }

  /// Цепляет валидатор равенства с другим значением.
  ValidatorChain equals(String otherValue, {String? message}) {
    return chain(_equals(otherValue, message));
  }

  /// Возвращает исходную функцию-валидатор.
  ValidatorCallback get fn => _fn;
}

/// Создаёт валидатор обязательности заполнения.
/// [message] — кастомное сообщение. Если `null`, вызывающая сторона должна
/// обеспечить локализованную строку через контекст.
ValidatorCallback _required(String? message) => (value) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
};

/// Создаёт валидатор email.
/// [message] — кастомное сообщение. Если `null`, вызывающая сторона должна
/// обеспечить локализованную строку через контекст.
ValidatorCallback _email(String? message) {
  final regex = RegularExpression.email();
  return (value) {
    if (value == null || value.isEmpty) return null;
    if (!regex.hasMatch(value)) {
      return message;
    }
    return null;
  };
}

ValidatorCallback _url(String? message) {
  final regexp = RegularExpression.url();

  return (value) {
    if (value.isBlank) return null;
    if (!regexp.hasMatch(value!)) {
      return message;
    }
    return null;
  };
}

/// Создаёт валидатор длины.
/// [minMessage] и [maxMessage] — кастомные сообщения. Если `null`, вызывающая
/// сторона должна обеспечить локализованные строки через контекст.
ValidatorCallback _length(
  int min,
  int max,
  String? minMessage,
  String? maxMessage,
) => (value) {
  if (value == null) return null;
  final len = value.length;
  if (min > 0 && len < min) {
    return minMessage;
  }
  if (max > 0 && len > max) {
    return maxMessage;
  }
  return null;
};

/// Создаёт валидатор по регулярному выражению.
/// [message] — кастомное сообщение. Если `null`, вызывающая сторона должна
/// обеспечить локализованную строку через контекст.
ValidatorCallback _pattern(RegExp pattern, String? message) => (value) {
  if (value == null || value.isEmpty) return null;
  if (!pattern.hasMatch(value)) {
    return message;
  }
  return null;
};

/// Создаёт валидатор с пользовательским условием.
/// [message] — кастомное сообщение. Если `null`, вызывающая сторона должна
/// обеспечить локализованную строку через контекст.
ValidatorCallback _custom(bool Function(String?) condition, String? message) => (value) {
  if (!condition(value)) {
    return message;
  }
  return null;
};

/// Создаёт валидатор равенства с другим значением.
/// [message] — кастомное сообщение. Если `null`, вызывающая сторона должна
/// обеспечить локализованную строку через контекст.
ValidatorCallback _equals(String otherValue, String? message) => (value) {
  if (value != otherValue) {
    return message;
  }
  return null;
};

/// Расширение для [ValidatorCallback], добавляющее методы цепочки напрямую.
extension ValidatorExtension on ValidatorCallback {
  /// Преобразует этот валидатор в [ValidatorChain].
  ValidatorChain get chain => ValidatorChain(this);

  /// Цепляет этот валидатор с другим валидатором.
  ValidatorCallback chainWith(ValidatorCallback next) {
    return (value) {
      final error = this(value);
      if (error != null) return error;
      return next(value);
    };
  }
}
