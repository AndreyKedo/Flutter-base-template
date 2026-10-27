import 'dart:convert';
import 'dart:io';

const stateDirectory = '.codex/.hook-state';
const stateVersion = 1;

// Hooks are standalone SDK tools: never import Flutter or resolve packages.
String repositoryRoot(String cwd) {
  final result = runGit(cwd, ['rev-parse', '--show-toplevel']);
  final output = result.stdout as String;
  return output.trim();
}

ProcessResult runGit(String root, List<String> arguments) {
  final result = Process.runSync('git', arguments, workingDirectory: root);
  if (result.exitCode != 0) {
    throw StateError('Git could not complete ${arguments.first}: ${result.stderr}');
  }
  return result;
}

bool protectedPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final lower = normalized.toLowerCase();
  final parts = lower.split('/');
  const directories = {'.git', '.aws', '.ssh', '.gnupg', 'secret', 'secrets', 'certificates', 'keystores'};
  const names = {'google-services.json', 'googleservice-info.plist', 'key.properties', 'id_rsa', 'id_ed25519'};
  for (final part in parts) {
    if (directories.contains(part) || names.contains(part) || part.startsWith('.env') || part.contains('secret')) {
      return true;
    }
    if (RegExp(r'\.(pem|key|p8|p12|pfx|jks|keystore|cer|crt|der|csr|mobileprovision)$').hasMatch(part)) return true;
  }
  return lower == stateDirectory || lower.startsWith('$stateDirectory/');
}

String checkedPath(String root, String path) {
  // Accept explicit repository-relative file names, never arbitrary shell text.
  final normalized = path.replaceAll('\\', '/');
  final components = normalized.split('/');
  if (normalized.isEmpty ||
      normalized.startsWith('/') ||
      normalized.contains(':') ||
      normalized.contains('\n') ||
      normalized.contains('\r') ||
      normalized.contains('\u0000') ||
      components.contains('..') ||
      components.contains('.') ||
      protectedPath(normalized)) {
    throw StateError('Unsupported or protected verification path: $path');
  }

  // Do not follow symlinks, including symlinked directories inside the checkout.
  final current = StringBuffer(root);
  for (final part in components) {
    current.write('/$part');
    final currentPath = current.toString();
    final type = FileSystemEntity.typeSync(currentPath, followLinks: false);
    if (type == FileSystemEntityType.link) throw StateError('Symlink requires manual verification: $path');
  }
  return normalized;
}

Map<String, String> workspaceSnapshot(String root) {
  // Enumerate only Git-visible files; ignored build/cache/state output is excluded.
  final result = runGit(root, ['ls-files', '--cached', '--others', '--exclude-standard', '-z']);
  final output = result.stdout as String;
  final names = output.split('\u0000');
  final unique = <String>{};
  for (final path in names) {
    if (path.isNotEmpty && !protectedPath(path)) unique.add(path);
  }
  final paths = unique.toList();
  paths.sort();
  final snapshot = <String, String>{};
  final regular = <String>[];
  for (final path in paths) {
    checkedPath(root, path);
    final type = FileSystemEntity.typeSync('$root/$path', followLinks: false);
    if (type == FileSystemEntityType.file) {
      regular.add(path);
    } else if (type != FileSystemEntityType.notFound) {
      throw StateError('Unsupported tracked entry requires manual verification: $path');
    }
  }

  // Git hashes bytes without filters and without writing objects (-w is absent).
  for (var offset = 0; offset < regular.length; offset += 128) {
    final end = offset + 128 < regular.length ? offset + 128 : regular.length;
    final batch = regular.sublist(offset, end);
    final hashesResult = runGit(root, ['hash-object', '--no-filters', '--', ...batch]);
    final hashesOutput = hashesResult.stdout as String;
    final hashes = const LineSplitter().convert(hashesOutput);
    if (hashes.length != batch.length) throw StateError('Incomplete workspace fingerprint');
    for (var i = 0; i < batch.length; i++) {
      snapshot[batch[i]] = hashes[i];
    }
  }
  // Index contents and HEAD are check inputs too, even when file bytes did not change.
  final headResult = runGit(root, ['rev-parse', '--verify', 'HEAD']);
  final head = headResult.stdout as String;
  snapshot[':git:HEAD'] = head.trim();
  final indexResult = runGit(root, ['ls-files', '--stage', '-z']);
  final indexOutput = indexResult.stdout as String;
  for (final entry in indexOutput.split('\u0000')) {
    final separator = entry.indexOf('\t');
    if (separator < 0) continue;
    final path = entry.substring(separator + 1);
    if (!protectedPath(path)) snapshot[':git:index:$path'] = entry.substring(0, separator);
  }
  return snapshot;
}

bool sameSnapshot(Map<String, dynamic> left, Map<String, dynamic> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

Map<String, dynamic> readObject(File file) {
  if (FileSystemEntity.isLinkSync(file.path)) throw StateError('Hook state must not be a symlink');
  final value = jsonDecode(file.readAsStringSync());
  if (value is! Map<String, dynamic>) throw StateError('Invalid hook state: ${file.path}');
  return value;
}

void writeObject(File file, Map<String, dynamic> value) {
  final temporary = File('${file.path}.$pid.tmp');
  temporary.writeAsStringSync(jsonEncode(value), flush: true);
  temporary.renameSync(file.path);
}

T withStateLock<T>(String root, T Function(Directory directory) action) {
  // A single short lock serializes parent/subagent state updates, never checks.
  checkedPath(root, '.codex');
  final directory = Directory('$root/$stateDirectory');
  final type = FileSystemEntity.typeSync(directory.path, followLinks: false);
  if (type == FileSystemEntityType.link) throw StateError('Hook state must not be a symlink');
  directory.createSync(recursive: true);
  final lockFile = File('${directory.path}/lock');
  if (FileSystemEntity.isLinkSync(lockFile.path)) throw StateError('Invalid hook state lock');
  final lock = lockFile.openSync(mode: FileMode.append);
  try {
    lock.lockSync(FileLock.blockingExclusive);
    return action(directory);
  } finally {
    lock.unlockSync();
    lock.closeSync();
  }
}

File sessionFile(Directory directory, String session) {
  if (!RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(session)) throw StateError('Invalid hook session id');
  return File('${directory.path}/session-$session.json');
}

void observeChanges(Map<String, dynamic> state, Map<String, String> snapshot) {
  final previous = Map<String, dynamic>.from(state['baseline'] as Map);
  final pending = <String>{};
  final paths = {...previous.keys, ...snapshot.keys};
  for (final path in paths) {
    if (path == ':git:HEAD') continue;
    if (previous[path] != snapshot[path]) {
      pending.add(path.startsWith(':git:index:') ? path.substring(11) : path);
    }
  }
  state['observed'] = snapshot;
  final changed = pending.toList();
  changed.sort();
  state['pending'] = changed;
}
