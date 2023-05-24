import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:secondflutter/services/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUnitialized extends AuthState {
  const AuthStateUnitialized();
}

class AuthStateLOgin extends AuthState {
  final AuthUser user;
  const AuthStateLOgin(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? excption;
  final bool isLoading;
  const AuthStateLoggedOut({required this.excption, required this.isLoading});
  //child states of the father state
  @override
  List<Object?> get props => [excption, isLoading];
}

class AuthStateRegistering extends AuthState {
  final Exception? excption;
  const AuthStateRegistering(this.excption);
}
