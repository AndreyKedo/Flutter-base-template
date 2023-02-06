import 'dart:async';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart' show setUrlStrategy, PathUrlStrategy;
import 'package:logging/logging.dart' show Logger;

import 'package:starter_template/src/common/runner/runner.dart';

import 'app.dart';

final Logger logger = Logger('Web runner');

/// Runner Singleton class
class Runner with IRunner {
  static final Runner _internalSingleton = Runner._internal();
  factory Runner() => _internalSingleton;
  Runner._internal();

  @override
  Logger get log => logger;

  @override
  FutureOr<DependencyFactory<WebDependencyStorage>?> initialization(RunnerConfig config) async {
    setUrlStrategy(PathUrlStrategy());
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settingsController = SettingsController(SettingsService(preferences));
    await settingsController.loadSettings();
    return () => WebDependencyStorage(sharedPreferences: preferences);
  }

  @override
  void onAppRun(DependencyFactory? factoryDependency) {
    if (factoryDependency != null) {
      runApp(Application(dependencyFactory: factoryDependency as DependencyFactory<WebDependencyStorage>));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace, ShowWidget show) {
    show(MaterialApp(
      title: 'Not found page',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Material(child: Center(child: SelectableText(error.toString()))),
    ));
  }

  @override
  void onLoading(ShowWidget show) {
    show(const SplashScreen());
  }
}
