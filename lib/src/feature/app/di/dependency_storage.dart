import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_template/src/common/logic/settings/settings_controller.dart';
import 'package:starter_template/src/common/model/dependency_storage.dart';

final class DependencyStorage implements IDependenciesStorage {
  final SharedPreferences sharedPreferences;
  final SettingsController settingsController;
  final PackageInfo packageInfo;

  const DependencyStorage(
      {required this.sharedPreferences, required this.settingsController, required this.packageInfo});

  @override
  void close() {
    settingsController.dispose();
  }
}
