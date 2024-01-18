import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/utils/error_dialog.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
            decoration: const InputDecoration(
              hintText: "Email"
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: "Password"
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password,);
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser?.emailVerified ?? false){
                  Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false,);
                }else{
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false,);
                }
                
              } on FirebaseAuthException catch (e) {
                if (e.code == "user-not-found"){
                  await showErrorDialog(context, "User Not Found");
                }
                else if(e.code == "wrong-password"){
                    await showErrorDialog(context, "Incorrect Password");
                  }
                  else{
                    await showErrorDialog(context, e.code);
                  }
              }catch(e){
                await showErrorDialog(context, e.toString());
              }     
            },
            child: const Text("Login")),
            TextButton(onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute,
              (route) => false);
            },
             child: const Text("New User? Register Here"))
        ],
      ),
    );
  } 
}