import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent {
  const AuthEventLogin(this.email, this.password);
  final String email;
  final String password;
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
