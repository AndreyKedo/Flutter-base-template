# Flutter application template

Flexible base flutter application project structure.

### Documentation and AI guidance

- [AGENTS.md](AGENTS.md) — AI working rules, verification and routing to guides and local skills.
- [Architecture](docs/architecture/overview.md) — template structure, initialization, DI and navigation.
- [Dart conventions](docs/DEVELOPMENT.md) — syntax, value semantics and collection ownership.
- [Data access](docs/development/data-access.md), [controllers](docs/development/controllers.md), [UI and localization](docs/development/ui-localization.md), and [testing](docs/development/testing.md) — guidance for the affected layer.
- [Feature changes](.agents/skills/flutter-feature-change/SKILL.md) and [localized messages](.agents/skills/flutter-localization/SKILL.md) — local AI workflows.

Guides distinguish requirements for new work from the current scaffold. Commands run from the repository root unless stated otherwise; Markdown links are relative to their containing file.

### How run

1. Clone this repository via `git clone`.
2. Decide which platforms your app will be running on.
3. Run `flutter create . --org com.yourdomain --platforms ios,android,... or nothing if you are writing an app for each platform` in your terminal.
4. Run `flutter pub get` to install all dependencies.
5. Run `flutter run` to run your app.
6. Here you go, start coding!

### Package renaming

To rename the package to your own name, use the provided script:

```bash
./rename_package.sh --new-name your_new_package_name
```

For more options, see [scripts/README.md](scripts/README.md)
