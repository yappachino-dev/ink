import 'dart:io';

/// Guards the spacing token sweep against silent value corruption.
///
/// The sweep that adopted `AppSpacing` shipped a real corruption first time.
/// Its migration script trimmed the numeric suffix with `str.rstrip('.0')`,
/// and `rstrip` strips a *character set*, not a suffix, so `40` became `4` and
/// `20` became `2`. Both then resolved to `AppSpacing.xs`, which collapsed five
/// layouts while `flutter analyze` stayed green: `AppSpacing.xs` is a
/// perfectly valid constant, so the file compiled and every test that did not
/// assert a pixel passed.
///
/// The lesson this encodes is that a refactor script needs a verifier that
/// compares *values*. Proving the tree compiles proves nothing here.
///
/// Run it as:
///
/// ```sh
/// dart run tool/verify_spacing_tokens.dart [baseRef] [headRef]
/// ```
///
/// `baseRef` defaults to `origin/main`. `headRef` defaults to `worktree`; pass
/// `HEAD` to check the committed state instead of the working tree.
///
/// Exits non-zero when a token does not carry the literal it replaced. Files
/// it cannot pair automatically are reported for a human rather than guessed
/// at, so a clean run means "no known corruption", not "nothing to see".
const Map<String, int> _token = <String, int>{
  'xs': 4,
  'sm': 8,
  'md': 12,
  'lg': 16,
  'xl': 20,
  'xxl': 24,
  'xxxl': 32,
  'huge': 48,
};

/// Values that were never on the scale, and the nearest step each snaps to.
///
/// Every entry still has to land where this table says, so a bad mapping is
/// caught rather than waved through as "an intentional snap".
const Map<int, int> _snap = <int, int>{
  1: 4,
  2: 4,
  3: 4,
  6: 8,
  10: 8,
  14: 12,
  18: 16,
  28: 24,
  40: 32,
};

final RegExp _edgeCall = RegExp(r'EdgeInsets\.([a-zA-Z]+)\(([^()]*)\)');
final RegExp _edgeToken = RegExp(r'AppSpacing\.(\w+)');
final RegExp _edgeNumber = RegExp(r'(?<![\w.])([0-9]+)(?:\.[0-9]+)?(?![\w.])');
final RegExp _sizeToken = RegExp(
  r'SizedBox\((?:height|width):\s*AppSpacing\.(\w+)\)',
);
final RegExp _sizeNumber = RegExp(
  r'SizedBox\((?:height|width):\s*([0-9]+(?:\.[0-9]+)?)\)',
);
final RegExp _symbolicSize = RegExp(
  r'SizedBox\((?:height|width):\s*(?!AppSpacing\.|[0-9])[A-Za-z_]',
);

void main(List<String> args) {
  final base = args.isNotEmpty ? args[0] : 'origin/main';
  final head = args.length > 1 ? args[1] : 'worktree';

  final prefix = _git(['rev-parse', '--show-prefix']).trim();
  final problems = <String>[];
  final review = <String>[];
  var checked = 0;

  for (final file in _dartFiles()) {
    final after = _read(head, file, '$prefix$file');
    if (!after.contains('AppSpacing')) continue;
    final before = _read(base, file, '$prefix$file');
    if (before.isEmpty) continue;
    checked++;
    _collect(_checkSizeBoxes(file, before, after), problems, review);
    _collect(_checkEdgeInsets(file, before, after), problems, review);
  }

  if (review.isNotEmpty) {
    stdout.writeln(
      '${review.length} file(s) could not be paired automatically. These are '
      'not failures, but they are unchecked:',
    );
    for (final item in review) {
      stdout.writeln('   $item');
    }
  }

  if (problems.isEmpty) {
    stdout.writeln('Spacing tokens verified across $checked files.');
    return;
  }

  stdout.writeln(
    '${problems.length} spacing token mismatch(es) in $checked files:',
  );
  for (final problem in problems) {
    stdout.writeln('   $problem');
  }
  exitCode = 1;
}

/// Splits findings into real corruption and files needing a human.
void _collect(List<String> found, List<String> problems, List<String> review) {
  for (final item in found) {
    if (item.contains('SKIPPED')) {
      review.add(item);
    } else {
      problems.add(item);
    }
  }
}

Iterable<String> _dartFiles() sync* {
  final roots = <String>['lib', 'test'];
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity
        in directory.listSync(recursive: true).whereType<File>()) {
      final path = entity.path.replaceAll(r'\\', '/');
      if (!path.endsWith('.dart')) continue;
      if (path.endsWith('.g.dart') || path.contains('.freezed.')) continue;
      yield path;
    }
  }
}

/// Reads a file at `ref`.
///
/// `localPath` is relative to the current directory, which is what the
/// worktree needs. `repoPath` is relative to the repository root, which is
/// what git needs, and differs from `localPath` when the tool runs from
/// `client/`.
String _read(String ref, String localPath, String repoPath) {
  if (ref == 'worktree') {
    final file = File(localPath);
    return file.existsSync() ? file.readAsStringSync() : '';
  }
  return _git(['show', '$ref:$repoPath']);
}

String _git(List<String> args) {
  final result = Process.runSync('git', args);
  return result.exitCode == 0 ? (result.stdout as String) : '';
}

/// The pixel value a literal must resolve to, or null if unmapped.
int? _expectedFor(String literal) {
  final value = int.tryParse(literal);
  if (value == null) return null;
  if (_token.containsValue(value)) return value;
  return _snap[value];
}

List<String> _checkSizeBoxes(String path, String before, String after) {
  if (_symbolicSize.hasMatch(before)) {
    final symbolic =
        '$path: SKIPPED - a SizedBox used a named constant, so its'
        ' value cannot be paired automatically. Check by hand.';
    return <String>[symbolic];
  }

  final old = _sizeNumber.allMatches(before).map((m) => m.group(1)!).toList();
  final tokens = _sizeToken.allMatches(after).map((m) => m.group(1)!).toList();
  if (old.length != tokens.length) {
    final unpaired =
        '$path: SKIPPED - ${old.length} literal SizedBox values'
        ' became ${tokens.length} tokens; pair them by hand.';
    return <String>[unpaired];
  }

  final problems = <String>[];
  for (var i = 0; i < tokens.length; i++) {
    final literal = old[i].replaceFirst(RegExp(r'\.0$'), '');
    if (literal == '0') continue;
    final want = _expectedFor(literal);
    final got = _token[tokens[i]];
    if (want == null) {
      problems.add(
        '$path: SizedBox($literal) -> AppSpacing.${tokens[i]}:'
        ' $literal is not on the scale and has no declared snap',
      );
    } else if (got != want) {
      problems.add(
        '$path: SizedBox($literal) -> AppSpacing.${tokens[i]} '
        '(=$got, expected $want)',
      );
    }
  }
  return problems;
}

List<String> _checkEdgeInsets(String path, String before, String after) {
  final old = _edgeCall
      .allMatches(before)
      .map((m) => (kind: m.group(1)!, body: m.group(2)!))
      .toList();
  final current = _edgeCall
      .allMatches(after)
      .map((m) => (kind: m.group(1)!, body: m.group(2)!))
      .toList();

  if (old.length != current.length) {
    // A literal call replaced by a named `AppSpacing` constant changes the
    // count without losing a value, so this is a note, not a failure.
    final shifted =
        '$path: SKIPPED - EdgeInsets call count'
        ' ${old.length} -> ${current.length}; the calls no longer align,'
        ' so their values are unchecked. Review by hand.';
    return <String>[shifted];
  }

  final problems = <String>[];
  for (var i = 0; i < old.length; i++) {
    final oldBody = old[i].body;
    final newBody = current[i].body;
    if (oldBody.contains('AppSpacing')) continue;
    if (!newBody.contains('AppSpacing')) continue;

    final distinct =
        _edgeNumber
            .allMatches(oldBody)
            .map((m) => int.parse(m.group(1)!))
            .where((v) => v != 0)
            .toSet()
            .toList()
          ..sort();
    final got =
        _edgeToken
            .allMatches(newBody)
            .map((m) => _token[m.group(1)!])
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();
    if (distinct.isEmpty || got.isEmpty) continue;

    // `fromLTRB(20, 20, 20, 8)` and `only(left: 20, right: 20, top: 20,
    // bottom: 8)` are the same padding, so compare distinct edges.
    final pairs = distinct.length < got.length ? distinct.length : got.length;
    for (var j = 0; j < pairs; j++) {
      final want = _expectedFor('${distinct[j]}');
      if (want == null) {
        problems.add(
          '$path: EdgeInsets(${oldBody.trim()}) carries ${distinct[j]}, '
          'which is off-scale with no declared snap',
        );
      } else if (got[j] != want) {
        problems.add(
          '$path: EdgeInsets(${oldBody.trim()}) carried ${distinct[j]}, now '
          'resolves to ${got[j]} (expected $want)',
        );
      }
    }
  }
  return problems;
}
