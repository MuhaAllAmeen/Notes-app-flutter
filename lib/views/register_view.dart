import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';

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
      listener: (context, state) async{
        if(state is AuthStateRegistering){
          if(state.exception is WeakPasswordException){
            await showErrorDialog(context, "Weak Password");

          }else if (state.exception is EmailAlreadyInUseException){
            await showErrorDialog(context, "Email already in use");

          }else if (state.exception is GenericException){
            await showErrorDialog(context, "Cannot Register");

          }else if (state.exception is InvalidEmailException){
            await showErrorDialog(context, "Invalid email");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Column(
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
            TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(AuthEventRegister(email, password));
                },
                child: const Text("Register")),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text("Existing User? Login Here"))
          ],
        ),
      ),
    );
  }
}
