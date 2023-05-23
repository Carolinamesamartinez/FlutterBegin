import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secondflutter/services/auth/auth_provider.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(((event, emit) async {
      provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLOgin(user));
      }
    }));
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoading());
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        emit(AuthStateLOgin(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });
    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogOutFailure(e));
      }
    });
  }
}
