import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState>{
  AuthBloc(AuthProvider provider): super(const AuthStateUninitialized()){
    on<AuthEventSendEmailVerification>((event, emit) async{
      await provider.verifyEmail();
      emit(state);
    },);
    on<AuthEventRegister> ((event, emit) async{
      final email = event.email;
      final password = event.password;
      try{
        await provider.createUser(email: email, password: password);
        await provider.verifyEmail();
        emit(const AuthStateNeedsVerification());
      }on Exception catch(e){
        emit(AuthStateRegistering(e));
      }
    },);
    on<AuthEventInitialize>((event, emit) async{
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(null,false));
      } else if(!user.isEmailVerified){
        emit(const AuthStateNeedsVerification());
      }else{
        emit(AuthStateLoggedIn(user));
      }
    });
    on<AuthEventLogIn>((event, emit) async{
      emit(const AuthStateLoggedOut(null, true));
      final email = event.email;
      final password = event.password;
      try{
        final user = await provider.login(email: email, password: password);
        if(!user.isEmailVerified){
          emit(const AuthStateLoggedOut(null, false));
          emit(const AuthStateNeedsVerification());
        }else{
          emit(const AuthStateLoggedOut(null, false));     
          emit(AuthStateLoggedIn(user));   
        }
        emit(AuthStateLoggedIn(user));
      }on Exception catch(e){
        emit(AuthStateLoggedOut(e,false));
      }
    });
    on<AuthEventLogOut>((event, emit) async{
      try{
        await provider.logout();
        emit(const AuthStateLoggedOut(null,false));
      } on Exception catch(e){
        emit(AuthStateLoggedOut(e,false));
      }    
    });
  }
}