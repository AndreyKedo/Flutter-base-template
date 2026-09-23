# Controllers, state and filters

Read when changing controllers/state, retry, concurrency or filtering. The main files are in `lib/feature/<feature>/controller/`; state may be included through `part`. Wiring and lifetime are covered by the [architecture](../architecture/overview.md), and data loading by [data access](data-access.md).

## Normative requirements

- For a new list, use sealed state with `InitialLoading`, `ErrorLoading`, `Idle`. The loaded list/tree belongs to Idle, not the base state. An initial loading failure without data produces ErrorLoading. This list contract does not describe every state machine in the application.
- If a repeated operation fails while data is already displayed, retain Idle. Deliver the error message to the UI through the mechanism defined for the feature; do not replace loaded data with an empty error state. The scaffold has no ready-made shared channel for these messages.
- Prefer `DroppableControllerHandler`; choose another standard handler from `control` when different concurrency semantics are needed. A custom controller handler requires user approval. Droppable skips new calls while an operation is running; it does not queue them.
- One public method represents one operation; do not combine different operations through behavior flags. Use `fetch` or `initialize` for initial loading. Refresh, update, navigation and continuation have separate methods.
- Do not store application state or busy flags in ordinary controller fields. Fields for dependencies and lifecycle resources, such as debounce, are distinct from hidden application state. Displaying operations is covered by the [UI guide](ui-localization.md#operations-and-forms).
- Do not add an `isDisposed` check solely before `setState`. Lifecycle checks remain relevant for other actions after `await`, callbacks and BuildContext access. Verify `setState` and handler behavior against the installed version of `control`; guarding notifications does not cancel the operation or its side effects.
- A filter is a separate immutable value; `FilteringController` changes it, and `ListController.update(filter)` receives the complete filter. Normalization and value semantics belong to the [Dart conventions](../DEVELOPMENT.md#value-types-and-collection-ownership).

## Current implementation and usage

[InitializationController](../../lib/feature/application/controller/initialization_controller.dart) is an existing example of a `StateController` with `DroppableControllerHandler`: `initialize` invokes the dependency builder, publishes the container on success and an error state through the `error` callback. [InitializationState](../../lib/feature/application/controller/initialization_state.dart) is included through `part` and has separate initial/idle/error variants. This is an initialization example, not a ready-made controller for lists, filters or retaining data after a repeated operation fails.

The controller is created and disposed through `ControllerScope` in [ApplicationWidget](../../lib/feature/application/widget/application.dart). The UI can observe it through `context.watchOf<T>()`; the observer for diagnostic events is connected in [AppDependencyBuilder](../../lib/feature/application/di/app_dep_builder.dart).

For a new asynchronous interaction, explicitly determine what should happen if another call arrives before the previous one finishes. Droppable can skip a filter change during loading. If the UI must apply the latest input, align UI/controller coordination with that behavior; do not automatically replace the handler with a universal queue. Debounce and other resources are disposed by their owner.

The `control` version is pinned in [pubspec.lock](../../pubspec.lock). Before using an unfamiliar API or relying on a lifecycle assumption, inspect the local source of the installed version according to the [API verification rules](../DEVELOPMENT.md#verifying-unfamiliar-sdksapis).

## Current template state / exceptions

Application-specific list/filter controllers and a shared mechanism for one-time UI errors are not yet available. `InitializationCoordinator` displays the splash for both initial and error states; an error state alone does not imply the presence of error UI or a retry button. Do not carry this behavior into a new list as a requirement.

## Verification and completion

For affected operations, select scenarios covering initial success/failure, retry, retaining data after a repeated operation fails, another call during a pending request and completion after disposal. For filtering, cover debounce/reset and application of the latest user input; for pagination, cover an explicit request for a single page and cursor advancement.

Verification techniques are described in the [testing guide](testing.md); commands and execution restrictions are defined in [AGENTS.md](../../AGENTS.md#verification).
