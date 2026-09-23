---
name: flutter-localization
description: Change localized messages in this Flutter template or an application derived from it from ARB inputs through Flutter generation to Dart consumers. Use for message additions, ICU parameter changes or regeneration after ARB edits, not theme-only changes or platform language-service work.
---

# Change localized messages

Input: intended message, its dynamic values and affected UI. Output: matching locale sources, generated API and consumers, with verification results.

## Workflow

1. Find the existing message and its consumers. Read the [message contract](../../../docs/development/ui-localization.md#localization-contract) to decide whether to reuse a key or change its parameters. Read [l10n.yaml](../../../l10n.yaml) for the actual input/output paths and inspect the supported locale sources.
2. Edit the relevant source entries in [lib/l10n](../../../lib/l10n/), including parameter metadata and each supported locale. Check the message language and meaning for each locale. Account for the current source and generated diff before generation so unrelated work remains identifiable.
3. From the repository root, run `flutter gen-l10n`. Generated localization files are outputs: do not edit them manually. If generation fails, correct the reported ARB/configuration mismatch within the task; do not patch generated Dart to hide it.
4. Inspect the generated signatures and update affected consumers. Check key/parameter parity across locales and review the configured untranslated-message report when produced. Handwritten wrappers in the output directory remain source files, not generator outputs.
5. Apply [project verification](../../../AGENTS.md#verification) to affected Dart. For a behavioral message change, select relevant locale/variant cases using the [testing guide](../../../docs/development/testing.md) for the user to run. Review the source, generated and consumer diff together.

## Stop conditions

Clarify an ambiguous message meaning or parameter contract before changing callers. If the installed generator cannot process the project sources, report the incompatibility instead of changing SDK/dependencies or editing generated output as a workaround.
