---
name: flutter-change-discovery
description: Investigate current Flutter source and collect evidence for an audit or change plan in this template or a derived application. Use for read-only exploration, architecture questions or fact gathering before planning; it does not authorize implementation.
---

# Discover the current change surface

Input: question, symptom or proposed behavior and a read-only scope. Output: source-backed findings, affected contracts and bounded options for subsequent planning.

## Workflow

1. Establish the current checkout and inspect `git status` plus the relevant diff. Treat uncommitted source as current evidence; distinguish existing work from the proposed change. Follow the [project boundaries](../../../AGENTS.md#safety--boundaries).
2. Locate the feature owner, entry points, callers and relevant shared infrastructure. Load only the applicable [routed guides](../../../AGENTS.md#context-routing). Trace the affected path through actual data, state, DI, navigation and UI rather than inferring it from directory names.
3. Separate normative requirements from implemented behavior and documented exceptions. Verify linked examples and helpers before relying on them: this scaffold does not already provide every service or feature described by its guides. For unfamiliar package behavior, follow [API verification](../../../docs/DEVELOPMENT.md#verifying-unfamiliar-sdksapis).
4. Classify findings as confirmed by current source, observed at runtime, inferred, or unresolved. Keep supplied API documentation, DTO expectations and actual response evidence distinct when relevant. Attach file/line references to material findings and identify missing evidence without guessing.
5. Present the current behavior, likely change surface, dependencies and bounded alternatives. State any product or contract decisions required and suitable verification scenarios. An earlier plan or a source-based audit is not proof that a change is implemented or works at runtime.

## Boundaries

Keep the investigation read-only: do not edit files, install packages, generate outputs, run formatters, tests or commands that mutate project/tool state. A proposed next step is not authorization to implement it or contact a live API. Read-only diagnostic tools may be used within the requested scope; distinguish their actual results from recommendations.
