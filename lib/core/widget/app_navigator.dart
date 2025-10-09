import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AppNavigationState = List<AppPage>;

/// Неизменяемая страница для использования с [AppNavigator].
///
/// Расширяет [MaterialPage] с дополнительной логикой для работы с [AppNavigator].
@immutable
class AppPage extends MaterialPage<void> {
  /// Создает страницу с указанным именем и дочерним виджетом.
  ///
  /// Если [key] не предоставлен, будет создан автоматически на основе [name] и [arguments].
  AppPage({required String super.name, required super.child, LocalKey? key, Map<String, Object?>? super.arguments})
    : super(key: key ?? ValueKey('$name-page-key'));

  @override
  String get name => super.name ?? 'Unknown';

  @override
  Map<String, Object?> get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => Object.hash(key, name, arguments);

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && key == other.key;
}

/// Декларативный навигатор для Flutter приложений.
///
/// Управляет стеком страниц и обеспечивает декларативную навигацию.
/// Поддерживает работу с контроллерами, guards, observers и другими функциями.
class AppNavigator extends StatefulWidget {
  /// Создает виджет навигатора с начальным списком страниц.
  ///
  /// Параметр [pages] не может быть пустым.
  AppNavigator({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// Создает виджет навигатора с контроллером.
  ///
  /// Параметр [controller] не может содержать пустое значение.
  AppNavigator.controlled({
    required ValueNotifier<AppNavigationState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// Получить [AppNavigatorState] из ближайшего экземпляра этого класса,
  /// который окружает данный контекст, если такой имеется.
  static AppNavigatorState? maybeOf(BuildContext context) => context.findAncestorStateOfType<AppNavigatorState>();

  /// Получить состояние навигации из ближайшего экземпляра этого класса,
  /// который окружает данный контекст, если такой имеется.
  static AppNavigationState? stateOf(BuildContext context) => maybeOf(context)?.state;

  /// Получить навигатор из ближайшего экземпляра этого класса,
  /// который окружает данный контекст, если такой имеется.
  static NavigatorState? navigatorOf(BuildContext context) => maybeOf(context)?.navigator;

  /// Изменить страницы навигатора.
  ///
  /// Применяет функцию [fn] к текущему состоянию страниц и обновляет навигатор.
  static void change(BuildContext context, AppNavigationState Function(AppNavigationState pages) fn) =>
      maybeOf(context)?.change(fn);

  /// Добавить страницу в стек навигатора.
  ///
  /// Создает новый список страниц, добавляя [page] в конец текущего списка.
  static void push(BuildContext context, AppPage page) => change(context, (state) => [...state, page]);

  /// Удалить последнюю страницу из стека навигатора.
  ///
  /// Создает новый список страниц без последнего элемента.
  static void pop(BuildContext context) => change(context, (state) {
    if (state.isNotEmpty) {
      state.removeLast();
    }
    return state;
  });

  /// Очистить страницы до начального состояния.
  ///
  /// Сбрасывает стек страниц к начальному состоянию, заданному в виджете.
  static void reset(BuildContext context, AppPage page) {
    final navigator = maybeOf(context);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  /// Начальные страницы для отображения.
  final AppNavigationState pages;

  /// Контроллер для использования с навигатором.
  ///
  /// Если предоставлен, навигатор будет слушать изменения этого контроллера.
  final ValueNotifier<AppNavigationState>? controller;

  /// Защитники для применения к страницам.
  ///
  /// Каждый guard - это функция, которая может изменить или отклонить состояние навигации.
  final List<AppNavigationState Function(BuildContext context, AppNavigationState state)> guards;

  /// Наблюдатели для прикрепления к навигатору.
  ///
  /// Эти наблюдатели будут уведомлены о событиях навигации.
  final List<NavigatorObserver> observers;

  /// Делегат переходов для использования с навигатором.
  ///
  /// Определяет, как будут анимироваться переходы между страницами.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Повторная валидация страниц.
  ///
  /// Если предоставлен, навигатор будет слушать изменения этого объекта
  /// и выполнять повторную валидацию страниц.
  final Listenable? revalidate;

  /// Функция обратного вызова, которая будет вызвана при нажатии кнопки назад.
  ///
  /// Должна возвращать логическое значение true, если этот навигатор обработает запрос;
  /// в противном случае возвращать логическое значение false.
  ///
  /// Также можно изменить [AppNavigationState] для изменения стека навигации.
  final ({AppNavigationState state, bool handled}) Function(AppNavigationState state)? onBackButtonPressed;

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

/// Состояние для виджета AppNavigator.
///
/// Управляет стеком страниц, слушателями и обработчиками событий.
class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  /// Текущее состояние [Navigator] (null, если еще не построено).
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// Текущий список страниц.
  AppNavigationState get state => UnmodifiableListView<AppPage>(_state);

  late AppNavigationState _state;
  List<NavigatorObserver> _observers = const [];

  /* #region Жизненный цикл */
  @override
  void initState() {
    super.initState();
    // Инициализируем состояние начальными страницами
    _state = widget.pages;
    // Добавляем слушатель для revalidate, если он предоставлен
    widget.revalidate?.addListener(revalidate);
    // Инициализируем наблюдателей
    _observers = <NavigatorObserver>[_observer, ...widget.observers];
    // Добавляем слушатель для контроллера, если он предоставлен
    widget.controller?.addListener(_controllerListener);
    // Вызываем слушатель контроллера для инициализации
    _controllerListener();
    // Добавляем наблюдатель за жизненным циклом приложения
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Повторная валидация при изменении зависимостей
    revalidate();
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем слушатель revalidate при необходимости
    if (!identical(widget.revalidate, oldWidget.revalidate)) {
      oldWidget.revalidate?.removeListener(revalidate);
      widget.revalidate?.addListener(revalidate);
    }
    // Обновляем наблюдателей при необходимости
    if (!identical(widget.observers, oldWidget.observers)) {
      _observers = <NavigatorObserver>[_observer, ...widget.observers];
    }
    // Обновляем слушатель контроллера при необходимости
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    // Удаляем наблюдателя за жизненным циклом приложения
    WidgetsBinding.instance.removeObserver(this);
    // Удаляем слушатель контроллера
    widget.controller?.removeListener(_controllerListener);
    // Удаляем слушатель revalidate
    widget.revalidate?.removeListener(revalidate);
    super.dispose();
  }
  /* #endregion */

  @override
  Future<bool> didPopRoute() {
    // Если определен обработчик кнопки назад, вызываем его
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.toList());
      change((pages) => result.state);
      return SynchronousFuture(result.handled);
    }

    // Иначе обрабатываем нажатие кнопки назад стандартным образом
    // Если в стеке меньше 2 страниц, не обрабатываем (вернуть false)
    if (_state.length < 2) return SynchronousFuture(false);
    // Удаляем последнюю страницу из стека
    _onDidRemovePage(_state.last);
    return SynchronousFuture(true);
  }

  /// Синхронизировать состояние с контроллером.
  ///
  /// Устанавливает значение контроллера равным текущему состоянию [_state]
  /// и восстанавливает слушатель изменений.
  void _setStateToController() {
    if (widget.controller case ValueNotifier<AppNavigationState> controller) {
      controller
        // Временно удаляем слушатель, чтобы избежать рекурсии
        ..removeListener(_controllerListener)
        // Устанавливаем новое значение
        ..value = _state
        // Восстанавливаем слушатель
        ..addListener(_controllerListener);
    }
  }

  /// Обработчик изменений контроллера.
  ///
  /// Вызывается, когда значение контроллера изменяется извне.
  /// Применяет guards к новому значению и обновляет состояние навигатора.
  void _controllerListener() {
    final controller = widget.controller;
    // Проверяем, что контроллер существует и виджет еще mounted
    if (controller == null || !mounted) return;
    final newValue = controller.value;
    // Если новое значение идентично текущему, ничего не делаем
    if (identical(newValue, _state)) return;
    final ctx = context;
    // Применяем guards к новому значению
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) {
      // Если guards вернули пустой список или состояние не изменилось,
      // восстанавливаем значение контроллера
      _setStateToController();
    } else {
      // Иначе обновляем состояние навигатора
      _state = UnmodifiableListView<AppPage>(next);
      _setStateToController();
      setState(() {});
    }
  }

  /// Повторная валидация страниц.
  ///
  /// Применяет guards к текущему состоянию и обновляет навигатор при необходимости.
  /// Вызывается при изменении зависимостей или внешних событий.
  void revalidate() {
    // Проверяем, что виджет еще mounted
    if (!mounted) return;
    final ctx = context;
    // Применяем guards к текущему состоянию
    final next = widget.guards.fold(_state.toList(), (s, g) => g(ctx, s));
    // Если guards вернули пустой список или состояние не изменилось, ничего не делаем
    if (next.isEmpty || listEquals(next, _state)) return;
    // Иначе обновляем состояние навигатора
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Изменить страницы.
  ///
  /// Применяет функцию [fn] к копии текущего состояния, затем применяет guards
  /// и обновляет состояние навигатора при необходимости.
  void change(AppNavigationState Function(AppNavigationState pages) fn) {
    // Создаем копию текущего состояния для мутации
    final prev = _state.toList();
    // Применяем функцию к копии состояния
    var next = fn(prev);
    // Если функция вернула пустой список, ничего не делаем
    if (next.isEmpty) return;
    // Проверяем, что виджет еще mounted
    if (!mounted) return;
    final ctx = context;
    // Применяем guards к новому состоянию
    next = widget.guards.fold(next, (s, g) => g(ctx, s));
    // Если guards вернули пустой список или состояние не изменилось, ничего не делаем
    if (next.isEmpty || listEquals(next, _state)) return;
    // Иначе обновляем состояние навигатора
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Вызывается, когда страница удаляется из стека.
  void _onDidRemovePage(Page<Object?> page) {
    change((pages) {
      pages.removeWhere((p) => p.key == page.key);
      return pages;
    });
  }

  @override
  Widget build(BuildContext context) => Navigator(
    pages: _state,
    transitionDelegate: widget.transitionDelegate,
    onDidRemovePage: _onDidRemovePage,
    observers: _observers,
  );
}
