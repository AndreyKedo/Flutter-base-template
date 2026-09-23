# UI and localized messages

Read when changing widgets/screens, themes, forms, visible text or formatting. Files belong in `lib/feature/<feature>/screen/`, `widget/` and the shared library in `lib/core/widget/`. The Material boundary is defined in [AGENTS.md](../../AGENTS.md#architecture-invariants), and collection ownership in the [Dart conventions](../DEVELOPMENT.md#value-types-and-collection-ownership).

## Normative requirements

### Rendering and styling

- Do not perform business computations, sorting or data filtering in `build`; create widgets from prepared state. Enumerating elements for rendering is not the same as processing domain data. Avoid unnecessary `toList`/`toSet`; use simple conditions for small fixed sets.
- Use semantic theme colors, available theme text styles and existing icons. Do not change a token's meaning to obtain a desired shade. Check that a shared component or spacing system exists in the current application before using it.
- Define the style of a new reusable component through a shared style object + `Theme.extension` + a widget-level `style` override. Feature-specific colors belong to the component's style, with light/dark support.
- A label/color/highlight change must preserve the remaining rendering and layout.

### Operations and forms

Display loading according to the operation state defined by the controller/UI contract. Do not duplicate it with a hidden busy flag in the controller. The template has no ready-made global loading overlay; the task and available state determine the specific presentation and how repeated actions are blocked. Adding a shared loading service is not a mandatory step for every feature.

Forms use [ValidatorChain](../../lib/core/utils/validation_chain.dart) with localized messages. Supply appropriate messages to validators that must display an error: a `null` result indicates that there is no error. Transport/domain contract validation remains at the [data boundary](data-access.md); a field validator does not replace it.

### Localization contract

- Obtain visible strings, hints, statuses and plurals through `context.lcl` from the [BuildContext extensions](../../lib/core/build_context_ext.dart).
- Pass message values through placeholders; express a finite set of variants of one message through ICU `select`, and quantities through `plural`/`selectordinal`. Keep variants of one semantic message in a single parameterized key.
- Use locale-aware number/date formatting. Dates have [IntlHelperContextWrapper](../../lib/core/localizations/intl_wrapper.dart), and message parameters have ARB metadata. When changing formatting, verify the specific helper's behavior for the required locale.
- Do not automatically translate user-provided names or unknown server values. The meaning of the specific message determines the fallback for an unknown value.
- Keep keys, parameters and meaning consistent across all supported locale sources; an ARB file's name does not establish the quality of its translations.

## Sources and workflow

- [ApplicationWidget](../../lib/feature/application/widget/application.dart) contains the current light/dark themes based on `ColorScheme.fromSeed`. The scaffold has no ready-made collection of component styles or shared spacing API.
- [app_en.arb](../../lib/l10n/app_en.arb) and [app_ru.arb](../../lib/l10n/app_ru.arb) are the current message sources; `apiError` demonstrates the `statusCode` placeholder.
- [l10n.yaml](../../l10n.yaml) defines the ARB directory, generated output and untranslated-message report file. Outputs are in `lib/core/localizations/`; handwritten `localization_wrapper.dart` and `intl_wrapper.dart` are not generated files.
- [ApplicationLocalizationWrapper](../../lib/core/localizations/localization_wrapper.dart) provides messages and compatible Material delegates. Create the wrapper only with a context whose tree already provides `AppLocalizations`.

This guide owns UI and message requirements. Follow [flutter-localization](../../.agents/skills/flutter-localization/SKILL.md) for ARB changes, generator execution, and verification of the generated API and its consumers; that procedure is not duplicated here.

Selecting and persisting the application language, as well as platform integration, belong to the [architecture](../architecture/overview.md). The message workflow does not create those services.

## Current template state / exceptions

- `AppEntry` and debug screens contain strings directly in Dart; this is not an example to follow for new user-facing messages.
- Some messages in the current ARB files do not match the file's language. Check both locales when changing a message; existing text is not a translation reference and does not require automatically expanding the task to all localization.
- `ApplicationWidget` sets `ThemeMode.dark`. A light theme in the source does not mean the application already has a theme switcher.

## Verification and completion

For changed UI, select checks for the relevant states, light/dark themes, long text and text scaling when affected. For messages, cover variants, quantities and locale transitions; for formatting, cover the user's locale. The widget harness is described in the [testing guide](testing.md); general commands are defined in [AGENTS.md](../../AGENTS.md#verification).
