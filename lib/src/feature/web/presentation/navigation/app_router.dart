library app_navigation;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_template/src/feature/web/presentation/screen/main_screen.dart';

abstract class GoAppNavigator {
  abstract final GoRouter router;
  final GlobalKey<NavigatorState>? navKey;
  final String? restorationKey;
  final Listenable? notifier;

  const GoAppNavigator({this.navKey, this.restorationKey, this.notifier});

  static const String rootName = 'root';
  static const String root = '/';

  GoRouter call() => router;

  GoRouter _getRouter() => GoRouter(
      navigatorKey: navKey,
      restorationScopeId: restorationKey,
      routes: [
        GoRoute(
          path: root,
          name: rootName,
          builder: (context, state) => const MainScreen(),
        ),
      ],
      refreshListenable: notifier,
      debugLogDiagnostics: kDebugMode);

  factory GoAppNavigator.create({GlobalKey<NavigatorState>? navKey, String? restorationKey, Listenable? notifier}) =
      _GoAppNavigatorImpl;
}

class _GoAppNavigatorImpl extends GoAppNavigator {
  _GoAppNavigatorImpl({super.navKey, super.restorationKey, super.notifier});

  @override
  late final GoRouter router = _getRouter();
}

class DialogPage<T> extends Page<T> {
  final Widget child;

  const DialogPage({required this.child, super.name, super.key});

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        useSafeArea: true,
        builder: (context) => child,
      );
}
