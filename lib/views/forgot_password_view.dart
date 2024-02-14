import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/design/box/frosted_glass.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';
import 'package:mynotes/utils/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc,AuthState>(
      listener:(context, state) async{
        if(state is AuthStateForgotPassword){
          if(state.hasSentEmail){
            _controller.clear();
            await showPasswordResetDialog(context);
          }
          if(state.exception!=null){
            await showErrorDialog(context, 'We could not process your request. Please make sure you have registered first');
          }
        }
    }, child: Scaffold(
      backgroundColor: Colors.black,
      body:  Padding(
        padding: const EdgeInsets.only(top:80.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:  EdgeInsets.only(left:25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Enter your email to', style: TextStyle(color: Colors.white30,fontSize: 30,)),
                     Text('Reset your Password',style: TextStyle(color: Colors.white,fontSize: 45),)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:60.0),
                child: Center(
                  child: Column(
                    children: [
                      FrostedGlassBox(
                        theWidth: 350.0,
                        theHeight: 100.0,
                        theChild: TextField(
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.white),
                          autofocus: true,
                          controller: _controller,
                          decoration: const InputDecoration(hintText: "Enter Email Address",hintStyle: TextStyle(color: Colors.white70)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:25.0),
                        child: Column(
                          children: [
                            TextButton(onPressed:() {
                              final email = _controller.text;
                              context.read<AuthBloc>().add(AuthEventForgotPassword(email));
                            }, child: const Text("Send Password Reset Link",style: TextStyle(color: Colors.white,fontSize: 20))),
                            TextButton(onPressed:() {
                              context.read<AuthBloc>().add(const AuthEventLogOut());
                            }, child: const Text('Back to Login Page',style: TextStyle(color: Colors.white,fontSize: 20)))
                          ],
                        ),
                      ),
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