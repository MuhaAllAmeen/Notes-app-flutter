import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';
import 'package:mynotes/utils/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      listener: (context, state) async{
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundException) {
            await showErrorDialog(context, "User Not Found");
          } else if (state.exception is WrongPasswordException) {
            await showErrorDialog(context, "Incorrect Password");
          } else if (state.exception is InvalidCredentialsException) {
            await showErrorDialog(context, "Invalid Credentials");
          } else if (state.exception is GenericException) {
            await showErrorDialog(context, "Cannot LogIn");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _email,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(hintText: "Password"),
              ),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  
                },
                child: TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      context
                          .read<AuthBloc>()
                          .add(AuthEventLogIn(email, password));
                    },
                    child: const Text("Login")),
              ),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventShouldRegister());
                  },
                  child: const Text("New User? Register Here")),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventForgotPassword(null));
                  },
                  child: const Text("Forgot Password"))
            ],
          ),
        ),
      ),
    );
  }
}
