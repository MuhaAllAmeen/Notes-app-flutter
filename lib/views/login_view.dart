import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/design/box/frosted_glass.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';

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
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top:80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left:25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Login to', style: TextStyle(color: Colors.white30,fontSize: 30,fontFamily: 'PlayfairDisplay'),),
                      Text('Your Notes',style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'PlayfairDisplay',fontWeight: FontWeight.bold),),                  
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Center(
                        child: FrostedGlassBox(
                          theWidth: 350.0,
                          theHeight: 200.0,
                          theChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                controller: _email,
                                cursorColor: Colors.white,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(hintText: "Email",hintStyle: TextStyle(color: Colors.white70)),
                              ),
                              TextField(
                                controller: _password,
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(hintText: "Password",hintStyle: TextStyle(color: Colors.white70)),
                                          ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top:25.0),
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () async {
                              final email = _email.text;
                              final password = _password.text;
                              context
                                  .read<AuthBloc>()
                                  .add(AuthEventLogIn(email, password));
                            },
                            child: const Text("Login",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),)),
                        TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthEventShouldRegister());
                            },
                            child: const Text("New User? Register Here",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Quicksand',fontWeight: FontWeight.bold))),
                        TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthEventForgotPassword(null));
                            },
                            child: const Text("Forgot Password",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Quicksand',fontWeight: FontWeight.bold)))
                        ],
                      ),
                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
