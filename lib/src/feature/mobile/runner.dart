import 'package:flutter/widgets.dart' show runApp;
import 'package:logging/logging.dart' show Logger;
import 'package:starter_template/src/common/model/dependency_storage.dart';

import 'package:starter_template/src/common/runner/runner.dart';

import 'app.dart';

final Logger logger = Logger('Mobile runner');

/// Runner Singleton class
class Runner with IRunner {
  static final Runner _internalSingleton = Runner._internal();
  factory Runner() => _internalSingleton;
  Runner._internal();

  @override
  Logger get log => logger;

  @override
  void onAppRun(DependencyFactory<IDependenciesStorage>? factoryDependency) {
    runApp(const MobileApplication());
  }
}
