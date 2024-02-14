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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top:80.0),
          child: 
            Padding(
              padding: const EdgeInsets.only(left:25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("A verification Email has been sent", style: TextStyle(color: Colors.white30,fontSize: 30,),),
                       Text("Press the button \nto send the \nlink again",style: TextStyle(color: Colors.white,fontSize: 45)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:60.0),
                    child: Center(
                      child: Column(
                        children: [
                          TextButton(onPressed: () async{
                            context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
                          }, 
                          child: const Text("Verify",style: TextStyle(color: Colors.white,fontSize: 20),)),
                          TextButton(onPressed: () {
                            context.read<AuthBloc>().add(const AuthEventLogOut());
                          }, child: const Text("Restart",style: TextStyle(color: Colors.white,fontSize: 20),))
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