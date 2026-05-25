final emailRegex = RegExp(
  r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
);

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

String? passwordValidator(
  String? v, {
  required String emptyError,
  required String lengthError,
}) {
  final value = v?.trim() ?? '';

  if (value.isEmpty) return emptyError;
  if (value.length < 6 || value.length > 128) return lengthError;

  return null;
}

String? passwordConfirmValidator(
  String? v, {
  required String password,
  required String emptyError,
  required String noMatchError,
}) {
  final value = v?.trim() ?? '';

  if (value.isEmpty) return emptyError;
  if (value != password.trim()) return noMatchError;

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
