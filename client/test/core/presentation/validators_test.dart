import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/validators.dart';

void main() {
  group('emailValidator', () {
    const error = 'bad email';

    String? validate(String v) =>
        emailValidator(v, emptyError: 'empty', formatError: error);

    test('accepts standard addresses', () {
      expect(validate('user@example.com'), isNull);
      expect(validate('first.last+tag@sub.example.co'), isNull);
    });

    test('accepts long TLDs that the old regex rejected', () {
      expect(validate('user@example.museum'), isNull);
      expect(validate('user@example.technology'), isNull);
    });

    test('rejects malformed addresses', () {
      expect(validate('no-at-sign'), error);
      expect(validate('a@b'), error);
      expect(validate('@example.com'), error);
    });
  });

  group('passwordValidator', () {
    const length = 'weak password';

    String? validate(String v) =>
        passwordValidator(v, emptyError: 'empty', lengthError: length);

    test('enforces 6..72 characters to mirror the server policy', () {
      expect(validate('12345'), length);
      expect(validate('123456'), isNull);
      expect(validate('x' * 72), isNull);
      expect(validate('x' * 73), length);
    });

    test('does not trim: spaces are part of the secret', () {
      expect(validate('  pass  '), isNull);
      expect(validate('       '), isNull, reason: '7 spaces is a valid secret');
    });
  });

  group('passwordConfirmValidator', () {
    String? validate(String v, String password) => passwordConfirmValidator(
      v,
      password: password,
      emptyError: 'empty',
      noMatchError: 'mismatch',
    );

    test('matches without trimming either side', () {
      expect(validate('secret  ', 'secret  '), isNull);
      expect(validate('secret', 'secret  '), 'mismatch');
      expect(validate('', 'secret'), 'empty');
    });
  });

  test('verificationCodeValidator enforces minimum length', () {
    expect(
      verificationCodeValidator('', emptyError: 'empty', lengthError: 'short'),
      'empty',
    );
    expect(
      verificationCodeValidator(
        '123',
        emptyError: 'empty',
        lengthError: 'short',
      ),
      'short',
    );
    expect(
      verificationCodeValidator(
        '123456',
        emptyError: 'empty',
        lengthError: 'short',
      ),
      isNull,
    );
  });
}
