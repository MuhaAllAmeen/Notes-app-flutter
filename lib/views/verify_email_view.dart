import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
          children: [const Text("A verification Email has been sent"),
          const Text("Press the button to send the link again"),
          TextButton(onPressed: () async{
            final currentUser = FirebaseAuth.instance.currentUser;
            await currentUser?.sendEmailVerification(); 
          }, 
          child: const Text("Verify")),
          TextButton(onPressed: ()async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text("Restart"))],
        ),
    );    
  }
}