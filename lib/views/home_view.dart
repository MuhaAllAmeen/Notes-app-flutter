import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState){    
          case ConnectionState.done:
            // final currentUser = FirebaseAuth.instance.currentUser;
            // if (currentUser?.emailVerified ?? false){
            //   return const Text("done");
            // } else{
            //   return const VerifyEmailView();
            // }
            return const LoginView();
          default:
            return const Text("Loading");
        }
      }
    );
  }
}