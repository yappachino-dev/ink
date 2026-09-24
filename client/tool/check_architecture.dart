import 'dart:io';

const _generatedSuffixes = ['.g.dart', '.freezed.dart'];

void main() {
  final violations = <String>[];

  for (final root in ['lib', 'test']) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;

    for (final file in directory.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || _isGenerated(file.path)) continue;

      final relativePath = file.path.replaceAll(String.fromCharCode(92), '/');
      final source = file.readAsStringSync();

      if ((relativePath.startsWith('lib/features/') ||
              relativePath.startsWith('test/features/')) &&
          relativePath.contains('/presentation/')) {
        _checkPresentationImports(relativePath, source, violations);
      }

      if (relativePath.startsWith('lib/features/') &&
          relativePath.contains('/data/') &&
          source.contains('package:ink/app/database/database_provider.dart')) {
        violations.add(
          '$relativePath obtains AppDatabase from the app database provider',
        );
      }

      if (relativePath.startsWith('lib/core/') &&
          source.contains('package:ink/features/')) {
        violations.add('$relativePath imports a feature module from core');
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Architecture import checks passed.');
    return;
  }

  stderr.writeln('Architecture import violations:');
  for (final violation in violations) {
    stderr.writeln(' - $violation');
  }
  exitCode = 1;
}

bool _isGenerated(String path) =>
    _generatedSuffixes.any((suffix) => path.endsWith(suffix));

void _checkPresentationImports(
  String path,
  String source,
  List<String> violations,
) {
  final featureMatch = RegExp(
    '^(?:lib|test)/features/([^/]+)/presentation/',
  ).firstMatch(path);
  if (featureMatch == null) return;

  final feature = featureMatch.group(1)!;
  final forbiddenImports = [
    RegExp('package:ink/features/[^/]+/data/'),
    RegExp('package:ink/core/infrastructure/'),
    RegExp('package:ink/core/services/'),
    RegExp('package:ink/app/database/'),
  ];

  for (final pattern in forbiddenImports) {
    if (pattern.hasMatch(source)) {
      violations.add('$path contains ${pattern.pattern}');
    }
  }

  final crossFeatureImports = RegExp(
    'package:ink/features/([^/]+)/presentation/',
  ).allMatches(source);
  if (crossFeatureImports.any((match) => match.group(1) != feature)) {
    violations.add('$path imports another feature presentation layer');
  }
}
