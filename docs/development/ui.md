# UI

Read when changing widgets/screens, themes, layout or forms. Files belong in `lib/feature/<feature>/screen/`, `widget/` and the shared library in `lib/core/widget/`. The Material boundary is defined in [AGENTS.md](../../AGENTS.md#architecture-invariants), and collection ownership in the [Dart conventions](../DEVELOPMENT.md#value-types-and-collection-ownership).

## Normative requirements

Obtain user-visible text, including validator errors, through localization. Message requirements and locale-aware formatting are defined in the [localization guide](localization.md#localization-contract).

### Rendering and styling

- Do not perform business computations, sorting or data filtering in `build`; create widgets from prepared state. Enumerating elements for rendering is not the same as processing domain data. Avoid unnecessary `toList`/`toSet`; use simple conditions for small fixed sets.
- Widgets whose responsibility is to display information must accept individual display properties as constructor parameters and must not accept domain models/entities. For example, a user card accepts `String name`, `DateTime createdAt` and `int age`; extracting these values from a `User` and performing domain computations belong to the calling code. Pass only the properties needed for rendering.
- Use semantic theme colors, available theme text styles and existing icons. Do not change a token's meaning to obtain a desired shade. Check that a shared component or spacing system exists in the current application before using it.
- Define the style of a new reusable component through a shared style object + `Theme.extension` + a widget-level `style` override. Feature-specific colors belong to the component's style, with light/dark support.
- A label/color/highlight change must preserve the remaining rendering and layout.

### Operations and forms

Display loading according to the operation state defined by the controller/UI contract. Do not duplicate it with a hidden busy flag in the controller. The template has no ready-made global loading overlay; the task and available state determine the specific presentation and how repeated actions are blocked. Adding a shared loading service is not a mandatory step for every feature.

Forms use [ValidatorChain](../../lib/core/utils/validation_chain.dart) with localized messages. Supply appropriate messages to validators that must display an error: a `null` result indicates that there is no error. Transport/domain contract validation remains at the [data boundary](data-access.md); a field validator does not replace it.

## Current implementation

- [ApplicationWidget](../../lib/feature/application/widget/application.dart) contains the current light/dark themes based on `ColorScheme.fromSeed`. The scaffold has no ready-made collection of component styles or shared spacing API.

## Current template state / exceptions

- `ApplicationWidget` sets `ThemeMode.dark`. A light theme in the source does not mean the application already has a theme switcher.

## Verification and completion

Check that information-display widget constructors accept individual display properties and have no domain-model/entity parameters. For changed UI, select checks for the relevant states, light/dark themes, long text and text scaling when affected. For message or formatting changes, also apply the [localization checks](localization.md#verification-and-completion). The widget harness is described in the [testing guide](testing.md); general commands are defined in [AGENTS.md](../../AGENTS.md#verification).
