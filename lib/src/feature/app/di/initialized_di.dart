import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/common/logic/bloc/bloc_observer.dart';
import 'package:starter_template/src/common/logic/bloc/transformers.dart';
import 'package:starter_template/src/common/logic/settings/settings_controller.dart';
import 'dependency_storage.dart';

Future<Factory<DependencyStorage>> $initializedDependency(Logger log) async {
  //Configure bloc
  Bloc.transformer = dropEventTransformer();
  Bloc.observer = AppBlocObserver(log);

  final packageInfo = await PackageInfo.fromPlatform();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  final defaultLocale = AppLocalizationsX.computeDefaultLocale();
  final settingsController = SettingsController(SettingsService(preferences, defaultLocale));

  return Factory(() => DependencyStorage(
      sharedPreferences: preferences, settingsController: settingsController, packageInfo: packageInfo));
}
