import 'package:starter_template/src/common/model/dependency_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Export dependency
export 'package:starter_template/src/common/logic/settings_controller.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:starter_template/src/common/model/dependency_storage.dart';

class WebDependencyStorage implements IDependenciesStorage {
  final SharedPreferences sharedPreferences;
  const WebDependencyStorage({required this.sharedPreferences});

  @override
  Future<void> close() async {}
}
