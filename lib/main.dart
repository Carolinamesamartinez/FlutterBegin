import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:secondflutter/constants/routes.dart';
import 'package:secondflutter/helpers/loading/loading_screen.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
import 'package:secondflutter/services/auth/bloc/auth_bloc.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';
import 'package:secondflutter/services/auth/firebase_auth_provider.dart';
import 'package:secondflutter/views/forgot_password_view.dart';
import 'package:secondflutter/views/login_view.dart';
import 'package:secondflutter/views/notes/create_update_note_view.dart';
import 'package:secondflutter/views/notes/notes_view.dart';
import 'package:secondflutter/views/register_view.dart';
import 'package:secondflutter/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRow: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //we are sending intialize events to out authbloc
    context.read<AuthBloc>().add(const AuthEventInitialize());
    //Blocbuilder
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLOgin) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateorgotPasseord) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
