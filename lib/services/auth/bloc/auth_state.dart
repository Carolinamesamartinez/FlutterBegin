import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:secondflutter/services/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState(
      {required this.isLoading, this.loadingText = 'Please wait a moment'});
}

class AuthStateUnitialized extends AuthState {
  const AuthStateUnitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLOgin extends AuthState {
  final AuthUser user;
  const AuthStateLOgin({required bool isLoading, required this.user})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? excption;
  const AuthStateLoggedOut(
      {required this.excption, required bool isLoading, String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);
  //child states of the father state
  @override
  List<Object?> get props => [excption, isLoading];
}

class AuthStateRegistering extends AuthState {
  final Exception? excption;
  const AuthStateRegistering({required bool isLoading, required this.excption})
      : super(isLoading: isLoading);
}
