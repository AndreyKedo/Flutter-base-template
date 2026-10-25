---
name: flutter-localization
description: Add or change messages, ICU parameters and Dart consumers in the Flutter template's existing localization setup. Apply its project contract and regeneration workflow; excludes initial localization setup, theme-only changes and platform language services.
---

# Integrate localized message changes

Use `dart-flutter:flutter-setup-localization` for ARB/ICU mechanics under the [plugin rules](../../../AGENTS.md#dart-and-flutter-plugin). Apply its content-editing guidance to this already configured scaffold. This skill owns the project integration below.

## Project integration

1. Apply the [message contract](../../../docs/development/localization.md#localization-contract) to the message and callers. [l10n.yaml](../../../l10n.yaml) owns paths and the untranslated-message report; preserve its output and `context.lcl` / `material_ui` integration. Account for existing source and generated changes.
2. After the ARB change, run `flutter gen-l10n` from the repository root, without substituting dependency installation. Handwritten localization and intl wrappers in the output directory remain source files. Resolve generation failures in ARB/configuration within scope; do not patch generated Dart.
3. Update callers to the changed generated signatures, check cross-locale key/parameter parity and actual message language, and review the untranslated-message report when produced. Review source, generated code and callers together. Apply [project verification](../../../AGENTS.md#verification); recommend relevant [locale/variant scenarios](../../../docs/development/testing.md) for the user to run.

## Stop conditions

Clarify an ambiguous message meaning or parameter contract before changing callers. If the installed generator cannot process the project sources, report the incompatibility instead of changing SDK/dependencies or editing generated output as a workaround.
