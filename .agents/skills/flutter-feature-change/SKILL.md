---
name: flutter-feature-change
description: Implement a new feature or a coordinated behavior change across domain, data access, state, DI or navigation layers in this Flutter template or a derived application. Do not use for read-only investigation, behavior-preserving file decomposition, or an isolated styling or message edit.
---

# Change a Flutter feature

Input: requested behavior, target feature and any supplied data contract. Output: a coherent feature change with affected contracts and evidence of verification.

Use `dart-flutter:flutter-apply-architecture-best-practices` for general layer roles under the [plugin rules](../../../AGENTS.md#dart-and-flutter-plugin). This workflow owns integration with the scaffold's feature folders, `control` and existing DI.

## Workflow

1. Read the current `git status` and relevant diff, then inspect the affected implementation and its callers. Identify existing work to preserve, the feature owner and the observable behavior requested. If prior investigation exists, verify its source references against the current checkout; use [flutter-change-discovery](../flutter-change-discovery/SKILL.md) when the task first requires evidence for planning rather than implementation.
2. Resolve the public domain contract and acceptance scenarios before implementing dependent behavior. Use [parallel investigation](../../../AGENTS.md#parallel-investigation) for independent unknowns. Read the relevant [architecture guide](../../../docs/architecture/overview.md); distinguish available infrastructure from conventions for future features. Check for an existing helper, component or service before adding one. Identify changed producers, consumers, resource ownership and navigation boundaries.
3. Load only the guide for each affected mechanism:
   - Endpoint, mapping, repository or storage: [data access](../../../docs/development/data-access.md).
   - State transitions, retry or filtering: [controllers](../../../docs/development/controllers.md).
   - Rendering or forms: [UI](../../../docs/development/ui.md).
   - Messages or locale-aware formatting: [localization](../../../docs/development/localization.md). For ARB or generated API changes, follow [flutter-localization](../flutter-localization/SKILL.md).
4. Bind the changed contracts to the scaffold's actual DI lifetime and navigation. Check initial, loaded and failure behavior at the changed boundary, plus repeated operations or concurrency where affected. Do not add missing scaffold services merely because a guide describes their intended conventions.
5. Review the full changed dependency graph, including new files, imports/exports, route entry points, generated consumers and relevant documentation. Search for obsolete references when replacing a symbol or contract. Select regression cases using the [testing guide](../../../docs/development/testing.md) and perform applicable [project verification](../../../AGENTS.md#verification). Recommend behavioral tests for the user to run; do not invoke them.
6. Complete [mandatory independent review](../../../AGENTS.md#mandatory-independent-review) before handing off a substantial change. Give the reviewer the original behavior request, contracts, final diff and check evidence; resolve findings and have affected fixes reviewed. Report the resulting behavior, review status and checks actually performed, distinguishing static verification from runtime observations and remaining unknowns.

## Stop conditions

If source and requirements leave an essential domain contract ambiguous, ask for that specific decision before implementing dependent behavior. For a custom controller handler or a new dependency, follow the approval boundary in the owning guide/root; this Skill does not grant an exception.
