---
name: flutter-behavior-preserving-refactor
description: Physically split, move or reorganize existing Dart/Flutter code in this template or a derived application while preserving behavior. Use for requested thematic file decomposition or boundary cleanup; excludes research-only plans and new product behavior.
---

# Refactor while preserving behavior

Input: target code, requested structural change and behavior to preserve. Output: the completed file/dependency structure with updated consumers and verification evidence.

## Workflow

1. Inspect current `git status`, the relevant diff and the complete target code. Map declarations, imports/exports, `part` relationships, public callers and shared dependencies. Identify existing work to preserve and the requested structural boundary; use [flutter-change-discovery](../flutter-change-discovery/SKILL.md) if the task is only to investigate or plan.
2. Record the behavior affected by the move: public contracts, state transitions, side effects, navigation and resource creation/disposal where relevant. Load the owning [routed guides](../../../AGENTS.md#context-routing), including [architecture](../../../docs/architecture/overview.md) when changing dependency direction or ownership.
3. Choose thematic destination files around responsibilities and dependency direction. Define which declarations remain public and how private symbols remain accessible. Do not choose arbitrary file-size targets or introduce layers solely to shorten files; avoid mixing functional corrections into the refactor.
4. Move declarations physically, update imports/exports, `part` relationships and every affected consumer, preserving scope ownership and lifetimes. For a requested file split or replacement, remove the obsolete original file after migration; do not leave a compatibility barrel unless the public contract or the user requires it. Handle shared files and dependent moves sequentially.
5. Inspect the complete resulting dependency graph, including new files. Search for references to old paths and moved symbols; check orphaned files, duplicate implementations, missing exports and unintended dependency cycles. Compare behavior and resource ownership with the pre-change implementation, not just the moved text.
6. Apply [project verification](../../../AGENTS.md#verification) to all affected Dart, including newly created files. Select meaningful behavioral scenarios from the [testing guide](../../../docs/development/testing.md) for the user; do not invoke tests. Review the combined diff and report the structural result, performed checks and any unverified behavior.

## Scope changes

If preserving behavior requires an architectural or product decision beyond the requested move, identify the dependency and resolve that decision before changing dependent code. Existing deviations do not authorize incidental cleanup; documented conventions do not establish that missing infrastructure exists.
