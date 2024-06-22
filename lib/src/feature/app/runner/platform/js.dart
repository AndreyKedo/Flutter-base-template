import 'dart:async';

import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart' show setUrlStrategy, PathUrlStrategy;
import 'package:logging/logging.dart' show Level, Logger;
import 'package:starter_template/src/common/constant/enviroment.dart';
import 'package:starter_template/src/common/runner/runner.dart';
import 'package:starter_template/src/feature/app/di/dependency_storage.dart';
import 'package:starter_template/src/feature/app/di/initialized_di.dart';
import 'package:starter_template/src/feature/app/widget/app.dart';

/// Runner Singleton class
class Runner extends IRunner<DependencyStorage> {
  static final Runner _internalSingleton = Runner._internal();

  factory Runner() => _internalSingleton;

  Runner._internal();

  late final Logger logger = Logger('Web runner');

  @override
  Logger get log => logger;

  @override
  FutureOr<Factory<DependencyStorage>> initialization() async {
    if (EnvironmentConfig.kDebug) {
      log.info('CanvasKit path ${const String.fromEnvironment('FLUTTER_WEB_CANVASKIT_URL')}');
    }
    // ignore: prefer_const_constructors
    setUrlStrategy(PathUrlStrategy());

    if (EnvironmentConfig.env.isQA) {
      log.level = Level.WARNING;
    }

    return $initializedDependency(log);
  }

  @override
  void onAppRun(Factory<DependencyStorage> factoryDependency) {
    runApp(Application(dependencyFactory: factoryDependency));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {}

  @override
  void onLoading() {}
}
