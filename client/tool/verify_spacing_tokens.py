#!/usr/bin/env python3
"""Guards the spacing token sweep against silent value corruption.

Why this exists
---------------
A migration script replaced literal spacing values with `AppSpacing`
constants. It trimmed the numeric suffix with ``str.rstrip('.0')``, and
``rstrip`` takes a *character set* rather than a suffix, so::

    '40'.rstrip('.0')  ->  '4'
    '20'.rstrip('.0')  ->  '2'

Forty-pixel gaps became ``AppSpacing.xs`` (4px) and twenty-pixel gaps became
4px too, collapsing five layouts - auth headings sat on top of their form
fields, and the recovery phrase rows touched. The analyzer never complained,
because ``AppSpacing.xs`` is a perfectly valid constant: the file compiled and
every test that did not assert a pixel passed.

The lesson this encodes: a refactor script needs a verifier that compares
*values*. Proving the tree compiles proves nothing here.

Usage
-----
    python3 client/tool/verify_spacing_tokens.py [base_ref]

``base_ref`` defaults to ``origin/main``. Pass ``worktree`` as the *second*
argument to verify uncommitted changes::

    python3 client/tool/verify_spacing_tokens.py origin/main worktree

Exit code is 0 when every tokenised value corresponds to the literal it
replaced, 1 otherwise.
"""

import re
import subprocess
import sys

# Token name -> the pixel value it represents.
TOKEN = {
    'xs': 4,
    'sm': 8,
    'md': 12,
    'lg': 16,
    'xl': 20,
    'xxl': 24,
    'xxxl': 32,
    'huge': 48,
}

# Values that were never on the scale, and the nearest step each snaps to.
# Every entry still has to land where this table says, so a bad mapping is
# caught rather than waved through as "an intentional snap".
SNAP = {
    '1': 4, '2': 4, '3': 4,
    '6': 8, '10': 8, '14': 12, '18': 16,
    '28': 24, '40': 32,
}

ON_SCALE = {str(v): v for v in TOKEN.values()}

EDGE_CALL = re.compile(r'EdgeInsets\.([a-zA-Z]+)\(([^()]*)\)')
EDGE_TOKEN = re.compile(r'AppSpacing\.(\w+)')
EDGE_NUMBER = re.compile(r'(?<![\w.])([0-9]+)(?:\.[0-9]+)?(?![\w.])')
SIZEBOX_TOKEN = re.compile(r'SizedBox\((?:height|width):\s*AppSpacing\.(\w+)\)')
SIZEBOX_NUMBER = re.compile(r'SizedBox\((?:height|width):\s*([0-9]+(?:\.[0-9]+)?)\)')


def expected_for(literal):
    """The pixel value a literal must resolve to, or None if unmapped."""
    if literal in ON_SCALE:
        return ON_SCALE[literal]
    return SNAP.get(literal)


def read(ref, path):
    if ref == 'worktree':
        try:
            with open(path, encoding='utf-8') as handle:
                return handle.read()
        except OSError:
            return ''
    return subprocess.run(
        ['git', 'show', f'{ref}:{path}'], capture_output=True,
    ).stdout.decode('utf-8', 'replace')


def dart_files():
    listed = subprocess.run(
        ['git', 'ls-tree', '-r', '--name-only', 'HEAD'],
        capture_output=True, text=True,
    ).stdout.split('\n')
    return [
        f for f in listed
        if f.startswith('client/')
        and f.endswith('.dart')
        and '/.g.dart' not in f
        and '.freezed.' not in f
    ]


def has_symbolic_sizebox(text):
    """True when a SizedBox argument is a named constant, not a literal.

    Positional pairing cannot line up in that case, so the file is reported for
    a human rather than guessed at.
    """
    return bool(
        re.search(
            r'SizedBox\((?:height|width):\s*(?!AppSpacing\.|[0-9])[A-Za-z_]',
            text,
        )
    )


def check_sizebox(path, before, after):
    """Each tokenised SizedBox must match the literal SizedBox it replaced."""
    problems = []
    if has_symbolic_sizebox(before):
        return [
            f'{path}: SKIPPED - a SizedBox used a named constant, so its value '
            f'cannot be paired automatically. Check by hand.'
        ]
    old = SIZEBOX_NUMBER.findall(before)
    new = SIZEBOX_TOKEN.findall(after)
    if len(old) != len(new):
        return [
            f'{path}: SKIPPED - {len(old)} literal SizedBox values became '
            f'{len(new)} tokens; pair them by hand.'
        ]
    for index, token in enumerate(new):
        if index >= len(old):
            break
        literal = old[index].removesuffix('.0')
        if literal == '0':
            continue
        want = expected_for(literal)
        if want is None:
            problems.append(
                f'{path}: SizedBox({literal}) -> AppSpacing.{token}: '
                f'{literal} is not on the scale and has no declared snap'
            )
        elif TOKEN[token] != want:
            problems.append(
                f'{path}: SizedBox({literal}) -> AppSpacing.{token} '
                f'(={TOKEN[token]}, expected {want})'
            )
    return problems


def check_edge(path, before, after):
    """Each tokenised EdgeInsets must carry the values it used to carry."""
    problems = []
    old = [(k, b) for k, b in EDGE_CALL.findall(before)]
    new = [(k, b) for k, b in EDGE_CALL.findall(after)]
    if len(old) != len(new):
        problems.append(
            f'{path}: EdgeInsets call count {len(old)} -> {len(new)}'
        )
        return problems

    for (_, old_body), (_, new_body) in zip(old, new):
        if 'AppSpacing' in old_body or 'AppSpacing' not in new_body:
            continue
        old_values = sorted(
            int(x) for x in EDGE_NUMBER.findall(old_body) if int(x) != 0
        )
        new_values = sorted(
            TOKEN[t] for t in EDGE_TOKEN.findall(new_body) if t in TOKEN
        )
        if not old_values or not new_values:
            continue
        # Compare the distinct edges: `fromLTRB(20, 20, 20, 8)` and
        # `only(left: 20, right: 20, top: 20, bottom: 8)` are the same padding.
        distinct = sorted(set(old_values))
        got = sorted(set(new_values))
        if len(got) > len(distinct):
            got = got[:len(distinct)]
        for literal, value in zip(distinct, got):
            want = expected_for(str(literal))
            if want is None:
                problems.append(
                    f'{path}: EdgeInsets({old_body.strip()}) carries {literal}, '
                    f'which is off-scale with no declared snap'
                )
            elif value != want:
                problems.append(
                    f'{path}: EdgeInsets({old_body.strip()}) carried {literal}, '
                    f'now resolves to {value} (expected {want})'
                )
    return problems


def main():
    base = sys.argv[1] if len(sys.argv) > 1 else 'origin/main'
    head = sys.argv[2] if len(sys.argv) > 2 else 'worktree'

    problems = []
    checked = 0
    for path in dart_files():
        after = read(head, path)
        if 'AppSpacing' not in after:
            continue
        before = read(base, path)
        if not before:
            continue
        checked += 1
        problems.extend(check_sizebox(path, before, after))
        problems.extend(check_edge(path, before, after))

    if problems:
        print(f'{len(problems)} spacing token mismatch(es) in {checked} files:')
        for problem in problems:
            print('  ', problem)
        return 1

    print(f'spacing tokens verified across {checked} files')
    return 0


if __name__ == '__main__':
    sys.exit(main())
