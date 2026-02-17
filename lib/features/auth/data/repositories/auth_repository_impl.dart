import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/auth/domain/entities/user_entity.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrobravo/features/auth/data/models/user_model.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  Future<void> _saveUserToPreferences(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_profile', jsonEncode(user.toJson()));
    } catch (e) {
      log('Erro ao salvar usuário no cache: $e');
    }
  }

  Future<UserModel?> _getUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_user_profile');
      if (jsonString != null) {
        return UserModel.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      log('Erro ao recuperar usuário do cache: $e');
    }
    return null;
  }

  @override
  Future<Either<Exception, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(Exception('Login falhou: Usuário não retornado.'));
      }

      // Buscar dados complementares na tabela public.users
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userModel = UserModel.fromJson(userProfile);
      await _saveUserToPreferences(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      log('Auth Error: ${e.message}');
      return Left(Exception(e.message));
    } catch (e) {
      log('Unexpected Error: $e');
      return Left(Exception('Erro inesperado ao fazer login.'));
    }
  }

  @override
  Future<Either<Exception, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      // Enviar metadados para que (se houver trigger) o banco saiba o que fazer
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nome': name,
          'tipouser': [userType], // Envia como array
        },
      );

      if (response.user == null) {
        return Left(Exception('Cadastro falhou.'));
      }

      // Opcional: Inserir manualmente se não houver trigger
      // Por segurança, vamos verificar se o perfil foi criado, se não, criamos.
      try {
        await _supabaseClient.from('users').upsert({
          'id': response.user!.id,
          'nome': name,
          'email': email,
          'tipouser': [userType],
        });
      } catch (e) {
        log('Erro ao criar perfil público (pode já existir via trigger): $e');
      }

      // Retorna a entidade (construída manualmente pois o fetch pode ter delay)
      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        nome: name,
        roles: [userType],
        foto: null,
      );

      // Cache this basic model as well so subsequent immediate offline starts have something
      await _saveUserToPreferences(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Erro inesperado ao cadastrar.'));
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    // Clear cache on sign out
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_profile');
  }

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return none();

    try {
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      final userModel = UserModel.fromJson(userProfile);
      await _saveUserToPreferences(userModel);
      return some(userModel.toEntity());
    } catch (e) {
      log('Erro ao recuperar usuário atual: $e. Tentando cache offline.');
      final cachedUser = await _getUserFromPreferences();
      if (cachedUser != null && cachedUser.id == user.id) {
        return some(cachedUser.toEntity());
      }
      // If we are offline and have no cache, we currently force logout/none.
      // Alternatively, we could construct a basic UserEntity from Supabase User metadata if available,
      // but complete functional offline usage likely requires the profile.
      return none();
    }
  }

  @override
  Future<Either<Exception, void>> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Erro ao solicitar redefinição de senha.'));
    }
  }

  @override
  Future<Either<Exception, void>> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Erro ao atualizar a senha.'));
    }
  }

  @override
  Future<Either<Exception, void>> signInWithGoogle() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.agrobravo://login-callback/',
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Erro ao fazer login com Google.'));
    }
  }

  @override
  Future<Either<Exception, void>> signInWithApple() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? null : 'io.supabase.agrobravo://login-callback/',
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    }
  }

  @override
  Stream<AuthChangeEvent> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange.map((data) => data.event);
}
