final emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$');

String? emailValidator(
  String? v, {
  required String emptyError,
  required String formatError,
}) {
  final value = v?.trim() ?? '';

  if (value.isEmpty) return emptyError;
  if (!emailRegex.hasMatch(value)) return formatError;

  return null;
}

// Passwords are not trimmed: leading/trailing spaces are part of the secret
// the user chose, and silently altering them causes login mismatches.
// The upper bound matches the server policy (bcrypt truncates at 72 bytes).
String? passwordValidator(
  String? v, {
  required String emptyError,
  required String lengthError,
}) {
  final value = v ?? '';

  if (value.isEmpty) return emptyError;
  if (value.length < 6 || value.length > 72) return lengthError;

  return null;
}

String? passwordConfirmValidator(
  String? v, {
  required String password,
  required String emptyError,
  required String noMatchError,
}) {
  final value = v ?? '';

  if (value.isEmpty) return emptyError;
  if (value != password) return noMatchError;

  return null;
}

String? verificationCodeValidator(
  String? v, {
  required String emptyError,
  required String lengthError,
}) {
  final value = v?.trim() ?? '';

  if (value.isEmpty) return emptyError;
  if (value.length < 4) return lengthError;

  return null;
}
