import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_template/src/common/widget/dependency_scope.dart';
import 'package:starter_template/src/feature/settings/settings_controller.dart';

final class DependencyStorage implements IDependenciesStorage {
  final SharedPreferences sharedPreferences;
  final SettingsController settingsController;

  const DependencyStorage({
    required this.sharedPreferences,
    required this.settingsController,
  });

  @override
  void close() {
    settingsController.dispose();
  }
}
