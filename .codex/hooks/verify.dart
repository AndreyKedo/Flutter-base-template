import 'dart:convert';
import 'dart:io';

import 'workspace.dart';

void main(List<String> arguments) {
  try {
    // Require explicit ownership. Never choose every dirty file or run arbitrary commands.
    if (arguments.isEmpty || arguments.first != '--' || arguments.length == 1) {
      throw ArgumentError('Usage: dart .codex/hooks/verify.dart -- <repository-relative task files>');
    }
    final currentDirectory = Directory.current;
    final root = repositoryRoot(currentDirectory.path);
    final requested = arguments.skip(1);
    final files = <String>{};
    for (final path in requested) {
      final normalized = checkedPath(root, path);
      if (Directory('$root/$normalized').existsSync()) throw ArgumentError('Specify files, not directories: $path');
      files.add(normalized);
    }
    final before = workspaceSnapshot(root);
    final trackedResult = runGit(root, ['ls-files', '-z']);
    final trackedOutput = trackedResult.stdout as String;
    final trackedPaths = trackedOutput.split('\u0000');
    final tracked = trackedPaths.toSet();
    for (final path in files) {
      if (!before.containsKey(path) && !tracked.contains(path)) {
        stdout.writeln('Absent path included as a deletion: $path');
      }
    }

    // Invalidate old evidence before any attempted check, including a failed retry.
    withStateLock(root, (directory) {
      final receipt = File('${directory.path}/verification.json');
      if (receipt.existsSync()) receipt.deleteSync();
    });
    final checks = <String>[];
    final dartFiles = <String>[];
    var hasDart = false;
    var hooksOnly = true;
    for (final path in files) {
      if (!path.endsWith('.dart')) continue;
      hasDart = true;
      if (!path.startsWith('.codex/hooks/')) hooksOnly = false;
      if (before.containsKey(path)) dartFiles.add(path);
    }
    if (dartFiles.isNotEmpty) {
      runCheck(root, Platform.resolvedExecutable, ['format', ...dartFiles]);
      checks.add('dart format (explicit existing Dart files)');
    }
    final formatted = workspaceSnapshot(root);
    final allPaths = {...before.keys, ...formatted.keys};
    for (final path in allPaths) {
      if (before[path] != formatted[path] && !dartFiles.contains(path)) {
        throw StateError('Concurrent/out-of-scope change during formatting: $path. Retry after integration.');
      }
    }
    if (hasDart) {
      runCheck(root, Platform.resolvedExecutable, ['analyze', '--fatal-infos', if (hooksOnly) '.codex/hooks']);
      if (!hooksOnly && files.any((path) => path.startsWith('.codex/hooks/') && path.endsWith('.dart'))) {
        runCheck(root, Platform.resolvedExecutable, ['analyze', '--fatal-infos', '.codex/hooks']);
      }
      checks.add(hooksOnly ? 'dart analyze .codex/hooks' : 'dart analyze (repository)');
    }

    // Validate local documentation and JSON without network requests or generators.
    var links = 0;
    for (final path in files) {
      if (!formatted.containsKey(path)) continue;
      final file = File('$root/$path');
      if (path.endsWith('.md')) {
        final content = file.readAsStringSync();
        links += checkMarkdown(root, path, content);
        if (path.endsWith('/SKILL.md')) checkSkill(path, content);
      }
      if (path.endsWith('.json')) jsonDecode(file.readAsStringSync());
    }
    checks.add('local Markdown links/anchors ($links), required Skill metadata and JSON syntax');
    runCheck(root, 'git', ['diff', '--check', '--cached', '--', ...files]);
    runCheck(root, 'git', ['diff', '--check', '--', ...files]);
    for (final path in files) {
      if (!tracked.contains(path) && formatted.containsKey(path)) checkNewFileWhitespace(root, path);
    }
    checks.add('git diff --check (staged + unstaged); new-file whitespace');

    // The receipt is valid only if the whole observable checkout stayed unchanged.
    withStateLock(root, (directory) {
      final after = workspaceSnapshot(root);
      if (!sameSnapshot(formatted, after)) throw StateError('Files changed during checks. No receipt saved; retry.');
      final receipt = File('${directory.path}/verification.json');
      final now = DateTime.now();
      final utc = now.toUtc();
      writeObject(receipt, {
        'version': stateVersion,
        'passed': true,
        'files': files.toList(),
        'workspace': after,
        'checks': checks,
        'completedAt': utc.toIso8601String(),
      });
    });
    stdout.writeln('Verification recorded for ${files.length} explicit task files. Tests were not run.');
    for (final check in checks) {
      stdout.writeln('- $check');
    }
  } catch (error) {
    stderr.writeln('Verification incomplete: $error');
    exitCode = 1;
  }
}

void runCheck(String root, String executable, List<String> arguments) {
  stdout.writeln('Checking: $executable ${arguments.join(' ')}');
  final result = Process.runSync(executable, arguments, workingDirectory: root);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) throw StateError('Check failed with exit ${result.exitCode}: $executable');
}

int checkMarkdown(String root, String path, String content) {
  // Only inline local links are automated; reference-style links and prose need review.
  final withoutFences = content.replaceAll(RegExp(r'^```[^\n]*\n[\s\S]*?^```[^\n]*$', multiLine: true), '');
  final matches = RegExp(r'\[[^\]]*\]\((<[^>]+>|[^\s)]+)(?:\s+"[^"]*")?\)').allMatches(withoutFences);
  var checked = 0;
  final source = File('$root/$path');
  final sourceUri = source.uri;
  for (final match in matches) {
    var destination = match.group(1)!;
    if (destination.startsWith('<')) destination = destination.substring(1, destination.length - 1);
    final link = Uri.parse(destination);
    if (link.hasScheme || link.hasAuthority) continue;
    final resolved = sourceUri.resolveUri(link);
    final local = resolved.removeFragment();
    final target = local.toFilePath();
    if (!target.startsWith('$root/')) throw StateError('Link leaves the repository: $path -> $destination');
    final relative = target.substring(root.length + 1);
    checkedPath(root, relative);
    final type = FileSystemEntity.typeSync(target, followLinks: false);
    if (type == FileSystemEntityType.notFound) throw StateError('Missing link: $path -> $destination');
    if (link.hasFragment && target.endsWith('.md')) {
      final headings = markdownAnchors(File(target).readAsStringSync());
      final anchor = Uri.decodeComponent(link.fragment);
      if (!headings.contains(anchor)) throw StateError('Missing anchor: $path -> $destination');
    }
    checked++;
  }
  return checked;
}

Set<String> markdownAnchors(String content) {
  final result = <String>{};
  final counts = <String, int>{};
  final lines = const LineSplitter().convert(content);
  var fenced = false;
  for (final line in lines) {
    if (line.startsWith('```')) fenced = !fenced;
    if (fenced) continue;
    final match = RegExp(r'^#{1,6}\s+(.+?)\s*#*\s*$').firstMatch(line);
    if (match == null) continue;
    final heading = match.group(1)!;
    final lower = heading.toLowerCase();
    final plain = lower.replaceAll(RegExp(r'[^\p{L}\p{N}_ -]', unicode: true), '');
    final base = plain.replaceAll(' ', '-');
    final count = counts[base] ?? 0;
    result.add(count == 0 ? base : '$base-$count');
    counts[base] = count + 1;
  }
  return result;
}

void checkSkill(String path, String content) {
  // Validate required plain/quoted scalar fields, not arbitrary YAML extensions.
  final lines = const LineSplitter().convert(content);
  if (lines.isEmpty || lines.first != '---') throw StateError('Missing Skill frontmatter: $path');
  final end = lines.indexOf('---', 1);
  if (end < 0) throw StateError('Unclosed Skill frontmatter: $path');
  final fields = <String, String>{};
  for (final line in lines.sublist(1, end)) {
    final match = RegExp(r'^(name|description):\s*(.+)$').firstMatch(line);
    if (match == null) continue;
    final key = match.group(1)!;
    var value = match.group(2)!;
    if (fields.containsKey(key)) throw StateError('Duplicate Skill field $key: $path');
    if (value.startsWith('"') && value.endsWith('"')) value = jsonDecode(value) as String;
    if (value.startsWith("'") && value.endsWith("'")) value = value.substring(1, value.length - 1);
    fields[key] = value;
  }
  final name = fields['name'] ?? '';
  final description = fields['description'] ?? '';
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(name) ||
      name.length > 64 ||
      description.trim().isEmpty ||
      description.length > 1024 ||
      description == '|' ||
      description == '>') {
    throw StateError('Invalid/unsupported required Skill metadata: $path');
  }
}

void checkNewFileWhitespace(String root, String path) {
  final bytes = File('$root/$path').readAsBytesSync();
  if (bytes.contains(0)) return;
  final content = utf8.decode(bytes, allowMalformed: true);
  final lines = const LineSplitter().convert(content);
  for (var index = 0; index < lines.length; index++) {
    if (RegExp(r'[ \t]+$').hasMatch(lines[index])) throw StateError('Trailing whitespace: $path:${index + 1}');
  }
  if (lines.isNotEmpty && lines.last.isEmpty) throw StateError('New blank line at EOF: $path');
}
