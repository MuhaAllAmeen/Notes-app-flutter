import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth,FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider{
  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user!=null){
        return user;
      }else{
        throw UserNotLoggedInException();
      }
    }on FirebaseAuthException catch(e){
      if (e.code == "weak-password")
        {throw WeakPasswordException();}
      else if(e.code == "email-already-in-use")
        {throw EmailAlreadyInUseException();}
      else if(e.code == "invalid-email"){
        throw InvalidEmailException();
      }
      else{
        throw GenericException();
      }
    }catch(e){
      throw GenericException();
    }
  }

  @override
  AuthUser? get currentUser {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser!=null){
      return AuthUser.fromFirebase(currentUser);
    }else{
      return null;
    }
  }

  @override
  Future<AuthUser> login({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user!=null){
        return user;
      }else{
        throw UserNotLoggedInException();
      }

    }on FirebaseAuthException catch(e){
      if (e.code == "user-not-found"){
        throw UserNotFoundException();
      }
      else if(e.code == "wrong-password"){
        throw WrongPasswordException();
      }
      else{
        throw InvalidCredentialsException();
      }
    }catch(e){
      throw GenericException();
    }
  }

  @override
  Future<void> logout() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<void> verifyEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null){
      await user.sendEmailVerification();
    }else{
      throw UserNotLoggedInException();
    }
  }
  
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch(e){
      switch(e.code){
        case 'firebase_auth/invalid-email':
          throw InvalidEmailException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundException();
        default:
          throw GenericException();
      }
    }catch(e){
      throw GenericException();
    }
  }
  
}