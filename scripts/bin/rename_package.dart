import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:ansi_styles/ansi_styles.dart';

import 'options.dart';
import 'flags.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      Options.newName,
      abbr: Options.newName.abbr,
      help: Options.newName.help?.text,
      valueHelp: Options.newName.help?.valueHelp,
    )
    ..addOption(
      Options.oldName,
      abbr: Options.oldName.abbr,
      help: Options.newName.help?.text,
      valueHelp: Options.newName.help?.valueHelp,
    )
    ..addFlag(Flags.initRepo, help: Flags.initRepo.help, negatable: false)
    ..addFlag(
      Flags.helps,
      abbr: Flags.helps.abbr,
      help: Flags.helps.help,
      negatable: false,
    );

  late ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(AnsiStyles.red('${AnsiStyles.bold('Error:')} ${e.message}'));
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (argResults['help'] as bool) {
    stdout.writeln(
      AnsiStyles.cyan(
        AnsiStyles.bold(
          'Rename Flutter package name in pubspec.yaml and imports',
        ),
      ),
    );
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Handle repository initialization
  if (argResults['init-repo'] as bool) {
    _initializeRepository();
    return;
  }

  if (!argResults.wasParsed(Options.newName)) {
    stderr.writeln(
      AnsiStyles.red('${AnsiStyles.bold('Error:')} --new-name is required'),
    );
    stderr.writeln(parser.usage);
    exit(1);
  }

  final newName = argResults[Options.newName] as String;
  final oldName = argResults.wasParsed(Options.oldName)
      ? argResults[Options.oldName] as String
      : _extractPackageName('pubspec.yaml');

  if (oldName.isEmpty) {
    stderr.writeln(
      AnsiStyles.red(
        '${AnsiStyles.bold('Error:')} Could not determine old package name',
      ),
    );
    exit(1);
  }

  stdout.writeln(
    AnsiStyles.green(
      'Renaming package from "${AnsiStyles.bold(oldName)}" to "${AnsiStyles.bold(newName)}"',
    ),
  );

  // Update pubspec.yaml
  _updatePubspecYaml('pubspec.yaml', newName);

  // Update Dart imports
  _updateDartImports(Directory.current, oldName, newName);

  // Fetch dependency
  _fetchDependency();

  stdout.writeln(
    AnsiStyles.green(
      AnsiStyles.bold('Package renaming completed successfully!'),
    ),
  );

  exit(0);
}

/// Extracts the package name from pubspec.yaml
String _extractPackageName(String pubspecPath) {
  final file = File(pubspecPath);
  if (!file.existsSync()) {
    stderr.writeln(
      AnsiStyles.red('${AnsiStyles.bold('Error:')} pubspec.yaml not found'),
    );
    exit(1);
  }

  final content = file.readAsStringSync();
  final yaml = loadYaml(content) as YamlMap;

  final name = yaml['name'];
  if (name == null) {
    stderr.writeln(
      AnsiStyles.red(
        '${AnsiStyles.bold('Error:')} name field not found in pubspec.yaml',
      ),
    );
    exit(1);
  }

  return name.toString();
}

/// Updates the package name in pubspec.yaml
void _updatePubspecYaml(String pubspecPath, String newName) {
  final file = File(pubspecPath);
  if (!file.existsSync()) {
    stderr.writeln(
      AnsiStyles.red('${AnsiStyles.bold('Error:')} pubspec.yaml not found'),
    );
    exit(1);
  }

  final content = file.readAsStringSync();
  final yamlEditor = YamlEditor(content);
  yamlEditor.update(['name'], newName);

  file.writeAsStringSync(yamlEditor.toString());
  stdout.writeln(AnsiStyles.green('Updated package name in pubspec.yaml'));
}

/// Updates Dart import statements in all .dart files
void _updateDartImports(Directory directory, String oldName, String newName) {
  final files = directory.listSync(recursive: true);

  for (final file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      _updateDartFileImports(file, oldName, newName);
    }
  }
}

/// Updates Dart import statements in a single file
void _updateDartFileImports(File file, String oldName, String newName) {
  final content = file.readAsStringSync();
  final lines = content.split('\n');
  var changed = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // Check for import statements with the old package name
    if (line.contains('package:$oldName/')) {
      lines[i] = line.replaceAll('package:$oldName/', 'package:$newName/');
      changed = true;
    }
  }

  if (changed) {
    file.writeAsStringSync(lines.join('\n'));
    stdout.writeln(AnsiStyles.green('Updated imports in ${file.path}'));
  }
}

void _fetchDependency() {
  stdout.writeln(AnsiStyles.cyan('Fetching dependencies...'));
  final result = Process.runSync('dart', ['pub', 'get']);
  if (result.exitCode != 0) {
    stderr.writeln(AnsiStyles.red('Fetch dependency is not success;'));
    stderr.writeln(result.stdout);
  } else {
    stdout.writeln(AnsiStyles.green('Dependencies fetched successfully!'));
  }
}

/// Initialize a new git repository
void _initializeRepository() {
  stdout.writeln(AnsiStyles.cyan('Initializing new git repository...'));

  // Remove existing .git directory if it exists
  final gitDir = Directory('.git');
  if (gitDir.existsSync()) {
    stdout.writeln(AnsiStyles.yellow('Removing existing .git directory...'));
    gitDir.deleteSync(recursive: true);
  }

  // Initialize new repository
  final result = Process.runSync('git', ['init']);
  if (result.exitCode != 0) {
    stderr.writeln(
      AnsiStyles.red(
        '${AnsiStyles.bold('Error initializing git repository:')} ${result.stderr}',
      ),
    );
    exit(1);
  }

  stdout.writeln(
    AnsiStyles.green(
      AnsiStyles.bold('Git repository initialized successfully!'),
    ),
  );
  stdout.writeln(result.stdout);
}
