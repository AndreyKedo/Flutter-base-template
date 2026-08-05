import 'package:control/control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/core/localizations/intl_wrapper.dart';
import 'package:starter_template/core/localizations/localization_wrapper.dart';
import 'package:starter_template/core/widget/app_navigator.dart';
import 'package:starter_template/core/widget/inherited_scope.dart';

/// Расширения контекста
extension BuildContextExt on BuildContext {
  /// Возвращает обертку для контекста приложения.
  ApplicationContextWrapper get app => ApplicationContextWrapper(this);

  ApplicationNavigationWrapper get nav => app.nav;

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

  /// Возвращает локализации для виджетов Cupertino.
  CupertinoLocalizations get cupertinoLocalization => CupertinoLocalizations.of(_c);

  /// Возвращает обертку для навигации в приложении.
  ApplicationNavigationWrapper get nav => ApplicationNavigationWrapper(_c);

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

extension type ApplicationNavigationWrapper(BuildContext context) {
  /// Переход на новый экран [page].
  void push(AppPage page) => AppNavigator.push(context, page);

  /// Возврат на предыдущий экран.
  void pop() => AppNavigator.pop(context);
}
