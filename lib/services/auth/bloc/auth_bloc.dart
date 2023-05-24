import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secondflutter/services/auth/auth_provider.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUnitialized()) {
    //only send a email verification we dont do anything to the screen
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      },
    );

    on<AuthEventInitialize>(((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        //default state we dont do anything worog and we aren not loading anything
        emit(const AuthStateLoggedOut(excption: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLOgin(user));
      }
    }));
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(excption: null, isLoading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(excption: null, isLoading: false));
          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(excption: null, isLoading: false));
          emit(AuthStateLOgin(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(excption: e, isLoading: false));
      }
    });
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(excption: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(excption: e, isLoading: false));
      }
    });
  }
}
