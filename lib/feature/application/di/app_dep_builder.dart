import 'package:control/control.dart';
import 'package:flutter/services.dart';
import 'package:starter_template/core/di.dart';
import 'package:starter_template/core/entity/inline_controller_observer.dart';
import 'package:starter_template/core/environment.dart';
import 'package:starter_template/core/logger.dart';
import 'package:starter_template/core/network/http_overrides.dart';
import 'package:starter_template/core/network/user_agent_builder.dart';
import 'package:starter_template/core/services/platform_info/platform_info_provider.dart';
import 'package:starter_template/core/services/platform_info/platform_info_provider_impl.dart';
import 'package:starter_template/feature/application/di/app_dep_container.dart';

/// Строит зависимостей приложения из списка шагов.
class AppDependencyBuilder extends DependencyBuilder<ApplicationDependency, AppDependencyContext> {
  AppDependencyBuilder()
    : super(
        steps: [
          (
            name: 'Flutter framework setup',
            callback: (_) async {
              await SystemChrome.setPreferredOrientations([.portraitDown, .portraitUp]);

              if (Flavor.current == .staging) {
                AppLogger.enableLogger(excludeLogger: {'GoRouter'});
                AppLogger.r.config(Environment.current.toString());
              }

              // Логирование событий для [StateController]
              final stateControllerLogger = AppLogger.named('StateManager');
              Controller.observer = InlineControllerObserver(
                didCreate: (controller) {
                  stateControllerLogger.d('$controller.onCreate');
                },
                didDispose: (controller) {
                  stateControllerLogger.d('$controller.onDispose');
                },
                didError: (controller, exception, stackTrace) {
                  stateControllerLogger.e('$controller.onError', exception, stackTrace);
                },
              );
            },
          ),
          (
            name: 'Plugin/Service setup',
            callback: (context) async {
              context.platformInfoProvider = await PlatformInfoProviderImpl.ensureInfo();
            },
          ),
          (
            name: 'SetupHttp',
            callback: (context) async {
              final info = context.platformInfoProvider;

              final package = info.package;
              final device = info.device;

              final userAgentBuilder = UserAgentBuilder()
                  .appName(package.appName.replaceAll(' ', ''))
                  .version('${package.version}+${package.buildNumber}')
                  .deviceModel(device.model)
                  .osName(device.os)
                  .osVersion(device.osVersion);

              // final systemProxyConfig = Flavor.current == .staging ? await SystemProxyProvider().getConfig() : null;
              // if (systemProxyConfig != null) {
              //   AppLogger.r.i('System proxy enabled: $systemProxyConfig');
              // }
              // Применяем переопределения для HTTP клиента.
              AppHttpOverrides.ensure(
                userAgentResolver: userAgentBuilder.build,
                //    systemProxyEnvironment: systemProxyConfig?.toEnvironment(),
              );
            },
          ),
        ],
        create: (context) {
          return _ApplicationContainer(appInfoProvider: context.platformInfoProvider);
        },
        context: AppDependencyContext(),
      );
}

/// Объект который выступает в роли контекста для создания зависимостей.
///
/// **Все поля этого объекта объявлены как "ленивые"** - это значит, что перед попыткой получить
/// значение их нужно проинициализировать.
class AppDependencyContext implements DependencyBuilderContext {
  late PlatformInfoProvider platformInfoProvider;
}

/// Контейнер с глобальными зависимостями для всех модулей.
class _ApplicationContainer implements ApplicationDependency {
  _ApplicationContainer({required this.appInfoProvider});

  // MARK: Instances

  @override
  final PlatformInfoProvider appInfoProvider;

  @override
  void dispose() {}
}
