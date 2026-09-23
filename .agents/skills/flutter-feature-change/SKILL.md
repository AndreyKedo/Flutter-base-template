---
name: flutter-feature-change
description: Add or change a feature in this Flutter template or an application derived from it across domain, data access, state, DI or navigation layers. Use for a new feature or a coordinated change across layers, not an isolated styling or message edit.
---

# Change a Flutter feature

Input: requested behavior, target feature and any supplied data contract. Output: a coherent feature change with its affected contracts and verification results.

## Workflow

1. Identify the domain operation and affected layers. Read the relevant part of the [architecture guide](../../../docs/architecture/overview.md), then inspect the available implementation and its callers. Resolve the public domain contract before adding implementation; a documented convention is not evidence that a helper or feature already exists.
2. Load only the guide for each affected mechanism:
   - Endpoint, mapping, repository or storage: [data access](../../../docs/development/data-access.md).
   - State transitions, retry or filtering: [controllers](../../../docs/development/controllers.md).
   - Rendering or forms: [UI](../../../docs/development/ui-localization.md).
   - Message changes: follow the localization workflow linked from that UI guide.
3. Work from the agreed contract through the affected data/state layers to their consumers. Create only the needed layers, wire the relevant DI lifetime and connect screens to the application's actual navigation. Check initial, loaded and failure behavior at the boundary changed by the task.
4. Select regression cases using the [testing guide](../../../docs/development/testing.md), then perform applicable [project verification](../../../AGENTS.md#verification). Recommend behavioral tests for the user to run; do not invoke them. Report the resulting behavior and any unresolved failure.

## Stop conditions

If source and requirements leave an essential domain contract ambiguous, ask for that specific decision before implementing the dependent behavior. For a custom controller handler or a new dependency, follow the approval boundary in the owning guide/root; this Skill does not grant an exception.
