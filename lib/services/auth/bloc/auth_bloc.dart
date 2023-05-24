import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secondflutter/services/auth/auth_provider.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnitialized(isLoading: true)) {
    //only send a email verification we dont do anything to the screen
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );
    on<AuthEventShouldRegsiter>(
      (event, emit) {
        emit(const AuthStateRegistering(isLoading: false, excption: null));
      },
    );
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateorgotPasseord(
            exception: null, hasSentEmail: false, isLoading: false));
        final email = event.email;
        if (email == null) {
          return;
        } //user just want to go to forgotpassword screen
        emit(const AuthStateorgotPasseord(
            exception: null,
            hasSentEmail: false,
            isLoading:
                true)); //user wants to actuallly send a forgot password email

        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }

        emit(AuthStateorgotPasseord(
            exception: exception,
            hasSentEmail: didSendEmail,
            isLoading: false));
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(excption: e, isLoading: false));
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
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLOgin(user: user, isLoading: false));
      }
    }));
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
          excption: null,
          isLoading: true,
          loadingText: 'please wait hile i log you in'));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(excption: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(excption: null, isLoading: false));
          emit(AuthStateLOgin(user: user, isLoading: false));
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
