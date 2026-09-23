# Flutter base template — project context

## Project

Reusable Flutter application scaffold. Shared infrastructure is in `lib/core/`, features in `lib/feature/`, ARB sources in `lib/l10n/`, tests in `test/`. Platform projects are created for each derived application; setup and package renaming are described in the [README](README.md).

## Sources of truth

- SDK and direct dependencies: [pubspec.yaml](pubspec.yaml); resolved versions: [pubspec.lock](pubspec.lock); lint/format rules: [analysis_options.yaml](analysis_options.yaml).
- Current source and applicable tests establish implemented behavior. Guides distinguish **normative requirements** for changes from the **current template state / exceptions**. A convention for a future feature does not mean that feature already exists; an existing deviation does not replace a requirement.
- Localization inputs and generated outputs are configured in [l10n.yaml](l10n.yaml). Use the package name from `pubspec.yaml` after renaming the template.

## Architecture invariants

- Preserve `control`, `http`/`http_middleware_client` and the existing [DependencyContainer / DependencyBuilder](lib/core/di.dart). Module boundaries, data flow and the current navigation setup are described in the [architecture guide](docs/architecture/overview.md#normative-requirements).
- Material imports use `package:material_ui/material_ui.dart`; do not mix incompatible Material theme types or delegates.
- Add only the layers and infrastructure required by the requested behavior. Inspect what the template actually provides before relying on a helper or service.

## Working rules

Before changing Dart, read [syntax and structure](docs/DEVELOPMENT.md#syntax-and-structure). Load other sections, guides or Skills only for the affected mechanism using the routing table below; each document owns its specialized requirements.

## Verification

- Safe targeted checks for the affected area may run without separate confirmation. Tests may be run only by the user; do not invoke test commands, including through scripts or hooks.
- For changed Dart: `dart format <changed-files>`, then `flutter analyze` or `dart analyze`. Recommend relevant behavioral tests from [testing guidance](docs/development/testing.md) for the user to run.
- For Markdown/Skills only: check local links, source references, consistency and Skill frontmatter/triggers; no Flutter tests or code generation.
- Review the task diff and run `git diff --check -- <changed-paths>`. Do not weaken checks to obtain a passing result; report unrelated failures separately.

## Safety / boundaries

- Do not read `.env*`, signing keys, keystores, certificates, `google-services.json`, `GoogleService-Info.plist`, `key.properties`, secret directories or user keys.
- Third-party `pub.dev` packages require user approval/review. Python scripts require a brief justification and user permission.

## Definition of Done

The affected contracts and routed requirements are satisfied, applicable verification is complete, and the result states any failures or checks not performed. Source-backed guides remain consistent when the documented behavior changes.

## Context routing

| Task | Read/use |
|---|---|
| Add/change a feature across layers | [flutter-feature-change](.agents/skills/flutter-feature-change/SKILL.md) |
| DI, module boundaries, routing or platform services | [Architecture](docs/architecture/overview.md) |
| API, DTO, mapper, repository or persistence | [Data access](docs/development/data-access.md) |
| Controller, state, retry or filters | [Controllers](docs/development/controllers.md) |
| UI, theme, forms or formatting | [UI and localization](docs/development/ui-localization.md) |
| Add/change localized messages or their generated API | [flutter-localization](.agents/skills/flutter-localization/SKILL.md) |
| Tests, fakes or widget harnesses | [Testing](docs/development/testing.md) |
