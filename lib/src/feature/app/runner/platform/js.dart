// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:starter_template/src/common/runner/runner.dart';
import 'package:starter_template/src/common/widget/dependency_scope.dart';
import 'package:starter_template/src/feature/app/di/dependency_storage.dart';
import 'package:starter_template/src/feature/app/di/initialized_di.dart';
import 'package:starter_template/src/feature/app/widget/application_widget.dart';
import 'package:starter_template/src/feature/app/widget/error_application_widget.dart';

class RunnerImpl extends Runner<DependencyStorage> {
  static final RunnerImpl _internalSingleton = RunnerImpl._internal();
  factory RunnerImpl() => _internalSingleton;

  RunnerImpl._internal();

  @override
  Logger createRunnerLogger() => Logger('WebRunner');

  @override
  Future<DependencyStorage> initialization() {
    usePathUrlStrategy();
    return $initializedDependency();
  }

  @override
  void onApp(DependencyStorage dependency) {
    runApp(
      DependenciesScope<DependencyStorage>.value(
        value: dependency,
        child: ApplicationWidget(storage: dependency),
      ),
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    runApp(ErrorApplicationWidget(error: error, stackTrace: stackTrace));
  }
}
