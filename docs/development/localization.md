# Localization and formatting

Read when changing visible messages, their parameters, translations or locale-aware number/date formatting. Message sources belong in `lib/l10n/`; generated localization code and handwritten wrappers are in `lib/core/localizations/`. Widget presentation follows the [UI guide](ui.md). Selecting and persisting the application language, as well as platform integration, follow the [architecture](../architecture/overview.md#normative-requirements).

## Normative requirements

### Localization contract

- Obtain visible strings, hints, validation messages, statuses and plurals through `context.lcl` from the [BuildContext extensions](../../lib/core/build_context_ext.dart).
- Pass message values through placeholders; express a finite set of variants of one message through ICU `select`, and quantities through `plural`/`selectordinal`. Keep variants of one semantic message in a single parameterized key.
- Use locale-aware number/date formatting. Dates have [IntlHelperContextWrapper](../../lib/core/localizations/intl_wrapper.dart), and message parameters have ARB metadata. When changing formatting, verify the specific helper's behavior for the required locale.
- Do not automatically translate user-provided names or unknown server values. The meaning of the specific message determines the fallback for an unknown value.
- Keep keys, parameters and meaning consistent across all supported locale sources; an ARB file's name does not establish the quality of its translations.

## Sources and workflow

- [app_en.arb](../../lib/l10n/app_en.arb) and [app_ru.arb](../../lib/l10n/app_ru.arb) are the current message sources; `apiError` demonstrates the `statusCode` placeholder.
- [l10n.yaml](../../l10n.yaml) defines the ARB directory, generated output and untranslated-message report file. Outputs are in `lib/core/localizations/`; handwritten `localization_wrapper.dart` and `intl_wrapper.dart` are not generated files.
- [ApplicationLocalizationWrapper](../../lib/core/localizations/localization_wrapper.dart) provides messages and compatible Material delegates. Create the wrapper only with a context whose tree already provides `AppLocalizations`.
- [ApplicationWidget](../../lib/feature/application/widget/application.dart) connects the localization delegates and supported locales to `MaterialApp`.

This guide owns message and formatting requirements. Follow [flutter-localization](../../.agents/skills/flutter-localization/SKILL.md) for ARB changes, generator execution, and verification of the generated API and its consumers.

## Current template state / exceptions

- `AppEntry` and debug screens contain strings directly in Dart; this is not an example to follow for new user-facing messages.
- Some messages in the current ARB files do not match the file's language. Check both locales when changing a message; existing text is not a translation reference and does not require automatically expanding the task to all localization.

## Verification and completion

For messages, cover variants, quantities and locale transitions; for formatting, cover the user's locale. When text changes affect layout, apply the [UI checks](ui.md#verification-and-completion) for long text and text scaling. The widget harness is described in the [testing guide](testing.md); general commands are defined in [AGENTS.md](../../AGENTS.md#verification).
