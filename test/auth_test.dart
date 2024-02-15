import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

void main(){
  group("Mock Authentication", () { 
    final provider = MockAuthProvider();
    test("Should not be initialized", () {
      expect(provider.isInitialized, false);
    });

    test("cannot log out if not initialzed", (){
      expect(provider.logout(), throwsA(const TypeMatcher<NotInitializedError>()));
    });

    test("should be able to initialize", () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after login", () {
    expect(provider.currentUser, null);
    });

    test("Should be able to initialize in less than 2 seconds", () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("Create user should delegate to login", () async{
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: "anything");
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundException>()));

      final badPasswordUser = provider.createUser(email: 'something@bar.com', password: 'foobar');
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);

      expect(user.isEmailVerified, false);
    });

    test("logged in user should be able to get verified", () {
      provider.verifyEmail();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("should be able to logout and login again", () async {
      await provider.logout();
      await provider.login(email: 'email', password: 'password');

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });

}

class NotInitializedError implements Exception{}
class MockAuthProvider implements AuthProvider{

  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;
  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    if (!isInitialized){
      throw NotInitializedError();
    }
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitialized){
      throw NotInitializedError();
    }
    if (email=='foo@bar.com') throw UserNotFoundException();
    if (password=='foobar') throw WrongPasswordException();
    const user = AuthUser(isEmailVerified:false, email: 'foo@bar.com',id: 'my_id');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async{
    if (!isInitialized){
      throw NotInitializedError();
    }
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> verifyEmail() async{
    if (!isInitialized){
      throw NotInitializedError();
    }
    final user = _user;
    if (user==null) throw UserNotFoundException();
    const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com',id: 'my_id');
    _user = newUser;
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }

}