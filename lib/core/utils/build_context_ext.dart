import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/core/localizations/app_localizations.dart';
import 'package:starter_template/core/widget/app_navigator.dart';
import 'package:starter_template/core/widget/inherited_scope.dart';

extension BuildContextExt on BuildContext {
  ApplicationContextWrapper get app => ApplicationContextWrapper(this);
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

  /// Список поддерживаемых локалей.
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Список делегатов локализации.
  List<LocalizationsDelegate> get localizationsDelegates => AppLocalizations.localizationsDelegates;

  /// Возвращает обертку для навигации в приложении.
  ApplicationNavigationWrapper get nav => ApplicationNavigationWrapper(_c);

  /// Возвращает контейнер с зависимостями где [T] унаследован от [DependencyContainer].
  T getDepend<T extends DependencyContainer>() => _c.getScoped<T>();

  /// Возвращает экземпляр зависимости типа [T] из текущего контекста.
  T getScoped<T>() => _c.getScoped<T>();
}

extension type ApplicationLocalizationWrapper._(AppLocalizations _context) implements AppLocalizations {
  /// Создает обертку для локализации приложения на основе контекста.
  ///
  /// Выбрасывает исключение, если в дереве виджетов отсутствует [AppLocalizations].
  factory ApplicationLocalizationWrapper(BuildContext context) {
    final delegate = AppLocalizations.of(context);
    assert(delegate != null, 'Do not have AppLocalizations into elements tree');
    return ApplicationLocalizationWrapper._(delegate!);
  }
}

extension type ApplicationNavigationWrapper(BuildContext context) {
  /// Переход на новый экран [page].
  void push(AppPage page) => AppNavigator.push(context, page);

  /// Возврат на предыдущий экран.
  void pop() => AppNavigator.pop(context);
}
