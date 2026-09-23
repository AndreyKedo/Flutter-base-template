# Behavioral verification

Read when adding/changing tests or selecting checks for affected behavior. Commands and execution restrictions belong to [AGENTS.md](../../AGENTS.md#verification): only the user runs tests. Selecting scenarios and writing tests do not authorize the agent to run them.

## Normative requirements

- The purpose of testing is to find scenarios where substantive application logic can behave incorrectly and prevent identified defects from recurring. Before adding a test, identify the specific scenario, possible error and observable result. Look for these in user actions, boundary values, state transitions, asynchronous operation ordering and local data handling. The existence of a class or method, test counts and coverage percentages do not by themselves justify a new test.
- Test behavior and regressions, not implementation structure, declaration names or mechanical repetition of translations. Localized widget behavior may be tested when it matters to the task.
- Build tests around substantive logic in the UI, controllers, domain and services: interactions, state transitions, computations, rules, operation coordination and error handling.
- Do not test the client-server contract: endpoints, HTTP methods, header and request-body contents, response schemas, or requiredness and nullability of server DTO fields. Do not create tests for mechanical serialization/deserialization, straightforward field copying in mappers or standard type casts.
- Test the data layer only when it contains substantive application logic or a local data source. Examples include local search, page merging, deduplication, caching and invalidation, local fallback selection and operation retries. Verify that logic's results and behavior, not the transport format.
- For local data sources, verify reading, writing, deletion, migrations, local schema compatibility and recovery from errors within the affected behavior. Do not duplicate the internal implementation of a third-party database or plugin in application tests.
- Use domain objects and test doubles in UI, controller, domain and service tests. Do not introduce JSON, server DTOs or mappers solely to prepare test data. A class's placement in the data layer or the name `Mapper` does not by itself justify a test.
- For localized UI, use delegates compatible with [ApplicationLocalizationWrapper](../../lib/core/localizations/localization_wrapper.dart) and the Material imports specified in the root instructions. Choose the smallest check capable of detecting the relevant regression.

## Choosing a level and tools

| Change | Suitable scenarios |
|---|---|
| Server DTOs/APIs and mechanical mapping | Do not create separate tests for the client-server contract or field copying |
| Domain | Computations, data merging, nullable copy, equality, collection protection where source mutation is a real risk |
| Substantive data-layer logic | Search, page merging, caching, invalidation, fallback, failure and retry |
| Local data source | Reading, writing, deletion, migrations and recovery of local data |
| Controller/concurrency | State transitions, retaining data on error, another call during an operation, completion after disposal |
| Initialization and DI | Build success/failure, retry after failure, lifetime of created resources |
| Platform service | Observable behavior through a fake platform interface or a test-double adapter |
| Localized UI | Locale changes, semantic variants, quantities and displayed behavior |
| Navigation/UI interaction | Screen transitions, returning, action availability and text scaling |
| Theme/rendering | Light/dark themes, reusable component styles and states |

The table lists options for checking changed behavior, not already implemented modules or a requirement to create all coverage in advance.

### Async and widget harness

Paths under `test/` usually mirror those under `lib/`. For an asynchronous scenario, control operation completion through a fake/`Completer` to check the pending state and the subsequent event separately. In widget tests, use `pump` for debounce intervals; complete the lifecycle of created controllers/clients through teardown. Data must be synthetic.

Build a localized harness on `MaterialApp` from `material_ui` with `AppLocalizations.supportedLocales`, `AppLocalizations.delegate` and `GlobalMaterialLocalizations.delegates` from `material_ui`. The [generated API](../../lib/core/localizations/app_localizations.dart) and [wrapper](../../lib/core/localizations/localization_wrapper.dart) define the current names and delegates. Access `context.lcl` from a descendant context under the localized tree, not while creating the root `MaterialApp`. For controllers/DI, provide only the dependencies needed by the behavior being checked.

## Current template state / exceptions

- [test/widget_test.dart](../../test/widget_test.dart) contains an empty `main`; the template has no ready-made behavioral tests or fixtures yet. This file does not establish coverage.
- The [pre-commit script](../../bin/pre_commit.dart) runs whole-project formatting and Flutter tests when Dart files are staged. This is an existing user workflow, not a verification method authorized for the agent; the root restriction also covers indirect test execution.
- A similar class or example does not establish that a harness is suitable: verify current constructors, interfaces and scope dependencies before using it.

## Completion criteria

Each new test has an identifiable error it can detect; its assertions distinguish correct behavior from a regression. Data is synthetic and asynchronous resources are released. Report the checks actually performed and tests recommended for the user; the presence of a test must not be presented as a successful run.
