import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState){    
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;
            if (currentUser!=null){
              // currentUser.reload();
              // print(currentUser);
              if (currentUser.isEmailVerified){
                return NotesView();
              }else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }
            
          default:
            return const Text("Loading");
        }
      }
    );
  }
}