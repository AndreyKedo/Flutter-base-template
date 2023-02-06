import 'package:flutter/material.dart';
import 'package:starter_template/src/common/extensions/build_context.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/common/widget/application.dart';
import 'presentation/navigation/app_router.dart';
import 'di.dart';

//Export DI Container and dependency
export 'di.dart';
export 'presentation/screen/splash_screen.dart';

class Application extends AppWrapper<WebDependencyStorage> {
  Application({super.key, required super.dependencyFactory});

  final GoAppNavigator navigator = GoAppNavigator.create(navKey: GlobalKey());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      onGenerateTitle: (context) => context.localized.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: navigator(),
    );
  }
}
