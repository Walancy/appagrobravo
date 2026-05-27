import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

@LazySingleton()
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  void clearError() {
    state.maybeWhen(
      error: (_) => emit(const AuthState.initial()),
      orElse: () {},
    );
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    final userOption = await _authRepository.getCurrentUser();
    await userOption.fold(
      () async => emit(const AuthState.unauthenticated()),
      (user) async {
        try { getIt<ItineraryCubit>().reset(); } catch (_) {}
        await OnboardingService.instance.initialize(user.id);
        log('[ONB] checkAuthStatus done user=${user.id} needsOnboarding=${OnboardingService.instance.needsOnboarding}');
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(const AuthState.loading());

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('remembered_email', email);
    } else {
      await prefs.remove('remembered_email');
    }

    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.fold(
      (error) async =>
          emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (user) async {
        try { getIt<ItineraryCubit>().reset(); } catch (_) {}
        await OnboardingService.instance.initialize(user.id);
        log('[ONB] login done user=${user.id} needsOnboarding=${OnboardingService.instance.needsOnboarding}');
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remembered_email');
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    log('AuthCubit.register: Iniciando validação dos dados de entrada...');
    if (name.trim().isEmpty) {
      emit(const AuthState.error('Informe seu nome.'));
      return;
    }

    if (email.trim().isEmpty) {
      emit(const AuthState.error('Informe seu e-mail.'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthState.error('A senha deve ter pelo menos 6 caracteres.'));
      return;
    }

    if (password != passwordConfirm) {
      emit(const AuthState.error('As senhas não conferem.'));
      return;
    }

    emit(const AuthState.loading());
    log('AuthCubit.register: Validação OK. Chamando _authRepository.signUpWithEmailAndPassword...');
    
    // Default to USER_APP for self-registration via app
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email.trim(),
      password: password,
      name: name.trim(),
      userType: 'USER_APP',
    );

    await result.fold(
      (error) async {
          log('AuthCubit.register: Falha no repositório -> $error');
          emit(AuthState.error(error.toString().replaceAll('Exception: ', '')));
      },
      (user) async {
        log('AuthCubit.register: Sucesso no repositório! Verificando sessão atual...');
        final currentSession = Supabase.instance.client.auth.currentSession;

        if (currentSession != null) {
          log('AuthCubit.register: Sessão ativa encontrada. Logando direto.');
          try { getIt<ItineraryCubit>().reset(); } catch (_) {}
          await OnboardingService.instance.initialize(user.id);
          emit(AuthState.authenticated(user));
        } else {
          log('AuthCubit.register: Sem sessão ativa. Solicitando confirmação de email.');
          emit(const AuthState.registrationSuccess(
            message: 'Conta criada com sucesso! Verifique seu e-mail para confirmar o cadastro.',
            needsEmailConfirmation: true,
          ));
        }
      },
    );
  }

  Future<void> recoverPassword(String email) async {
    emit(const AuthState.loading());
    final result = await _authRepository.resetPassword(email);
    result.fold(
      (error) => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) => emit(AuthState.otpSent(email)),
    );
  }

  Future<void> verifyOtp(String email, String token) async {
    emit(const AuthState.loading());
    final result = await _authRepository.verifyOtp(
      email: email,
      token: token,
    );
    result.fold(
      (error) => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) => emit(const AuthState.otpVerified()),
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
      (error) => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) => emit(const AuthState.passwordUpdated()),
    );
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _authRepository.signInWithGoogle();
    await result.fold(
      (error) async => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) async {
        final userOption = await _authRepository.getCurrentUser();
        await userOption.fold(
          () async => emit(const AuthState.unauthenticated()),
          (user) async {
            try { getIt<ItineraryCubit>().reset(); } catch (_) {}
            await OnboardingService.instance.initialize(user.id);
            emit(AuthState.authenticated(user));
          },
        );
      },
    );
  }

  Future<void> loginWithApple() async {
    emit(const AuthState.loading());
    final result = await _authRepository.signInWithApple();
    await result.fold(
      (error) async => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) async {
        final userOption = await _authRepository.getCurrentUser();
        await userOption.fold(
          () async => emit(const AuthState.unauthenticated()),
          (user) async {
            try { getIt<ItineraryCubit>().reset(); } catch (_) {}
            await OnboardingService.instance.initialize(user.id);
            emit(AuthState.authenticated(user));
          },
        );
      },
    );
  }

  Future<void> logout() async {
    // Reset itinerary + onboarding state before signing out so the next
    // login triggers a full reload (fixes BUG: onboarding/itinerary not
    // shown after re-login when cubit singleton retained stale loaded state).
    try {
      getIt<ItineraryCubit>().reset();
    } catch (_) {}
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
