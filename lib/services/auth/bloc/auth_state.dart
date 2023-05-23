import 'package:flutter/material.dart' show immutable;
import 'package:secondflutter/services/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLOgin extends AuthState {
  final AuthUser user;
  const AuthStateLOgin(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? excption;
  const AuthStateLoggedOut(this.excption);
}

class AuthStateLogOutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogOutFailure(this.exception);
}
