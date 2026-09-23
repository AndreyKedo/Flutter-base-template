# Flutter template architecture

Read when changing feature boundaries, DI, initialization, navigation or a platform service. Use [context routing](../../AGENTS.md#context-routing) to load implementation conventions for individual layers.

## Normative requirements

- Shared infrastructure and reusable domain types belong in `lib/core/`; feature code belongs in `lib/feature/<feature>/`. Stable areas such as `core` and `application` must not depend directly on entities from individual application features.
- A domain model expresses domain meaning and the application's API. Transport wrappers, JSON fields and continuation markers belong to DTOs; conversion to the domain model goes through a mapper/Converter.
- Create only the feature parts that are needed: `widget`, `screen`, `util`, `entity`, `navigation`, `dto`, `api`, `datasource`, `mapper`, `di`, `controller`, `repository`, `service`. A directory's presence in another module does not make that layer mandatory. A separate use-case layer is not required.
- Assemble feature dependencies in the feature's DI container and application-level dependencies in the application container. Define resource ownership and its `dispose`/`close` at the same level. A container does not imply that all its dependencies are singletons.
- Connect navigation to the existing application graph, keeping it separate from the data layer and services. Use the current routing mechanism for new screens; choosing a different router and changing dependencies is a separate change subject to the [approval boundaries](../../AGENTS.md#safety--boundaries).

## Current implementation

### Modules and initialization

| Area | Responsibility and source |
|---|---|
| `core` | DI, HTTP, utilities, basic types, platform info, localization wrappers and scopes; [DI](../../lib/core/di.dart), [BuildContext extensions](../../lib/core/build_context_ext.dart) |
| `application` | Dependency creation and root UI; [AppDependencyBuilder](../../lib/feature/application/di/app_dep_builder.dart), [ApplicationDependency](../../lib/feature/application/di/app_dep_container.dart), [ApplicationWidget](../../lib/feature/application/widget/application.dart) |
| `development` | Debug screens and log viewing; [DevelopmentScreen](../../lib/feature/development/screen/development_screen.dart), [LogsScreen](../../lib/feature/development/screen/logs_screen.dart) |

[main.dart](../../lib/main.dart) creates `InitializationController` and schedules `initialize` after the first frame. The [controller](../../lib/feature/application/controller/initialization_controller.dart) invokes the builder and publishes a state containing either the container or an error. The builder configures Flutter, logging and the controller observer, retrieves platform information and installs HTTP overrides with a User-Agent.

[InitializationCoordinator](../../lib/feature/application/widget/initialization_coordinator.dart) provides the initialized `ApplicationDependency` through `DependencyContainer.wrap`. This method uses [InheritedScope](../../lib/core/widget/inherited_scope.dart) and delegates container disposal to the scope. `ControllerScope` owns the controller it creates; the container is accessed through `context.getDepend<T>()`. Before extending DI, verify the lifetime against the actual creation and disposal sites.

### Navigation and UI

`ApplicationWidget` uses `MaterialApp`, a root `Navigator` and an observer for the debug button. [AppEntry](../../lib/feature/application/widget/app_entry.dart) is a placeholder entry screen. Debug screens open through `Navigator` and `MaterialPageRoute`, providing an example of the current navigation. The template has no mandatory separate router or prebuilt graph of application features.

Themes and locale delegates are connected in `ApplicationWidget`; requirements for the Material boundary, styling and localized messages are described in the [UI guide](../development/ui-localization.md).

### Data flow and infrastructure

For new features, the main response path is `JSON → DTO → mapper → domain → controller/state → UI`. The UI calls a controller, the controller calls a repository, and the repository implementation calls an API and, when needed, a datasource. The API implements the HTTP contract, the mapper performs conversion, and the repository defines loading and storage behavior. See [data access](../development/data-access.md) for details.

The template provides [RestApi](../../lib/core/network/rest_api.dart), [AppHttpClient](../../lib/core/network/app_http_client.dart) and a [JSON codec](../../lib/core/utils/json_parser.dart). Application-specific APIs, repositories and storage have not yet been assembled; the current `ApplicationDependency` exposes only `PlatformInfoProvider`. The presence of an HTTP utility does not mean a ready-to-use client is available through DI.

[AppLogger](../../lib/core/logger.dart) and the controller observer provide diagnostics; the builder enables logging for staging. Environment settings belong to [environment.dart](../../lib/core/environment.dart). Platform projects and the package name are configured according to the [README](../../README.md); application-specific environment settings do not imply that platform build flavors have already been created.

## Current template state / exceptions

- `InitializationCoordinator` displays the same splash screen during initial loading and on error. A separate error screen and retry UI are not yet implemented.
- Application-specific modules, authorization and local storage are absent. The guides describe conventions for adding them when required by a task, not existing services.
- Existing themes and debug screens do not demonstrate every requirement for future reusable UI components.

## Completion criteria

The change has a clear domain-contract owner, dependency direction, screen connection and resource lifetime. Checks are selected for the affected initialization/navigation transitions; requirements and implemented behavior remain distinct. Commands are defined in [AGENTS.md](../../AGENTS.md#verification).
