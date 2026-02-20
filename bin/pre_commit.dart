import 'dart:io';

void main() {
  ConsolePrinter.i('🔍 Running pre-commit checks...');

  if (!File('pubspec.yaml').existsSync()) {
    ConsolePrinter.e('pubspec.yaml not found. Are you in a Flutter project root?');
    exit(1);
  }

  try {
    Process.runSync('fvm', ['--version']);
  } catch (e) {
    ConsolePrinter.e('FVM not found. Please install FVM first.');
    exit(1);
  }

  final result = Process.runSync('git', ['diff', '--cached', '--name-only', '--diff-filter=ACM']);

  final stagedFiles = result.stdout
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty && line.endsWith('.dart'))
      .toList(growable: false);

  if (stagedFiles.isEmpty) {
    ConsolePrinter.w('No Dart files staged for commit. Skipping format and tests.');
    exit(0);
  }

  ConsolePrinter.i('Found staged Dart files: ${stagedFiles.join(', ')}');

  ConsolePrinter.i('Running dart format...');
  try {
    Process.runSync('fvm', ['dart', 'format', '.']);
    ConsolePrinter.i('✅ Code formatting completed');
  } catch (e) {
    ConsolePrinter.e('Code formatting failed');
    exit(1);
  }

  final diffResult = Process.runSync('git', ['diff', '--name-only']);
  final formattedFiles = diffResult.stdout
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty && line.endsWith('.dart'))
      .where(stagedFiles.contains)
      .toList(growable: false);

  if (formattedFiles.isNotEmpty) {
    ConsolePrinter.w('Some files were reformatted:');
    for (final file in formattedFiles) {
      ConsolePrinter.i('$file\n');
    }
    ConsolePrinter.i('Please add the formatted files and commit again:');
    ConsolePrinter.i('git add ${formattedFiles.join(' ')}');
    exit(1);
  }

  ConsolePrinter.i('Running Flutter tests...');
  try {
    Process.runSync('fvm', ['flutter', 'test']);
    ConsolePrinter.i('✅ All tests passed');
  } catch (e) {
    ConsolePrinter.e('Tests failed');
    ConsolePrinter.i('Fix failing tests before committing');
    exit(1);
  }

  if (File('analysis_options.yaml').existsSync()) {
    ConsolePrinter.i('Running static analysis...');
    try {
      Process.runSync('fvm', ['flutter', 'analyze', '--no-fatal-infos']);
      ConsolePrinter.i('✅ Static analysis completed');
    } catch (e) {
      ConsolePrinter.e('Static analysis found issues');
      ConsolePrinter.i('Fix analysis issues before committing');
      exit(1);
    }
  }

  ConsolePrinter.i('🎉 All pre-commit checks passed!');
  ConsolePrinter.i('Proceeding with commit...');
}

extension type const ConsolePrinter._(Stdout out) {
  static final e = ErrorConsolePrinter();

  static final i = InfoConsolePrinter();

  static final w = WarningConsolePrinter();

  static final s = ConsolePrinter._(stdout);

  /// Prints a message to the console.
  void call(String message) => out.writeln(message);
}

extension type const ErrorConsolePrinter._(Stdout out) implements ConsolePrinter {
  factory ErrorConsolePrinter() => ErrorConsolePrinter._(stderr);

  void call(String message) {
    out.writeln('❌ $message');
  }
}

extension type const InfoConsolePrinter._(Stdout out) implements ConsolePrinter {
  factory InfoConsolePrinter() => InfoConsolePrinter._(stdout);

  void call(String message) {
    out.writeln(message);
  }
}

extension type const WarningConsolePrinter._(Stdout out) implements ConsolePrinter {
  factory WarningConsolePrinter() => WarningConsolePrinter._(stdout);

  void call(String message) {
    out.writeln('⚠️ $message');
  }
}
