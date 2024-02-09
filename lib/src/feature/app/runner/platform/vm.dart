// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';

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

  late final Logger logger = Logger('IO runner');

  @override
  Logger get log => logger;

  @override
  FutureOr<Factory<DependencyStorage>> initialization() async {
    if (EnvironmentConfig.env.isQa) {
      log.level = Level.SEVERE;
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
