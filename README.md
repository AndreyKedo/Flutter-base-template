# Starter template

Flutter template project

## Description

Project use FVM for manage Flutter framework version

## Getting Started

This project is a starting point for a Flutter application.
Very simple template for build application

## Automation

Use `make help` for getting more info.

Available VS Code tasks! Look [Tasks](.vscode/tasks.json)

## Structure

Project structure

### [common](lib/src/common)

- Localization, extensions, assets, enviroment.
- Settings controller and settings service.
- Runner - run application inside guarded zone and log events. Show Splash screen or Error screen.
- Dependency scope - simple dependency provider.
- Scope - abstract class for your scope implementation
- AppWrapper - wrap your application widget for provide dependency.

### [feature](lib/src/feature)

- app - general entry point in your app.

## Used base packages

### State managment

- [bloc](https://pub.dev/packages/bloc)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)

### Navigation

- [go_router](https://pub.dev/packages/go_router)

### Localization

- [intl](https://pub.dev/packages/intl),

### Storage and database

- [drift](https://pub.dev/packages/drift),
- [sqlite3_flutter_libs](https://pub.dev/packages/sqlite3_flutter_libs)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

### Generation

- [json_serializable](https://pub.dev/packages/json_serializable)
- [json_annotation](https://pub.dev/packages/json_annotation)

### Utils

- [flutter_gen_runner](https://pub.dev/packages/flutter_gen_runner)
- [logging](https://pub.dev/packages/logging)
- [collection](https://pub.dev/packages/collection)
- [path_provider](https://pub.dev/packages/path_provider)
- [path](https://pub.dev/packages/path)

### Platform help plugins

- [package_info_plus](https://pub.dev/packages/package_info_plus)

## How to guides

### How run

1. Clone this repository via `git clone`.
2. Decide which platforms your app will be running on.
3. Run `flutter create . --org com.yourdomain --platforms ios,android,... or nothing if you are writing an app for each platform` in your terminal.
4. Run `flutter pub get` to install all dependencies.
5. Run `flutter run` to run your app.
6. Here you go, start coding!
