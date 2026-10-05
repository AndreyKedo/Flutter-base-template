# Controllers and state

Read when changing controllers, state transitions, asynchronous operations or concurrency. The main files are in `lib/feature/<feature>/controller/`; state may be included through `part`. Wiring and lifetime are covered by the [architecture](../architecture/overview.md), and data loading by [data access](data-access.md).

A controller is a finite state machine implemented with the `control` package. Its `state` must fully describe the current state of the process it manages. Immutable fields may hold dependency references, configuration and immutable entities. The controller must not have secondary mutable state outside `state`: independent flags or other hidden data that track operation status or determine state transitions.

Public asynchronous methods act as events: each method executes its operation through `handle` and publishes state transitions through `setState`. The feature contract determines the states and permitted transitions.

## Normative requirements

- Extend `StateController<S>` from `control`. Define a finite set of immutable state variants and the transitions allowed for each event. State must describe valid combinations of data and operation status; do not impose one universal set of variants on every controller. State value semantics and collection ownership follow the [Dart conventions](../DEVELOPMENT.md#value-types-and-collection-ownership).
- Immutable controller fields are allowed: `final` references to dependencies, immutable configuration and immutable entities. A repository held through a `final` reference may manage its own mutable data; the restriction concerns hidden state of the controller itself.
- Do not store secondary mutable controller state outside `state`, including independent busy flags, counters or data that track the managed process or determine its transitions. A `final` reference to a collection or object must not be used to hide such mutable state. Lifecycle resources may be held solely to manage their lifetime and must not encode application state. Internal state and lifecycle fields managed by `control` are the package's responsibility.
- Each public event method is asynchronous and executes its operation through its own `handle` call. Keep the operation's sequence and state transitions in that method; handle its failure through the handler's `error` callback. Await asynchronous work belonging to the operation so that `handle` tracks its completion and errors.
- One public method represents one event. Do not route different events through a universal private method with many parameters, callbacks or behavior flags that select their logic. Small helpers for a concrete reusable step are allowed; they must not hide the entire event implementation.
- Define success and failure transitions explicitly. If a failed repeated operation leaves previously displayed data valid, retain that data in state. Deliver transient error messages through the mechanism defined for the feature; the scaffold has no ready-made shared channel for them. Displaying operation status is covered by the [UI guide](ui.md#operations-and-forms).
- Choose a standard controller handler from `control` according to the required behavior when another event arrives during an operation. Determine whether the new call is skipped, queued or executed concurrently, and how its result affects state. A custom controller handler requires user approval; do not implement concurrency with mutable controller fields.
- Do not add an `isDisposed` check solely before `setState`. Lifecycle checks remain relevant for other actions after `await`, callbacks and BuildContext access. Verify `setState` and handler behavior against the installed version of `control`; guarding notifications does not cancel the operation or its side effects.

## Current implementation and usage

[InitializationController](../../lib/feature/application/controller/initialization_controller.dart) demonstrates this structure: it extends `StateController`, holds a `final` dependency and uses `DroppableControllerHandler`. Its asynchronous `initialize` method invokes the dependency builder through `handle`, publishes the resulting state through `setState` and handles failure through the `error` callback. [InitializationState](../../lib/feature/application/controller/initialization_state.dart) is included through `part` and defines the states for this operation.

The controller is created and disposed through `ControllerScope` in [ApplicationWidget](../../lib/feature/application/widget/application.dart). The UI can observe it through `context.watchOf<T>()`; the observer for diagnostic events is connected in [AppDependencyBuilder](../../lib/feature/application/di/app_dep_builder.dart).

The `control` version is pinned in [pubspec.lock](../../pubspec.lock). Before using an unfamiliar API or relying on a lifecycle assumption, inspect the local source of the installed version according to the [API verification rules](../DEVELOPMENT.md#verifying-unfamiliar-sdksapis).

## Current template state / exceptions

The template provides an initialization example, not a complete implementation of every controller scenario. `InitializationCoordinator` displays the splash for both initial and error states; an error state alone does not imply the presence of error UI or a retry action. These are properties of the existing initialization flow, not requirements for other state machines.

## Verification and completion

First check that `state` fully describes the current state of the managed process and that controller fields contain no independent mutable flags or other hidden state of that process. Immutable dependency references, configuration and immutable entities are valid controller fields. For each affected event, verify its own implementation through `handle`, the permitted starting states, intermediate transitions, success and failure behavior, and the resulting data. Include repeated calls, another event during a pending operation and completion after disposal where relevant.

Verification techniques are described in the [testing guide](testing.md); commands and execution restrictions are defined in [AGENTS.md](../../AGENTS.md#verification).
