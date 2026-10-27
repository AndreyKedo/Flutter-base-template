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

## Parallel investigation

Apply the [root trigger and role settings](../../../AGENTS.md#parallel-investigation) and [native delegation mechanism](../../../AGENTS.md#delegation-mechanism) before tracing independent paths. Assign each explorer one question, bounded paths, relevant constraints and an expected evidence summary. For example, one traces data and state transitions while another traces UI consumers and navigation; both use the current checkout and preserve the read-only boundary below.

Require file/symbol references, discovered contracts and dependencies, and a distinction between confirmed facts, inference and missing evidence. The main agent continues non-overlapping investigation, waits for all required findings, resolves disagreements against source and combines the results into one change map. Do not independently repeat the same broad scan or treat an explorer's summary as runtime verification. Explorers do not spawn further agents.

## Output and boundaries

Return findings in the current task by default. If the user requests a saved report, follow [documentation and task artifacts](../../../AGENTS.md#documentation-and-task-artifacts): use `build/agent-artifacts/<task-id>/` unless the user specifies another location. This authorizes only the requested report, not changes to source, configuration or maintained documentation. An explorer assigned a strictly read-only scope returns content to its parent for saving.

Keep the investigation read-only apart from that requested report: do not edit project files, install packages, generate code, run formatters, tests or commands that mutate project/tool state. A proposed next step is not authorization to implement it or contact a live API. Read-only diagnostic tools may be used within the requested scope; distinguish their actual results from recommendations.
