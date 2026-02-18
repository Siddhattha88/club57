import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../server/repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Repository repository;
  LoginBloc(this.repository) : super(LoginIsNotStartState()) {
    on<LoginCompletingStarted>(_onLoginCompletingStarted);
    on<LoginCompletingFailed>(_onLoginCompletingFailed);
    on<LoginCompleting>(_onLoginCompleting);
    on<LoginCompletingNotStarted>(_onLoginCompletingNotStarted);
  }

  Future<void> _onLoginCompletingStarted(LoginCompletingStarted event, Emitter<LoginState> emit) async {
    emit(LoginCompletingStartedState());
  }

  Future<void> _onLoginCompletingFailed(LoginCompletingFailed event, Emitter<LoginState> emit) async {
    emit(LoginCompletingFailedState());
  }

  Future<void> _onLoginCompleting(LoginCompleting event, Emitter<LoginState> emit) async {
    AuthUser? userServerData = await repository.getLoginAuthUser(event.email, event.password);
    emit(LoginCompletingStateCompleted(userServerData));
  }

  Future<void> _onLoginCompletingNotStarted(LoginCompletingNotStarted event, Emitter<LoginState> emit) async {
    emit(LoginIsNotStartState());
  }
}
