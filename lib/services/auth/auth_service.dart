import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider{
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  
  @override
  Future<AuthUser> createUser({required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }
  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<AuthUser> login({required String email, required String password}) {
    return provider.login(email: email, password: password);
  }
  
  @override
  Future<void> logout() {
    return provider.logout();
  }
  
  @override
  Future<void> verifyEmail() {
    return provider.verifyEmail();
  }
  
  @override
  Future<void> initialize() {
    return provider.initialize();
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail})=> provider.sendPasswordReset(toEmail: toEmail);

}