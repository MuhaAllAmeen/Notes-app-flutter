import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){    
            case ConnectionState.done:
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser?.emailVerified ?? false){
                print ("Email Verified");
              } else{
                print ("Email not verified");
              }
              return const Text("done");
            default:
              return const Text("Loading");
          }
        }
      )
    );
  }
}