import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';

@LazySingleton()
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    final userOption = await _authRepository.getCurrentUser();
    userOption.fold(
      () => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (error) =>
          emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    if (password != passwordConfirm) {
      emit(const AuthState.error('As senhas não conferem.'));
      return;
    }

    emit(const AuthState.loading());
    // Default to USER_APP for self-registration via app
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      userType: 'USER_APP',
    );

    result.fold(
      (error) =>
          emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (user) {
        // Could emit a specific state like "VerificationNeeded" if email confirm is on
        // For now, assuming direct login or success message
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> recoverPassword(String email) async {
    emit(const AuthState.loading());
    final result = await _authRepository.resetPassword(email);
    result.fold(
      (error) => emit(AuthState.error(error.toString())),
      (_) => emit(const AuthState.passwordResetEmailSent()),
    );
  }

  Future<void> updatePassword(String password, String confirmPassword) async {
    if (password != confirmPassword) {
      emit(const AuthState.error('As senhas não conferem.'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthState.error('A senha deve ter pelo menos 6 caracteres.'));
      return;
    }

    emit(const AuthState.loading());
    final result = await _authRepository.updatePassword(password);
    result.fold(
      (error) => emit(AuthState.error(error.toString())),
      (_) => emit(const AuthState.passwordUpdated()),
    );
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _authRepository.signInWithGoogle();
    result.fold((error) => emit(AuthState.error(error.toString())), (_) {
      // Since it's OAuth, the browser will redirect.
      // We stay in loading state until the app is resumed and Supabase triggers auth state change.
    });
  }

  Future<void> loginWithApple() async {
    emit(const AuthState.loading());
    final result = await _authRepository.signInWithApple();
    result.fold((error) => emit(AuthState.error(error.toString())), (_) {});
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
