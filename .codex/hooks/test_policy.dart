/// Recognizes known test entrypoints without executing or expanding shell input.
///
/// This is a POSIX simple-command guard, not a shell interpreter. It does not
/// resolve aliases, functions, variables, command substitutions, arbitrary
/// scripts, interactive input, or dynamically chosen Melos script names.
String? forbiddenTestReason(String toolName, Map<String, dynamic> input) {
  // Inspect only known test tools; unrelated MCP calls retain their normal policy.
  final normalizedName = toolName.toLowerCase();
  final parts = normalizedName.split('__');
  if (parts.length >= 3 && parts.first == 'mcp') {
    final server = parts[1];
    final tool = parts.last;
    final isDartServer = server.contains('dart') || server.contains('flutter');
    if (isDartServer && (tool == 'run_tests' || tool == 'run_test')) {
      return _testReason('Dart/Flutter MCP test runner');
    }
  }

  // Codex documents command; cmd accommodates clients exposing unified-exec input.
  if (toolName != 'Bash' && toolName != 'exec_command') return null;
  final command = input['command'] ?? input['cmd'];
  if (command is! String) return null;
  return _shellReason(command, 0);
}

String _testReason(String entrypoint) =>
    'Blocked $entrypoint: tests are reserved for the user by AGENTS.md. '
    'Use the project verification runner for permitted checks.';

String? _shellReason(String source, int depth) {
  // Bound nested shell wrappers; unknown shell semantics are deliberately not evaluated.
  if (depth > 6) return null;
  final commands = _shellCommands(source);
  for (final command in commands) {
    final words = _withoutRedirections(command);
    final reason = _commandReason(words, depth);
    if (reason != null) return reason;
  }
  return null;
}

String? _commandReason(List<String> words, int depth) {
  // Peel only wrappers whose argument roles are known.
  var index = 0;
  while (index < words.length) {
    final word = words[index];
    if (_assignment.hasMatch(word)) {
      index++;
      continue;
    }
    final executable = _basename(word);
    if (executable == 'env') {
      index++;
      while (index < words.length) {
        final option = words[index];
        if (_assignment.hasMatch(option) || option == '-i' || option == '--ignore-environment') {
          index++;
        } else if (option == '-u' || option == '--unset' || option == '-C' || option == '--chdir') {
          index += 2;
        } else if (option.startsWith('--unset=') || option.startsWith('--chdir=')) {
          index++;
        } else if (option == '--') {
          index++;
          break;
        } else if (option.startsWith('-')) {
          return null;
        } else {
          break;
        }
      }
      continue;
    }
    if (executable == 'command') {
      index++;
      if (index < words.length && words[index] == '-p') index++;
      if (index < words.length && words[index] == '--') index++;
      if (index < words.length) {
        final option = words[index];
        if (option.startsWith('-')) return null;
      }
      continue;
    }
    if (executable == 'exec') {
      index++;
      while (index < words.length) {
        final option = words[index];
        if (option == '-a') {
          index += 2;
        } else if (option == '-c' || option == '-l') {
          index++;
        } else if (option == '--') {
          index++;
          break;
        } else if (option.startsWith('-')) {
          return null;
        } else {
          break;
        }
      }
      continue;
    }
    break;
  }
  if (index >= words.length) return null;

  // Inspect shell -c strings as commands, but leave data arguments untouched.
  final executable = _basename(words[index]);
  if (const {'sh', 'bash', 'zsh', 'dash', 'ksh'}.contains(executable)) {
    for (var argument = index + 1; argument < words.length; argument++) {
      final option = words[argument];
      if (!option.startsWith('-') || option == '--') return null;
      if (option == '--help' || option == '--version' || option == '--noexec') return null;
      if (_shellNoExecuteOption.hasMatch(option)) return null;
      if (_shellCommandOption.hasMatch(option)) {
        final sourceIndex = argument + 1;
        if (sourceIndex >= words.length) return null;
        return _shellReason(words[sourceIndex], depth + 1);
      }
    }
    return null;
  }

  // Resolve the supported FVM forms before inspecting SDK subcommands.
  if (executable == 'fvm') {
    final subcommand = index + 1;
    if (subcommand >= words.length) return null;
    final action = words[subcommand];
    var sdkIndex = subcommand;
    if (action == 'spawn') {
      sdkIndex += 2;
    } else if (action == 'exec') {
      sdkIndex++;
    }
    if (sdkIndex >= words.length) return null;
    final nested = words.sublist(sdkIndex);
    if (depth >= 6) return null;
    return _commandReason(nested, depth + 1);
  }

  // Match known test entrypoints, rather than arguments that merely mention tests.
  if (_isPreCommit(words[index])) return _preCommitReason;
  if (executable == 'flutter') {
    final action = _nextArgument(words, index + 1, _flutterFlags, _flutterValueOptions);
    if (action == null) return null;
    if (words[action] == 'test' || words[action] == 'drive') {
      return _testReason('flutter ${words[action]}');
    }
  } else if (executable == 'dart') {
    final action = _nextArgument(words, index + 1, _dartFlags, _dartValueOptions);
    if (action == null) return null;
    final name = words[action];
    if (name == 'test') return _testReason('dart test');
    if (_isPreCommit(name)) return _preCommitReason;
    if (name == 'run') {
      final entry = _nextArgument(words, action + 1, _dartFlags, _dartValueOptions);
      if (entry == null) return null;
      final package = words[entry];
      if (_isPreCommit(package)) return _preCommitReason;
      if (package == 'test' || package.startsWith('test:')) return _testReason('dart run test');
      if (package == 'integration_test' || package.startsWith('integration_test:')) {
        return _testReason('dart run integration_test');
      }
    }
  } else if (executable == 'melos') {
    final action = _nextArgument(words, index + 1, const {'--verbose', '--no-verbose'}, const {});
    if (action == null) return null;
    if (words[action] == 'test') return _testReason('melos test');
    if (words[action] == 'run') {
      final script = _nextArgument(words, action + 1, const {'--no-select'}, const {});
      if (script != null && words[script] == 'test') return _testReason('melos run test');
    }
  }
  return null;
}

int? _nextArgument(List<String> words, int start, Set<String> flags, Set<String> valueOptions) {
  // Skip recognized options only; help/version and unknown option grammars do not run a known entrypoint.
  for (var index = start; index < words.length; index++) {
    final word = words[index];
    if (word == '--') return index + 1 < words.length ? index + 1 : null;
    if (!word.startsWith('-')) return index;
    if (flags.contains(word)) continue;
    if (valueOptions.contains(word)) {
      index++;
      continue;
    }
    final equals = word.indexOf('=');
    if (equals > 0) {
      final option = word.substring(0, equals);
      if (valueOptions.contains(option)) continue;
    }
    return null;
  }
  return null;
}

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/');
  final name = segments.last;
  return name.endsWith('.exe') || name.endsWith('.bat') || name.endsWith('.cmd')
      ? name.substring(0, name.length - 4)
      : name;
}

bool _isPreCommit(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized == 'bin/pre_commit.dart' || normalized.endsWith('/bin/pre_commit.dart');
}

List<String> _withoutRedirections(List<String> words) {
  // Redirection targets are data, including names such as "test".
  final result = <String>[];
  for (var index = 0; index < words.length; index++) {
    final word = words[index];
    if (word.startsWith(_redirectionMarker)) {
      index++;
    } else {
      result.add(word);
    }
  }
  return result;
}

List<List<String>> _shellCommands(String source) {
  // Tokenize simple commands while preserving quoted data and escaped separators.
  final commands = <List<String>>[];
  var command = <String>[];
  var word = StringBuffer();
  var started = false;
  var wordWasQuoted = false;
  var quote = '';
  var delimiterExpected = false;
  var stripDelimiterTabs = false;
  final hereDocuments = <(String, bool)>[];
  void finishWord() {
    if (!started) return;
    final value = word.toString();
    command.add(value);
    if (delimiterExpected) {
      hereDocuments.add((value, stripDelimiterTabs));
      delimiterExpected = false;
    }
    word = StringBuffer();
    started = false;
    wordWasQuoted = false;
  }

  // Store completed commands separately so their token lists cannot be changed later.
  void finishCommand() {
    finishWord();
    if (command.isNotEmpty) commands.add(command);
    command = <String>[];
  }

  for (var index = 0; index < source.length; index++) {
    final character = source[index];
    if (quote == "'") {
      if (character == "'") {
        quote = '';
      } else {
        word.write(character);
      }
      continue;
    }
    if (character == '\\' && index + 1 < source.length) {
      final escaped = source[index + 1];
      if (quote == '"' && !const {r'$', '`', '"', '\\', '\n'}.contains(escaped)) {
        word.write(character);
      } else {
        index++;
        if (escaped != '\n') {
          word.write(escaped);
          started = true;
        }
      }
      continue;
    }
    if (quote == '"') {
      if (character == '"') {
        quote = '';
      } else {
        word.write(character);
      }
      continue;
    }
    if (character == "'" || character == '"') {
      quote = character;
      started = true;
      wordWasQuoted = true;
      continue;
    }
    if (character == '#' && !started) {
      while (index + 1 < source.length && source[index + 1] != '\n') {
        index++;
      }
      continue;
    }
    if (character == '<' || character == '>') {
      // A file descriptor must be adjacent and unquoted: `2>` differs from `2 >`.
      final prefix = word.toString();
      var descriptor = '';
      if (started && !wordWasQuoted && _fileDescriptor.hasMatch(prefix)) {
        descriptor = prefix;
        word = StringBuffer();
        started = false;
      } else {
        finishWord();
      }
      var operator = character;
      if (index + 1 < source.length) {
        final next = source[index + 1];
        if (next == character || next == '&' || next == '|' || (character == '<' && next == '>')) {
          operator = '$operator$next';
          index++;
        }
      }
      if (operator == '<<' && index + 1 < source.length && source[index + 1] == '-') {
        operator = '<<-';
        index++;
      }
      command.add('$_redirectionMarker$descriptor$operator');
      delimiterExpected = operator == '<<' || operator == '<<-';
      stripDelimiterTabs = operator == '<<-';
      continue;
    }
    if (character == ';' || character == '|' || character == '&' || character == '\n') {
      finishCommand();
      if (character != '\n') continue;

      // Here-document bodies are data; never interpret a patch or document as commands.
      for (final (delimiter, stripTabs) in hereDocuments) {
        var matched = false;
        while (index + 1 < source.length) {
          final start = index + 1;
          var end = source.indexOf('\n', start);
          if (end < 0) end = source.length;
          var line = source.substring(start, end);
          if (stripTabs) line = line.replaceFirst(_leadingTabs, '');
          index = end;
          if (line == delimiter) {
            matched = true;
            break;
          }
        }
        if (!matched) return commands;
      }
      hereDocuments.clear();
      continue;
    }
    if (character == ' ' || character == '\t' || character == '\r') {
      finishWord();
    } else {
      word.write(character);
      started = true;
    }
  }
  if (quote.isNotEmpty) return const [];
  finishCommand();
  return commands;
}

final _assignment = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*=');
final _shellCommandOption = RegExp(r'^-[A-Za-z]*c[A-Za-z]*$');
final _shellNoExecuteOption = RegExp(r'^-[A-Za-z]*n[A-Za-z]*$');
final _fileDescriptor = RegExp(r'^\d+$');
final _leadingTabs = RegExp(r'^\t+');
// A marker keeps a quoted argument such as ">" distinct from a real redirect.
const _redirectionMarker = '\u0000redirect:';
const _flutterFlags = {'-v', '--verbose', '--no-version-check', '--suppress-analytics'};
const _flutterValueOptions = {'-d', '--device-id', '--packages'};
const _dartFlags = {'--enable-asserts', '--disable-dart-dev', '--verbose', '-v'};
const _dartValueOptions = {'--packages', '--observe', '--enable-vm-service'};
const _preCommitReason =
    'Blocked bin/pre_commit.dart: it formats the whole project and runs Flutter tests. '
    'AGENTS.md reserves test execution for the user; use the project verification runner.';
