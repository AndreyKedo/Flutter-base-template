import 'package:flutter/material.dart';
import 'package:starter_template/core/utils/build_context_ext.dart';
import 'package:starter_template/core/widget/inherited_scope.dart';
import 'package:starter_template/feature/application/di/application_di.dart';
import 'package:starter_template/feature/application/widget/app_entry.dart';
import 'package:starter_template/feature/development/screen/development_screen.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedScope<ApplicationDi>(
      create: (_) {
        return ApplicationDiContainer.create();
      },
      child: _RootNavigatorWrapper(
        builder: (context, params) => MaterialApp(
          navigatorKey: params.key,
          navigatorObservers: [params.observer],
          onGenerateTitle: (context) => context.app.lcl.appName,
          themeMode: ThemeMode.dark,
          theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(60, 121, 243, 1),
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color.fromRGBO(60, 121, 243, 1),
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: context.app.localizationsDelegates,
          supportedLocales: context.app.supportedLocales,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(child: child ?? const SizedBox.shrink()),
                Positioned(
                  top: MediaQuery.viewPaddingOf(context).top,
                  right: 16,
                  child: ListenableBuilder(
                    listenable: params.observer,
                    child: const SizedBox.shrink(),
                    builder: (context, child) => params.observer.showDebugButton
                        ? FloatingActionButton.small(
                            child: const Icon(Icons.developer_mode),
                            onPressed: () {
                              final navContext = params.key.currentContext;
                              if (navContext == null) return;
                              DevelopmentScreen.push(navContext);
                            },
                          )
                        : child!,
                  ),
                ),
              ],
            );
          },
          home: const AppEntry(),
        ),
      ),
    );
  }
}

class _NavigatorParams {
  _NavigatorParams({required this.key, required this.observer});

  final GlobalKey<NavigatorState> key;
  final _RootObserver observer;

  BuildContext get context => key.currentContext!;
}

final class _RootNavigatorWrapper extends StatefulWidget {
  const _RootNavigatorWrapper({required this.builder});

  final Widget Function(BuildContext context, _NavigatorParams params) builder;

  @override
  State<_RootNavigatorWrapper> createState() => __RootNavigatorWrapperState();
}

/// State for widget _RootNavigatorWrapper
class __RootNavigatorWrapperState extends State<_RootNavigatorWrapper> {
  final navKey = GlobalKey<NavigatorState>();

  final observer = _RootObserver();

  /* #region Lifecycle */
  @override
  void dispose() {
    observer.dispose();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => widget.builder(context, _NavigatorParams(key: navKey, observer: observer));
}

class _RootObserver extends NavigatorObserver with ChangeNotifier {
  _RootObserver();

  bool _showDebug = true;
  bool get showDebugButton => _showDebug;

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    if (topRoute.settings.name == DevelopmentScreen.routeSettings.name) {
      if (_showDebug == false) return;
      _showDebug = false;
      notifyListeners();
      return;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route.settings.name == DevelopmentScreen.routeSettings.name) {
      if (_showDebug == true) return;
      _showDebug = true;
      notifyListeners();
      return;
    }
  }
}
