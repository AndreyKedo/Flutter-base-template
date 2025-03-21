import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_template/src/common/localization/localization.dart';
import 'package:starter_template/src/feature/settings/settings_controller.dart';
import 'package:starter_template/src/feature/settings/settings_service.dart';
import 'dependency_storage.dart';

Future<DependencyStorage> $initializedDependency() async {
  final preferences = await SharedPreferences.getInstance();

  final settingsController = SettingsController(
    SettingsService(
      SharedPreferencesAsync(),
      computeDefaultLocale(),
    ),
  );

  await settingsController.initialize();

  return DependencyStorage(
    sharedPreferences: preferences,
    settingsController: settingsController,
  );
}
