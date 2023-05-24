import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:secondflutter/constants/routes.dart';
import 'package:secondflutter/services/auth/auth_exceptions.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
import 'package:secondflutter/services/auth/bloc/auth_bloc.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';
import 'package:secondflutter/utilities/dialogs/error_dialog.dart';
import 'package:secondflutter/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  //iw we use the closedialog this is gonna give a function back

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.excption is UserNotFound) {
            await showErrorDialog(context, 'user not found');
          } else if (state.excption is WrongPassword) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.excption is GenericAuthException) {
            await showErrorDialog(context, 'Wrong ');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              controller: _email,
              decoration: const InputDecoration(hintText: 'Enter your email'),
            ),
            TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _password,
              decoration:
                  const InputDecoration(hintText: 'Enter your password'),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogin(email, password));
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegsiter());
              },
              child: const Text("note register yet? Register here"),
            )
          ],
        ),
      ),
    );
  }
}
