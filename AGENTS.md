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

## Documentation and task artifacts

- `docs/` contains maintained technical documentation: project architecture and contracts, descriptions of implemented mechanisms, adopted development practices and project setup/operation instructions. Describe current behavior from source evidence; label normative practices separately from the implementation's current state.
- Update the relevant thematic guide when its documented mechanism or practice changes. Add a document only for reusable project knowledge that has no suitable existing home. An investigation may supply verified facts for a guide; distill those facts into the guide rather than copying the investigation or presenting a proposed mechanism as implemented.
- Keep task plans, hypotheses, research notes, audit/review reports, check logs, diagnostic screenshots and other temporary agent output out of `docs/`. Return concise findings in the current task by default; native subagents return them to their parent. When files are needed, save them under `build/agent-artifacts/<task-id>/`, creating a separate task directory only as needed, unless the user explicitly requests another location.
- `build/agent-artifacts/` is Git-ignored and disposable: cleaning build output can remove it. Do not commit these files or make maintained documentation, application code or configuration depend on them. Keep durable technical conclusions self-contained in the appropriate guide. Do not delete or overwrite another task's artifacts.
- This routing applies to temporary agent work. Source files, generated project outputs and tool-managed state keep their prescribed locations, including verification receipts under `.codex/.hook-state/`; do not move or fabricate those records.

## Dart and Flutter plugin

The repository's [.codex/config.toml](.codex/config.toml) declares the official `flutter/agent-plugins` marketplace and enables `dart-flutter@dart-flutter`. See [Codex setup](README.md#codex-setup) for trust, installation and verification. Use the plugin's bundled MCP configuration; do not duplicate its server or copy its skills into the repository.

Use applicable **Dart and Flutter** skills for standard SDK/framework procedures; keep local guidance focused on project contracts and integration. Resolve skills by name from the active catalog, without machine-specific paths. If unavailable, follow [API verification](docs/DEVELOPMENT.md#verifying-unfamiliar-sdksapis). Plugin examples must respect this project's architecture, SDK, analyzer settings and verification restrictions; they do not authorize library/DI replacement, dependency installation, test runs or out-of-scope fixes.

## Subagents

Apply the [official subagent guidance](https://learn.chatgpt.com/docs/agent-configuration/subagents?surface=ide) as follows:

- Apply the parallel-investigation and independent-review requirements below. Keep implementation of small or tightly coupled changes with one author; delegation adds token and coordination costs.
- Keep requirements, architectural decisions, integration and final verification with the main agent.
- Give each subagent a clear objective, relevant context, owned files or scope, permission to edit or a read-only constraint, allowed checks and expected output. Request concise findings with file references, risks and verification results rather than raw logs.
- Parallel edits require non-overlapping file ownership and agreed shared contracts. Handle shared files, generated outputs and dependent changes sequentially; do not overwrite another agent's or the user's work.
- Use the role profiles below for investigation and independent review. Other subagents inherit the parent's model and reasoning unless the task specifies otherwise.
- Every subagent must follow this file, relevant routed guides, Skills and session permissions. Delegation does not relax the [verification](#verification) or [safety](#safety--boundaries) rules, including the test-command restriction.
- Continue independent work while subagents run; wait for required results before integration and the final response. The main agent reviews their findings and combined diff, resolves conflicts, completes applicable checks and reports remaining limitations.

### Delegation mechanism

- Use the current runtime's native subagent tools (`spawn_agent`, for example `collaboration.spawn_agent`) to create child agents of the current task. Coordinate and wait through that same native tool family using its returned agent identifiers; results return to the parent task. The `.codex/agents/` profiles configure these child agents and do not request new user-owned chats.
- App chat tools such as `create_thread`, `fork_thread`, `send_message_to_thread` and `wait_threads` are not substitutes for native subagents. Do not use separate chats or nested Codex CLI sessions to emulate missing subagent tools. Creating, forking or messaging a separate chat requires the user's explicit request for that operation, limited to its stated purpose and stage; a request for a separate review chat does not authorize explorer chats.
- A native subagent can have its own visible agent thread. Identify it by the native spawn operation and parent/child relationship, not by its title, sidebar appearance or the word "thread".
- If native spawning is unavailable, fails, or cannot satisfy a required execution constraint, report the limitation and continue only work that can be done sequentially. Required independent review remains incomplete until an authorized independent reviewer completes it. Follow the existing review failure rules; do not replace missing delegation with chat creation or claim that self-review is independent review.

### Models and reasoning

| Role | Project profile | Model | Reasoning |
|---|---|---|---|
| Bounded investigation | [template_explorer](.codex/agents/template_explorer.toml) | `gpt-6-luna` | `high` |
| Independent review | [template_reviewer](.codex/agents/template_reviewer.toml) | `gpt-6.1-sol` | `high` |

These settings follow [OpenAI's role and reasoning guidance](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning), also described by [Amiga](https://amiga.ru/learn/codex-config/subagents). The reviewer uses `high` for logic and edge cases; the documentation's simpler reviewer example uses `medium`. The primary agent's model is unchanged.

Custom-agent files set both model and reasoning and override inherited/spawn defaults. If the client cannot select a named profile, explicitly pass its model, reasoning and instructions to a native subagent tool under the [delegation mechanism](#delegation-mechanism). For ambiguous exploration beyond the narrow explorer's scope, use `gpt-6.1-sol` with `high`. If a configured model is unavailable or the user requests different settings, use a generic native subagent with an available, supported model/effort and the same role instructions; report the actual choice. Do not silently rewrite model defaults. Role instructions do not create a separate read-only sandbox: all agents inherit session permissions.

### Parallel investigation

When a substantial investigation has at least two independent evidence paths, launch bounded read-only explorers through the [delegation mechanism](#delegation-mechanism) in parallel before implementing behavior that depends on their findings. Typical paths are data/domain/state and UI/callers/navigation; split by independent questions, not by file count. Start with two explorers and add more only for distinct useful work. Follow [flutter-change-discovery](.agents/skills/flutter-change-discovery/SKILL.md) for assignment and synthesis. Small lookups and dependent questions stay sequential. If native delegation is unavailable, follow the mechanism fallback and gather evidence sequentially without claiming a parallel investigation.

### Mandatory independent review

- Require independent review for changes to behavior or public contracts, state/concurrency/error handling, persistence, DI/resource lifetime/navigation, moves across file or module boundaries, localization parameters/generated APIs, or agent instructions/configuration that change execution behavior. Judge significance by risk, not line count. Pure formatting, spelling and equivalent wording changes do not require a separate reviewer.
- After integration and applicable checks, start a fresh `template_reviewer` that did not author the implementation or its plan, using the [delegation mechanism](#delegation-mechanism). Provide the original request, acceptance criteria, relevant guides, the comparison baseline, the complete task diff including new files, and check results. Identify unrelated user changes. Supply evidence rather than the author's conclusion that the change is correct.
- The reviewer inspects the final source and affected callers without editing, running tests, formatting, generating code or delegating further. It returns findings ordered by severity with file/line references and observable consequences, plus the reviewed scope and remaining uncertainties; an empty finding list is explicit. Source review and static checks do not establish runtime behavior.
- The main agent assesses findings, fixes confirmed issues and obtains a follow-up review of affected changes and interactions. Complete the review only when the final version has been reviewed and no material finding remains unresolved; identify pre-existing or out-of-scope issues separately. A reviewer/tool failure or unavailable delegation leaves review incomplete, not implicitly passed. Report the blocker and completed work; self-review cannot substitute for the required independent pass.
- Report review status, performed checks and unverified behavior in the final handoff. This requirement never authorizes tests, including tests invoked indirectly through scripts or hooks.

## Verification

- Safe targeted checks for the affected area may run without separate confirmation. Tests may be run only by the user; do not invoke test commands, including through scripts or hooks.
- For changed Dart: `dart format <changed-files>`, then `flutter analyze` or `dart analyze`. Recommend relevant behavioral tests from [testing guidance](docs/development/testing.md) for the user to run.
- For Markdown/Skills only: check local links, source references, consistency and Skill frontmatter/triggers; no Flutter tests or code generation.
- Review the task diff and run `git diff --check -- <changed-paths>`. Do not weaken checks to obtain a passing result; report unrelated failures separately.
- Record the automated checks with `dart .codex/hooks/verify.dart -- <explicit repository-relative task files>` from the repository root before completing edits. Include new and deleted task paths. This runner formats only the supplied existing Dart files, analyzes affected Dart, validates local inline Markdown links/required Skill metadata and JSON, and checks diff whitespace. It never runs tests or generators. It does not replace source review, other applicable checks, or independent review.
- [Repository hooks](docs/development/agent-hooks.md) reject known test launches and detect missing/stale verification receipts. Rerun the verifier after further edits. Choose task-owned files explicitly; never expand scope to concurrent user edits just to satisfy the gate. If hooks/checks fail or remain unavailable, state that verification is incomplete and identify the blocker. Do not bypass trust, disable hooks or manufacture a receipt to claim completion.

## Safety / boundaries

- Do not read `.env*`, signing keys, keystores, certificates, `google-services.json`, `GoogleService-Info.plist`, `key.properties`, secret directories or user keys.
- Third-party `pub.dev` packages require user approval/review. Python scripts require a brief justification and user permission.

## Definition of Done

The affected contracts and routed requirements are satisfied, applicable verification and required independent review are complete, and the result states any failures or checks not performed. Source-backed guides remain consistent when the documented behavior changes.

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
| Agent hooks, verification receipts or blocked completion | [Agent hooks](docs/development/agent-hooks.md) |
