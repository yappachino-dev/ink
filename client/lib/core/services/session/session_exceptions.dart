class SessionLockedException implements Exception {
  const SessionLockedException([
    this.message = 'The app session is currently locked',
  ]);

  final String message;

  @override
  String toString() => 'SessionLockedException: $message';
}
