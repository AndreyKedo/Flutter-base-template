import 'package:control/control.dart';
import 'package:material_ui/material_ui.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/core/localizations/intl_wrapper.dart';
import 'package:starter_template/core/localizations/localization_wrapper.dart';
import 'package:starter_template/core/widget/inherited_scope.dart';

/// Расширения контекста
extension BuildContextExt on BuildContext {
  /// Возвращает обертку для контекста приложения.
  ApplicationContextWrapper get app => ApplicationContextWrapper(this);

  /// Возвращает обертку для локализации приложения.
  ApplicationLocalizationWrapper get lcl => app.lcl;

  /// Подписывает виджет на изменения контроллера.
  C watchOf<C extends Listenable>() => ControllerScope.of<C>(this, listen: true);

  /// Возвращает контейнер с зависимостями где [T] унаследован от [DependencyContainer].
  T getDepend<T extends DependencyContainer>() => getScoped<T>();
}

extension type ApplicationContextWrapper(BuildContext _c) {
  /// Возвращает обертку для локализации приложения.
  ApplicationLocalizationWrapper get lcl => ApplicationLocalizationWrapper(_c);

  /// Возвращает текущую локаль приложения.
  Locale get locale => Localizations.localeOf(_c);

  /// Возвращает локализации для виджетов Material.
  MaterialLocalizations get materialLocalization => MaterialLocalizations.of(_c);

  /// Возвращает обёртку с методами форматирования
  IntlHelperContextWrapper get intl => IntlHelperContextWrapper(_c);

  /// Возвращает [true] если открыта клавиатура.
  ///
  /// **Внимание: при вложенных Scaffold -> Scaffold метод не будет работать**
  bool get keyboardIsVisible {
    final bottomIndents = MediaQuery.viewInsetsOf(_c).bottom;

    return bottomIndents > 0;
  }
}
