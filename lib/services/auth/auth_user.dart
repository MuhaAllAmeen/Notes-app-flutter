import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; 

@immutable
class AuthUser{
  final String id;
  final bool isEmailVerified;
  final String email;

  const AuthUser({required this.id, required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(email:user.email!,isEmailVerified:user.emailVerified,id: user.uid);

}