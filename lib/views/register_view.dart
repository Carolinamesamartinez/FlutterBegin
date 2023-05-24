import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:secondflutter/constants/routes.dart';
import 'package:secondflutter/services/auth/auth_exceptions.dart';
import 'package:secondflutter/services/auth/auth_service.dart';
import 'package:secondflutter/services/auth/bloc/auth_bloc.dart';
import 'package:secondflutter/services/auth/bloc/auth_event.dart';
import 'package:secondflutter/services/auth/bloc/auth_state.dart';
import 'package:secondflutter/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
        if (state is AuthStateRegistering) {
          if (state.excption is WeakPassword) {
            await showErrorDialog(context, 'weak password');
          } else if (state.excption is EmailAlreadyInUse) {
            await showErrorDialog(context, 'Email Already In Use');
          } else if (state.excption is InvalidEmail) {
            await showErrorDialog(context, 'Invalid Email');
          } else if (state.excption is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('enter your email andr password '),
              TextField(
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autofocus: true,
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
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;

                        context
                            .read<AuthBloc>()
                            .add(AuthEventRegister(email, password));
                      },
                      child: const Text("Register"),
                    ),
                    TextButton(
                        onPressed: () {
                          //send the user to the login screen
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        child: const Text('Already registered? Login here'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
