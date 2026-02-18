import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxoo/models/user_model.dart';
import 'package:oxoo/server/repository.dart';
import 'firebase_auth_event.dart';
import 'firebase_auth_state.dart';

class FirebaseAuthBloc extends Bloc<FirebaseAuthEvent, FirebaseAuthState> {
  final Repository repository;

  FirebaseAuthBloc(this.repository) : super(FirebaseAuthIsNotStartState()){
    on<FirebaseAuthEvent>(_onFirebaseLogin);
  }

  Future<void> _onFirebaseLogin(FirebaseAuthEvent event, Emitter<FirebaseAuthState> emit) async {
    if (event is FirebaseAuthFailed) {
      emit(FirebaseAuthFailedState());
    } else if (event is FirebaseAuthCompleting) {
      AuthUser? userServerData = await repository.getFirebaseAuthUser(
        uid: event.uid,
        email: event.email,
        phone: event.phone,
      );
      emit(FirebaseAuthStateCompleted(userServerData));
    } else if (event is FirebaseAuthNotStarted) {
      emit(FirebaseAuthIsNotStartState());
    } else if (event is FirebaseAuthStarted) {
      emit(FirebaseAuthStartedState());
    }
  }

  @override
  Stream<FirebaseAuthState> mapEventToState(FirebaseAuthEvent event) async* {
    if (event is FirebaseAuthFailed) {
      yield FirebaseAuthFailedState();
    } else if (event is FirebaseAuthCompleting) {
      AuthUser? userServerData = await repository.getFirebaseAuthUser(
        uid: event.uid,
        email: event.email,
        phone: event.phone,
      );
      yield FirebaseAuthStateCompleted(userServerData);
    } else if (event is FirebaseAuthNotStarted) {
      yield FirebaseAuthIsNotStartState();
    } else if (event is FirebaseAuthStarted) {
      yield FirebaseAuthStartedState();
    }
  }
}
