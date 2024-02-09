import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

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
            context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
          }, 
          child: const Text("Verify")),
          TextButton(onPressed: () {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          }, child: const Text("Restart"))],
        ),
    );    
  }
}