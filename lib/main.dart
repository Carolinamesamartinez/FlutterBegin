import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:secondflutter/constants/routes.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        regsiterRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRow: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
