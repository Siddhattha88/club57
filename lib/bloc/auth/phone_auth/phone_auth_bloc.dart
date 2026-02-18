import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oxoo/server/phone_auth_repository.dart';
import '../../../constants.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final UserRepository _userRepository;
  // ignore: cancel_subscriptions
  StreamSubscription? subscription;
  String verID = "";

  PhoneAuthBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(InitialLoginState()){
          on<SendOtpEvent>(_onSendOtpEvent);
      }

  Future<void> _onSendOtpEvent(
      SendOtpEvent event, Emitter<PhoneAuthState> emit) async {
    try {
      emit(LoadingState());
      try {
        subscription = sendOtp(event.phoNo!).listen((event) {
          add(OtpSendEvent());  // Dispatch the received event back to the bloc
        });
      } catch (e) {
        emit(ExceptionState(message: "Failed to send OTP"));
      }
    } catch (error) {
      emit(ExceptionState(message: "Failed to send OTP"));
    }
  }

  @override
  Stream<PhoneAuthState> mapEventToState(PhoneAuthEvent event) async* {
    if (event is SendOtpEvent) {
      yield LoadingState(); // Show loading while OTP is being sent
      try {
        subscription = sendOtp(event.phoNo!).listen((event) {
          add(event);  // Dispatch the received event back to the bloc
        });
      } catch (e) {
        yield ExceptionState(message: "Failed to send OTP");
      }
    } else if (event is OtpSendEvent) {
      yield OtpSentState();
    } else if (event is LoginCompleteEvent) {
      yield LoginCompleteState(event.firebaseUser);
    } else if (event is LoginExceptionEvent) {
      yield ExceptionState(message: event.message);
    } else if (event is VerifyOtpEvent) {
      yield LoadingState();
      try {
        UserCredential result = await _userRepository.verifyAndLogin(verID, event.otp!);
        if (result.user != null) {
          yield LoginCompleteState(result.user);
        } else {
          yield OtpExceptionState(message: "Invalid OTP!");
        }
      } catch (e) {
        yield OtpExceptionState(message: "Invalid OTP!");
        printLog(e);
      }
    }
  }

  @override
  void onEvent(PhoneAuthEvent event) {
    super.onEvent(event);
    printLog(event);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    printLog(stacktrace);
  }

  Future<void> close() async {
    printLog("Bloc closed");
    await subscription?.cancel();  // Cancel the subscription when the bloc is closed
    super.close();
  }

  // This function handles the OTP sending and state management
  Stream<PhoneAuthEvent> sendOtp(String phoNo) async* {
    final phoneVerificationCompleted = (AuthCredential authCredential) {
      _userRepository.getUser().catchError((onError) {
        printLog(onError);
      }).then((user) {
        add(LoginCompleteEvent(user));  // Dispatch event to bloc
      });
    };

    final phoneVerificationFailed = (authException) {
      printLog("Phone verification failed: ${authException.message}");
      add(SendOtpEvent());// Dispatch failure event
    };

    final phoneCodeSent = (String verId, [int? forceResent]) {
      this.verID = verId;
      printLog("OTP Sent: $verID");
      add(OtpSendEvent());  // Dispatch OTP sent event
    };

    final phoneCodeAutoRetrievalTimeout = (String verid) {
      this.verID = verid;
    };

    // Send OTP via repository
    await _userRepository.sendOtp(
      phoNo,
      Duration(seconds: 1),
      phoneVerificationFailed,
      phoneVerificationCompleted,
      phoneCodeSent,
      phoneCodeAutoRetrievalTimeout,
    );
  }
}
