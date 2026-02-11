import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/auth/domain/entities/user_entity.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrobravo/features/auth/data/models/user_model.dart';
import 'dart:developer';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

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
      return Right(
        UserEntity(
          id: response.user!.id,
          email: email,
          name: name,
          roles: [userType],
        ),
      );
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Erro inesperado ao cadastrar.'));
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
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
      return some(userModel.toEntity());
    } catch (e) {
      log('Erro ao recuperar usuário atual: $e');
      // Se falhar ao pegar o perfil, desloga ou retorna none?
      // Retornar none força um novo login, o que é seguro.
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
    } catch (e) {
      return Left(Exception('Erro ao fazer login com Apple.'));
    }
  }
}
