# Agent hooks

These repository hooks implement two safeguards from [AGENTS.md](../../AGENTS.md#verification): reject known agent test launches, and detect missing or stale automated verification before completion. Independent review remains a separate requirement; these hooks do not implement or certify it.

## Setup and trust

[.codex/hooks.json](../../.codex/hooks.json) is the only hook definition source in this repository. It uses synchronous `command` handlers for `SessionStart`, `PreToolUse`, `PostToolUse` and `Stop`. The scripts require Dart from the project's supported SDK and Git on `PATH`, with a POSIX shell (macOS/Linux). Resolve scripts from the Git root so a session can start in a subdirectory. Windows needs a reviewed command adaptation before enabling these definitions.

Trust the project in Codex, then use `/hooks` in the CLI to inspect and trust these definitions. Review script changes as well as definition changes; do not assume the definition's trust hash proves unchanged external script contents. Codex skips untrusted definitions. Do not use the hook-trust bypass flag. After setup, start a new session so `SessionStart` captures a baseline before edits. Confirm hook activation in the actual client; CLI availability does not establish desktop runtime behavior.

See OpenAI's [hook locations](https://learn.chatgpt.com/docs/hooks#where-codex-looks-for-hooks), [trust rules](https://learn.chatgpt.com/docs/hooks#review-and-trust-hooks), and [tool coverage](https://learn.chatgpt.com/docs/hooks#tool-coverage). Hooks from other active sources also run; these definitions do not replace them. Keep `[hooks]` out of this repository's config while using `hooks.json` to avoid duplicate handlers.

## Forbidden test launches

[test_policy.dart](../../.codex/hooks/test_policy.dart) examines the documented `Bash` command input before execution (`cmd` is accepted as a compatibility fallback). It recognizes these executable/subcommand combinations:

- `flutter test`, `flutter drive`, `dart test`, `dart run test[:entry]`, and `dart run integration_test[:entry]`.
- Their supported FVM forms, including `fvm spawn <version> flutter test`, plus `melos test` and `melos run test`.
- Direct or Dart/FVM execution of `bin/pre_commit.dart`, including absolute paths. This existing user script runs tests and whole-project formatting; it is not an agent verification method.
- Dart/Flutter MCP tools whose leaf name is `run_test` or `run_tests`, if exposed by the client.

The tokenizer handles simple POSIX commands, recognized `env`/`command`/`exec` prefixes, shell `-c`/`-lc`, separators, quoting, redirections and heredoc bodies. Mentioning a command in `echo`, a search, Markdown or an `apply_patch` payload is not a test launch. Formatting a file under `test/` is permitted. The policy never evaluates input or rewrites commands, and does not change user Git hooks or commands run directly by the user.

This is a guard against known accidental launches, not a shell interpreter or a security boundary. Aliases, functions, variables, substitutions, arbitrary scripts, other test entrypoints, unknown option forms and interactive input are not resolved. In particular, a Git hook or another script may launch tests without exposing that child command to Codex. The agent must still inspect relevant scripts/hooks before invoking them. `write_stdin` does not trigger another `PreToolUse`; specialized tool paths may bypass lifecycle hooks. Never use these gaps to circumvent the test restriction.

## Recording verification

From the repository root, pass the complete, explicit set of task-owned files:

```bash
dart .codex/hooks/verify.dart -- lib/feature/example/controller/example_controller.dart docs/development/controllers.md
```

The example paths must be replaced with actual task files. Include new files and deleted paths; directories, protected paths and symlinks are rejected. Absent paths are treated as deletions, and cannot satisfy a pending change for a different path. Do not include unrelated user edits to make a check pass.

[verify.dart](../../.codex/hooks/verify.dart) runs only a fixed set of checks:

1. Format supplied existing Dart files using the current Dart executable.
2. If Dart changed (including deletions), analyze the repository with `--fatal-infos`. Changes confined to `.codex/hooks/` use explicit analysis of that standalone directory; mixed changes analyze both, since hidden directories may otherwise be omitted.
3. Validate local inline Markdown links and heading anchors, required single-line Skill `name`/`description` metadata, and JSON syntax for supplied files. Full Markdown/YAML/TOML semantics, reference-style links, external URLs and instructional correctness remain review responsibilities.
4. Run `git diff --check --cached -- <files>` and `git diff --check -- <files>` separately for staged and unstaged tracked changes, and check new files for whitespace errors. An existing HEAD is required for the workspace fingerprint.

It checks process exit codes, never runs tests, never generates code, never installs packages, and never invokes `bin/pre_commit.dart`. Analyzer failures, including pre-existing ones, are reported; they are not silently accepted. It uses the SDK executable directly, not a Flutter/FVM wrapper. A successful command elsewhere or a statement in the final answer does not create verification evidence; rerun this fixed verifier to record it.

The verifier removes the previous receipt before checking and saves a new one only after all checks succeed. It fingerprints the observable checkout after formatting and again after checks; concurrent changes prevent a successful receipt. The receipt records file coverage, check names and the exact file contents observed. A direct SDK path may be used when the local `dart` launcher requires unrelated SDK cache writes.

## Freshness and completion

[agent_hooks.dart](../../.codex/hooks/agent_hooks.dart) and [workspace.dart](../../.codex/hooks/workspace.dart) maintain a baseline per Codex session, shared with its subagents. `SessionStart` captures the current contents, including existing uncommitted work. Resume/compaction do not reset an existing baseline; the first `PreToolUse` can initialize it if necessary. `PreToolUse` and `PostToolUse` observe changes, and `Stop` resamples independently so correctness does not depend on the undocumented shape or ordering of shell responses.

The gate compares the current contents with the baseline, including new/deleted files. Reverted changes no longer require a check. A read-only session is not blocked just because the checkout was already dirty. A successful gate advances the baseline. Existing unfinished work is retained across later turns and resumes.

A receipt must cover every observed changed path and match the current observable checkout, index and HEAD. Any further visible change invalidates it, including changes to dependencies, configuration or these scripts. This deliberately invalidates conservatively: a concurrent unrelated edit can require rechecking the task files. The hook cannot infer who authored a change. If the pending set contains another person's work, report the scope conflict rather than format or claim verification of their files. Do not reset the baseline to hide unfinished work.

On missing/stale evidence, `Stop` asks the agent to continue once. A repeated failure at the same contents, or `stop_hook_active`, produces an explicit incomplete-verification warning instead of an endless continuation loop. State remains pending. This bounded failure path is not a passing check; the final response must name the blocker and must not claim readiness. A missing/corrupt baseline or receipt also reports incomplete verification. A failed handler, unavailable Dart/Git or client timeout may not block Codex itself, so visible hook errors must never be treated as proof of enforcement.

## State and limitations

Local JSON observations, the verification receipt and a file lock live under `.codex/.hook-state/`, which is [Git-ignored](../../.gitignore). They contain paths and Git content hashes, not file contents or command transcripts. Never commit or manually fabricate these records. A short exclusive file lock and replacement writes serialize parent/subagent updates; lengthy checks run outside the lock. The last complete verifier receipt is used, so the primary agent must verify the integrated file set after parallel work.

Fingerprinting includes Git-visible tracked/untracked files, excluding ignored outputs, hook state and protected paths from the repository safety policy. It does not follow symlinks. Git submodules/symlinked tracked entries require manual handling and can make the gate unavailable. Changes only in ignored/protected files cannot be certified by this mechanism. Large checkouts can exceed the handler timeout; report that limitation instead of silently reducing coverage.

Hooks supplement the project rules. They do not prove semantic correctness, runtime/UI behavior, review independence, hook coverage in every client, or absence of forbidden execution through unobserved paths. Tests remain exclusively user-run, including behavioral validation of these hooks. Static analysis and source review must be reported separately from live hook execution.
