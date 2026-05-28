import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/home/presentation/cubit/feed_cubit.dart';
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
        try { getIt<ProfileCubit>().loadProfile(user.id); } catch (_) {}
        try { getIt<DocumentsCubit>().loadDocuments(); } catch (_) {}
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
    final normalizedEmail = email.trim().toLowerCase();
    emit(const AuthState.loading());

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('remembered_email', normalizedEmail);
    } else {
      await prefs.remove('remembered_email');
    }

    final result = await _authRepository.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    await result.fold(
      (error) async {
        final errorStr = error.toString().replaceAll('Exception: ', '');
        if (errorStr == 'email_not_confirmed') {
          emit(const AuthState.error('E-mail não confirmado. Verifique sua caixa de entrada.'));
        } else {
          emit(AuthState.error(errorStr));
        }
      },
      (user) async {
        await _clearUserCache();
        try { getIt<ItineraryCubit>().reset(); } catch (_) {}
        try { getIt<ProfileCubit>().loadProfile(user.id); } catch (_) {}
        try { getIt<DocumentsCubit>().loadDocuments(); } catch (_) {}
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
    final normalizedEmail = email.trim().toLowerCase();
    if (name.trim().isEmpty) {
      emit(const AuthState.error('Informe seu nome.'));
      return;
    }

    if (normalizedEmail.isEmpty) {
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
      email: normalizedEmail,
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
          await _clearUserCache();
          try { getIt<ItineraryCubit>().reset(); } catch (_) {}
          try { getIt<ProfileCubit>().loadProfile(user.id); } catch (_) {}
          try { getIt<DocumentsCubit>().loadDocuments(); } catch (_) {}
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
    final normalizedEmail = email.trim().toLowerCase();
    emit(const AuthState.loading());
    final result = await _authRepository.resetPassword(normalizedEmail);
    result.fold(
      (error) => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) => emit(AuthState.otpSent(email)),
    );
  }

  Future<void> resendConfirmationEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    emit(const AuthState.loading());
    final result = await _authRepository.resendConfirmationEmail(normalizedEmail);
    result.fold(
      (error) => emit(AuthState.error(error.toString().replaceAll('Exception: ', ''))),
      (_) => emit(const AuthState.registrationSuccess(
        message: 'E-mail de confirmação reenviado com sucesso! Verifique sua caixa de entrada.',
        needsEmailConfirmation: true,
      )),
    );
  }

  Future<void> verifyOtp(String email, String token) async {
    final normalizedEmail = email.trim().toLowerCase();
    emit(const AuthState.loading());
    final result = await _authRepository.verifyOtp(
      email: normalizedEmail,
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
            await _clearUserCache();
            try { getIt<ItineraryCubit>().reset(); } catch (_) {}
            try { getIt<ProfileCubit>().loadProfile(user.id); } catch (_) {}
            try { getIt<DocumentsCubit>().loadDocuments(); } catch (_) {}
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
            await _clearUserCache();
            try { getIt<ItineraryCubit>().reset(); } catch (_) {}
            try { getIt<ProfileCubit>().loadProfile(user.id); } catch (_) {}
            try { getIt<DocumentsCubit>().loadDocuments(); } catch (_) {}
            await OnboardingService.instance.initialize(user.id);
            emit(AuthState.authenticated(user));
          },
        );
      },
    );
  }

  Future<void> logout() async {
    // Reset itinerary, profile, documents, notifications and feed state before signing out so the next
    // login triggers a full reload and clears cached user-specific data from memory.
    await _clearUserCache();
    try {
      getIt<ItineraryCubit>().reset();
    } catch (_) {}
    try {
      getIt<ProfileCubit>().reset();
    } catch (_) {}
    try {
      getIt<DocumentsCubit>().reset();
    } catch (_) {}
    try {
      getIt<NotificationsCubit>().reset();
    } catch (_) {}
    try {
      getIt<FeedCubit>().reset();
    } catch (_) {}
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString('remembered_email');
      final themeMode = prefs.getInt('theme_mode');

      // Preserve Supabase session keys so the stored session survives cache
      // clearance. supabase_flutter 2.x stores the session under a key of the
      // form "sb-<project-ref>-auth-token". Clearing it here would cause
      // currentSession to be null on every cold start, forcing re-login.
      final supabaseKeys = prefs
          .getKeys()
          .where((k) => k.startsWith('sb-') && k.endsWith('-auth-token'))
          .toList();
      final supabaseValues = <String, String>{};
      for (final k in supabaseKeys) {
        final v = prefs.getString(k);
        if (v != null) supabaseValues[k] = v;
      }

      await prefs.clear();

      if (rememberedEmail != null) {
        await prefs.setString('remembered_email', rememberedEmail);
      }
      if (themeMode != null) {
        await prefs.setInt('theme_mode', themeMode);
      }
      for (final entry in supabaseValues.entries) {
        await prefs.setString(entry.key, entry.value);
      }
    } catch (e) {
      log('Erro ao limpar cache de SharedPreferences: $e');
    }
  }
}
