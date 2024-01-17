import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          children: [const Text("Verify Your Email Address"),
          TextButton(onPressed: () async{
            final currentUser = FirebaseAuth.instance.currentUser;
            await currentUser?.sendEmailVerification(); 
          }, 
          child: const Text("Verify"))],
        ),
    );    
  }
}