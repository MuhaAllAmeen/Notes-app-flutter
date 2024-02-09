import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc,AuthState>(builder:(context, state) {
      if (state is AuthStateLoggedIn){
        return const NotesView();
      } else if(state is AuthStateNeedsVerification){
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut){
        return const LoginView();
      } else{
        return const Scaffold( body: CircularProgressIndicator(),);
      }
    },);
    // return FutureBuilder(
    //   future: AuthService.firebase().initialize(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState){    
    //       case ConnectionState.done:
    //         final currentUser = AuthService.firebase().currentUser;
    //         if (currentUser!=null){
    //           // currentUser.reload();
    //           // print(currentUser);
    //           if (currentUser.isEmailVerified){
    //             return const NotesView();
    //           }else{
    //             return const VerifyEmailView();
    //           }
    //         }else{
    //           return const LoginView();
    //         }
            
    //       default:
    //         return const Text("Loading");
    //     }
    //   }
    // );
  }
}