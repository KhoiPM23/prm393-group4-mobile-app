import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/firebase_user_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginSubmitted>(_onGoogleLoginSubmitted);
  }

  final UserRepository _userRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await _userRepository.login(event.email, event.password);
      emit(LoginSuccess());
    } on AuthException catch (error) {
      emit(LoginFailure(error: error.message));
    } catch (_) {
      emit(LoginFailure(error: 'Dang nhap that bai. Vui long thu lai.'));
    }
  }

  Future<void> _onGoogleLoginSubmitted(
    GoogleLoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _userRepository.loginWithGoogle();
      if (user == null) {
        emit(LoginInitial());
        return;
      }
      emit(LoginSuccess());
    } on AuthException catch (error) {
      emit(LoginFailure(error: error.message));
    } catch (_) {
      emit(LoginFailure(error: 'Dang nhap Google that bai. Vui long thu lai.'));
    }
  }
}
