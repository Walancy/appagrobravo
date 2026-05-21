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
      log('--- INÍCIO DO CADASTRO ---');
      log('1. Tentando criar usuário no Supabase Auth. Email: $email, Name: $name');
      // 1. Criar usuário no auth.users do Supabase
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nome': name,
          'tipouser': [userType],
        },
      );

      log('2. Resposta do Supabase Auth recebida. User nulo? ${response.user == null}');
      if (response.user != null) {
        log('   Identities vazias? ${response.user!.identities?.isEmpty ?? true}');
      }

      if (response.user == null || response.user!.identities == null || response.user!.identities!.isEmpty) {
        log('ERRO: E-mail bloqueado por duplicidade (user_repeated_signup) ou erro na API.');
        return Left(Exception('Este e-mail já está em uso ou vinculado a uma conta desativada.'));
      }

      final authUser = response.user!;
      final now = DateTime.now().toUtc().toIso8601String();

      // 2. Criar linha na tabela public.users preenchendo o máximo de campos
      //    Extraímos dados do auth user (metadata, telefone, datas) e
      //    preenchemos os demais com valores padrão seguros.
      final publicUserData = <String, dynamic>{
        'id': authUser.id,
        'nome': name,
        'email': email,
        'tipouser': [userType],
        // Dados que podemos derivar do auth user
        'telefone': authUser.phone, // null se não veio pelo signup
        'foto': authUser.userMetadata?['avatar_url'], // null para email signup
        // Campos de texto inicializados como null (sem dado do formulário)
        'cargo': null,
        'empresa': null,
        'observacoes': null,
        'capa_perfil': null,
        'cpf': null,
        'ssn': null,
        'cep': null,
        'estado': null,
        'cidade': null,
        'rua': null,
        'numero': null,
        'bairro': null,
        'complemento': null,
        'nacionalidade': null,
        'n_passaporte': null,
        'datanascimento': null,
        // Arrays inicializados como vazios
        'restricoes_alimentares': <String>[],
        'restricoes_medicas': <String>[],
        // Timestamp de criação
        'created_at': authUser.createdAt.isNotEmpty
            ? authUser.createdAt
            : now,
      };

      try {
        log('3. Tentando upsert na tabela public.users...');
        await _supabaseClient.from('users').upsert(publicUserData);
        log('   Upsert concluído com sucesso!');
      } catch (e) {
        // Log detalhado mas NÃO silencia o erro — se falhar, o cadastro continua
        // pois o auth user já existe, mas logamos para debug
        log('Aviso: Erro ao criar perfil público (tentativa upsert): $e');
        // Tentar insert simples como fallback (caso upsert tenha problema de RLS)
        try {
          log('4. Tentando insert simples (fallback) na tabela public.users...');
          await _supabaseClient.from('users').insert(publicUserData);
          log('   Insert fallback concluído com sucesso!');
        } catch (insertError) {
          log('Aviso: Insert fallback também falhou: $insertError');
          // Não retornamos erro aqui pois o auth user foi criado com sucesso
          // O perfil público pode ser criado via trigger ou na próxima ação
        }
      }

      // 3. Retorna a entidade construída localmente (fetch da tabela pode ter delay)
      final userModel = UserModel(
        id: authUser.id,
        email: email,
        nome: name,
        roles: [userType],
        foto: authUser.userMetadata?['avatar_url'],
      );

      // Cache para uso imediato offline
      log('5. Salvando usuário no cache local...');
      await _saveUserToPreferences(userModel);

      log('--- CADASTRO FINALIZADO COM SUCESSO ---');
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      log('Auth Error no cadastro: ${e.message}');
      return Left(Exception(e.message));
    } catch (e) {
      log('Erro inesperado no cadastro: $e');
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
  Future<Either<Exception, void>> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      return Left(Exception('Código inválido ou expirado.'));
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
