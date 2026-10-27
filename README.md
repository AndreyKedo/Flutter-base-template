# Flutter application template

Flexible base flutter application project structure.

### Documentation and AI guidance

`docs/` holds maintained technical documentation about implemented mechanisms, architecture and adopted project practices. Saved temporary agent work belongs in `build/agent-artifacts/<task-id>/`; it is ignored by Git and may be removed when build output is cleaned. See [documentation and task artifacts](AGENTS.md#documentation-and-task-artifacts).

- [AGENTS.md](AGENTS.md) — AI working rules, verification and routing to guides and local skills.
- [Architecture](docs/architecture/overview.md) — template structure, initialization, DI and navigation.
- [Dart conventions](docs/DEVELOPMENT.md) — syntax, value semantics and collection ownership.
- [Data access](docs/development/data-access.md), [controllers](docs/development/controllers.md), [UI](docs/development/ui.md), [localization](docs/development/localization.md), and [testing](docs/development/testing.md) — guidance for the affected mechanism.
- [Read-only discovery](.agents/skills/flutter-change-discovery/SKILL.md), [feature changes](.agents/skills/flutter-feature-change/SKILL.md), [behavior-preserving refactoring](.agents/skills/flutter-behavior-preserving-refactor/SKILL.md), and [localized messages](.agents/skills/flutter-localization/SKILL.md) — local AI workflows.

Guides distinguish requirements for new work from the current scaffold. Commands run from the repository root unless stated otherwise; Markdown links are relative to their containing file.

Standard Dart/Flutter procedures come from the official **Dart and Flutter** plugin configured below. Local guidance defines the template-specific contracts and integration rules; see [plugin usage](AGENTS.md#dart-and-flutter-plugin).

### Codex setup

[.codex/config.toml](.codex/config.toml) registers the official [Flutter marketplace](https://github.com/flutter/agent-plugins) and enables `dart-flutter@dart-flutter` for this repository. The plugin provides Dart/Flutter skills and the Dart MCP server configuration; no local copies are needed. The Flutter SDK must be installed and `dart` available on `PATH` for the MCP server.

Open the repository root in a Codex client that supports project marketplace configuration and confirm project trust. Codex reads project settings only for trusted projects; marketplace refresh can download/install the configured plugin into the shared user cache. Cloning the repository alone does not install it. See OpenAI's [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) and [repo plugin settings](https://developers.openai.com/plugins/build/plugins#enable-or-disable-a-plugin-for-a-repo).

If the plugin is still unavailable, run the official installation commands:

```bash
codex plugin marketplace add flutter/agent-plugins
codex plugin add dart-flutter@dart-flutter
```

These commands register/install the plugin in the user's Codex environment; the repository configuration controls its use for this project. Verify installation with `codex plugin list --marketplace dart-flutter --json` from the repository root: the plugin should be both installed and enabled. Start a new Codex session in the repository if its skills/tools are not yet visible. The project's prohibition on agent-run tests also applies to plugin skills and MCP tools.

The repository also includes [Codex hooks](.codex/hooks.json) for known forbidden test launches and current verification before completion. After trusting the project, open `/hooks` in the Codex CLI and review/trust the hook definitions; changed definitions require renewed trust. These hooks use `dart` and `git` on `PATH` with a POSIX shell (macOS/Linux). See [agent hooks](docs/development/agent-hooks.md) for the verifier command, coverage, state storage and limitations. Installation alone does not establish that hooks are active in an existing session.

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
