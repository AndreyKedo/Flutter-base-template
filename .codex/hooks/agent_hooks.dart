import 'dart:convert';
import 'dart:io';

import 'test_policy.dart';
import 'workspace.dart';

Future<void> main() async {
  var event = '';
  var continued = false;
  try {
    // Parse Codex's documented stdin envelope, never execute text from it.
    final decoder = utf8.decoder;
    final stream = decoder.bind(stdin);
    final input = await stream.join();
    final payload = jsonDecode(input) as Map<String, dynamic>;
    event = payload['hook_event_name'] as String;
    continued = payload['stop_hook_active'] == true;
    final tool = payload['tool_name'] as String? ?? '';
    final arguments = Map<String, dynamic>.from(payload['tool_input'] as Map? ?? {});
    if (event == 'PreToolUse') {
      final reason = forbiddenTestReason(tool, arguments);
      if (reason != null) {
        emit({
          'hookSpecificOutput': {
            'hookEventName': event,
            'permissionDecision': 'deny',
            'permissionDecisionReason': '$reason Tests may only be run by the user (AGENTS.md).',
          },
        });
        return;
      }
    }

    // Preserve the initial dirty checkout as a baseline; never reset on compact/resume.
    final cwd = payload['cwd'] as String;
    final root = repositoryRoot(cwd);
    final session = payload['session_id'] as String;
    final response = withStateLock(root, (directory) {
      final file = sessionFile(directory, session);
      final exists = file.existsSync();
      if (!exists && event == 'Stop') throw StateError('No baseline: hooks did not observe this session before edits');
      final snapshot = workspaceSnapshot(root);
      final state = exists
          ? readObject(file)
          : <String, dynamic>{
              'version': stateVersion,
              'baseline': snapshot,
              'observed': snapshot,
              'pending': <String>[],
            };
      if (state['version'] != stateVersion) throw StateError('Unsupported hook state version');
      observeChanges(state, snapshot);

      // Only Stop assesses completion; subagent completion is deliberately not gated.
      var result = <String, dynamic>{};
      if (event == 'Stop') result = completionDecision(directory, state, snapshot, continued);
      if (event == 'SessionStart') {
        result = {
          'hookSpecificOutput': {
            'hookEventName': event,
            'additionalContext':
                'Repository hooks forbid agent-run tests. Before completing edits, run '
                'dart .codex/hooks/verify.dart -- <explicit task files> from the repository root. '
                'This records format/analysis/docs/diff checks for the current content. '
                'Choose only owned task files; see docs/development/agent-hooks.md. '
                'A failed or unavailable check must be reported as incomplete, never passed.',
          },
        };
      }
      writeObject(file, state);
      return result;
    });
    emit(response);
  } catch (error) {
    // Keep failure visible. Do not advertise an unavailable guard as successful.
    final message = 'Repository hook unavailable: $error. Verification is incomplete; report this limitation.';
    if (event == 'Stop' && !continued) {
      emit({'decision': 'block', 'reason': message});
    } else {
      emit({'systemMessage': message});
    }
  }
}

Map<String, dynamic> completionDecision(
  Directory directory,
  Map<String, dynamic> state,
  Map<String, String> snapshot,
  bool continued,
) {
  // A read-only turn requires no new verification, even with pre-existing dirty files.
  final pending = List<String>.from(state['pending'] as List);
  if (pending.isEmpty) return {};
  final receiptFile = File('${directory.path}/verification.json');
  var fresh = false;
  if (receiptFile.existsSync()) {
    final receipt = readObject(receiptFile);
    final checked = Set<String>.from(receipt['files'] as List? ?? []);
    final verified = Map<String, dynamic>.from(receipt['workspace'] as Map? ?? {});
    fresh =
        receipt['version'] == stateVersion &&
        receipt['passed'] == true &&
        pending.every(checked.contains) &&
        sameSnapshot(verified, snapshot);
  }
  if (fresh) {
    state['baseline'] = snapshot;
    state['pending'] = <String>[];
    state.remove('lastBlockedWorkspace');
    return {};
  }

  // One continuation per unchanged snapshot, with no infinite retry loop on failures.
  final lastBlocked = Map<String, dynamic>.from(state['lastBlockedWorkspace'] as Map? ?? {});
  final repeated = sameSnapshot(lastBlocked, snapshot);
  final paths = pending.join(', ');
  final reason =
      'Current verification is missing or stale for: $paths. '
      'From the repository root run dart .codex/hooks/verify.dart -- <explicit task files>, '
      'including deleted/new task paths. Do not run tests. Recheck the integrated version after edits. '
      'If checks cannot complete or concurrent user edits are outside your scope, '
      'report the blocker and verification as incomplete; do not claim readiness.';
  state['lastBlockedWorkspace'] = snapshot;
  if (continued || repeated) {
    return {'continue': false, 'stopReason': reason, 'systemMessage': 'Verification incomplete. $reason'};
  }
  return {'decision': 'block', 'reason': reason};
}

void emit(Map<String, dynamic> response) {
  stdout.writeln(jsonEncode(response));
}
