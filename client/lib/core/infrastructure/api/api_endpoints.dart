const String _apiBase = '/api/v1';
const String _authBase = '$_apiBase/auth';
const String _protectedBase = '$_apiBase/protected';
const String _userBase = '$_protectedBase/me';

const String login = '$_authBase/login';
const String requestVerification = '$_authBase/verify-email';
const String register = '$_authBase/confirm-register';
const String refresh = '$_authBase/refresh';
const String logout = '$_authBase/logout';

const String me = _userBase;
const String keySlots = '$_userBase/keys';

const String sync = '$_protectedBase/sync';
