import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/design/box/frosted_glass.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
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
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top:80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:  EdgeInsets.only(left:25.0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Register to', style: TextStyle(color: Colors.white30,fontSize: 30,),),
                      Text('Your Notes',style: TextStyle(color: Colors.white,fontSize: 45),)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: FrostedGlassBox(
                      theWidth: 350.0, 
                      theHeight: 200.0, 
                      theChild:  
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              autofocus: true,
                              controller: _email,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(hintText: "Email",hintStyle: TextStyle(color: Colors.white70)),
                            ),
                            TextField(
                              autofocus: true,
                              controller: _password,
                              obscureText: true,
                              autocorrect: false,
                              style: const TextStyle(color: Colors.white),
                              enableSuggestions: false,
                              decoration: const InputDecoration(hintText: "Password",hintStyle: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:25.0),
                  child: Center(
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () async {
                              final email = _email.text;
                              final password = _password.text;
                              context.read<AuthBloc>().add(AuthEventRegister(email, password));
                            },
                            child: const Text("Register",style: TextStyle(color: Colors.white,fontSize: 20),)),
                      TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text("Existing User? Login Here",style: TextStyle(color: Colors.white,fontSize: 20)))
                      ],
                    ),
                  ),
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
