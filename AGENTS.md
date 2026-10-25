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

## Dart and Flutter plugin

Use applicable **Dart and Flutter** skills for standard SDK/framework procedures; keep local guidance focused on project contracts and integration. Resolve skills by name from the active catalog, without machine-specific paths. If unavailable, follow [API verification](docs/DEVELOPMENT.md#verifying-unfamiliar-sdksapis). Plugin examples must respect this project's architecture, SDK, analyzer settings and verification restrictions; they do not authorize library/DI replacement, dependency installation, test runs or out-of-scope fixes.

## Subagents

Apply the [official subagent guidance](https://learn.chatgpt.com/docs/agent-configuration/subagents?surface=ide) as follows:

- Use subagents when a substantial task has independent, bounded parts that benefit from parallel work. Handle small or tightly coupled changes with one agent; delegation adds token and coordination costs.
- Prefer delegation for code exploration, documentation research, log analysis and focused reviews. Keep requirements, architectural decisions and integration with the main agent.
- Give each subagent a clear objective, relevant context, owned files or scope, permission to edit or a read-only constraint, allowed checks and expected output. Request concise findings with file references, risks and verification results rather than raw logs.
- Parallel edits require non-overlapping file ownership and agreed shared contracts. Handle shared files, generated outputs and dependent changes sequentially; do not overwrite another agent's or the user's work.
- Keep inherited model and reasoning settings unless the user or applicable instructions explicitly select another supported configuration.
- Every subagent must follow this file, relevant routed guides, Skills and session permissions. Delegation does not relax the [verification](#verification) or [safety](#safety--boundaries) rules, including the test-command restriction.
- Continue independent work while subagents run; wait for required results before integration and the final response. The main agent reviews their findings and combined diff, resolves conflicts, completes applicable checks and reports remaining limitations.

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
| Read-only investigation, current-state audit or evidence for planning | [flutter-change-discovery](.agents/skills/flutter-change-discovery/SKILL.md) |
| Add/change a feature across layers | [flutter-feature-change](.agents/skills/flutter-feature-change/SKILL.md) |
| Split/move files or refactor existing code while preserving behavior | [flutter-behavior-preserving-refactor](.agents/skills/flutter-behavior-preserving-refactor/SKILL.md) |
| DI, module boundaries, routing or platform services | [Architecture](docs/architecture/overview.md) |
| API, DTO, mapper, repository or persistence | [Data access](docs/development/data-access.md) |
| Controller, state, retry or filters | [Controllers](docs/development/controllers.md) |
| UI, theme, forms or layout | [UI](docs/development/ui.md) |
| Localized text, ICU parameters or number/date formatting | [Localization](docs/development/localization.md) |
| Add/change ARB messages or their generated API | [flutter-localization](.agents/skills/flutter-localization/SKILL.md) |
| Tests, fakes or widget harnesses | [Testing](docs/development/testing.md) |
