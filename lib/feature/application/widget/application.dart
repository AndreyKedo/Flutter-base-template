import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:starter_template/core/actions/clipboard_action.dart';
import 'package:starter_template/core/actions/launch_url_action.dart';
import 'package:starter_template/core/build_context_ext.dart';
import 'package:starter_template/core/entity/types.dart';
import 'package:starter_template/feature/application/controller/initialization_controller.dart';
import 'package:starter_template/feature/application/widget/app_entry.dart';
import 'package:starter_template/feature/application/widget/initialization_coordinator.dart';
import 'package:starter_template/feature/development/screen/development_screen.dart';

class ApplicationWidget extends StatelessWidget {
  const ApplicationWidget({required this.create, super.key});

  final ControllerCreateCallback<InitializationController> create;

  @override
  Widget build(BuildContext context) {
    return ControllerScope<InitializationController>(
      create,
      lazy: false,
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
          localizationsDelegates: context.lcl.localizationsDelegates,
          supportedLocales: context.lcl.supportedLocales,
          actions: {
            ...WidgetsApp.defaultActions,
            LaunchUrlIntent: LaunchUrlAction(),
            ClipboardIntent: ClipBoardAction(),
          },
          builder: (context, child) {
            const splash = Placeholder();
            return Stack(
              children: [
                Positioned.fill(
                  child: InitializationCoordinator(splashScreen: splash, child: child!),
                ),
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
