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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

      if (userProfile['primeiro_acesso_viajante'] == true) {
        await _supabaseClient
            .from('users')
            .update({'primeiro_acesso_viajante': false})
            .eq('id', response.user!.id);
        
        userProfile['primeiro_acesso_viajante'] = false;
      }

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
    // Clear all cached data on sign out except remembered email and theme preferences
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key != 'remembered_email' && key != 'theme_mode') {
        await prefs.remove(key);
      }
    }
  }

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return none();

    try {
      // maybeSingle() retorna null em vez de lançar exceção se não encontrar
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile != null) {
        final userModel = UserModel.fromJson(userProfile);
        await _saveUserToPreferences(userModel);
        return some(userModel.toEntity());
      }

      // Perfil ainda não existe em public.users (login social recém-criado).
      // Constrói entidade mínima com dados do auth.users para não deslogar.
      log('public.users sem registro para ${user.id}. Usando dados do auth.users.');
      final fallbackName = user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          user.email?.split('@').first ??
          'Usuário';

      final fallbackModel = UserModel(
        id: user.id,
        email: user.email ?? '',
        nome: fallbackName,
        foto: user.userMetadata?['avatar_url'] as String?,
        roles: ['USER_APP'],
      );
      return some(fallbackModel.toEntity());
    } catch (e) {
      log('Erro ao recuperar usuário atual: $e. Tentando cache offline.');
      final cachedUser = await _getUserFromPreferences();
      if (cachedUser != null && cachedUser.id == user.id) {
        return some(cachedUser.toEntity());
      }
      // Sem cache e sem conexão — constrói mínimo para não deslogar
      final fallbackName = user.userMetadata?['full_name'] as String? ??
          user.email?.split('@').first ??
          'Usuário';
      final fallbackModel = UserModel(
        id: user.id,
        email: user.email ?? '',
        nome: fallbackName,
        foto: user.userMetadata?['avatar_url'] as String?,
        roles: ['USER_APP'],
      );
      return some(fallbackModel.toEntity());
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

  /// Faz upsert em public.users após autenticação social.
  /// - Primeira vez (INSERT): salva todos os campos inclusive nome.
  /// - Relogin (UPDATE): atualiza apenas email e foto — NÃO sobrescreve nome
  ///   para não substituir um nome real por um fallback de email.
  Future<void> _upsertPublicUser({
    required String id,
    required String nome,
    String? email,
    String? foto,
  }) async {
    try {
      // Verifica se já existe registro
      final existing = await _supabaseClient
          .from('users')
          .select('nome, primeiro_acesso_viajante')
          .eq('id', id)
          .maybeSingle();

      if (existing == null) {
        // Primeiro acesso — INSERT com todos os campos
        final now = DateTime.now().toUtc().toIso8601String();
        await _supabaseClient.from('users').insert({
          'id': id,
          'nome': nome.isNotEmpty ? nome : (email ?? 'Usuário'),
          'email': email,
          'foto': foto,
          'tipouser': ['USER_APP'],
          'primeiro_acesso_viajante': false,
          'created_at': now,
        });
        log('public.users INSERT OK para $id (nome: $nome)');
        // INC-016: new self-registered user — flag for onboarding
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('show_first_access_prompt', true);
      } else {
        // Relogin — atualiza apenas campos não-críticos, preserva nome existente
        final updateData = <String, dynamic>{};
        if (email != null) updateData['email'] = email;
        if (foto != null) updateData['foto'] = foto;

        // INC-016: admin-invited user has primeiro_acesso_viajante = true — detect and clear
        final isFirstAccess = existing['primeiro_acesso_viajante'] == true;
        if (isFirstAccess) {
          updateData['primeiro_acesso_viajante'] = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('show_first_access_prompt', true);
        }

        if (updateData.isNotEmpty) {
          await _supabaseClient
              .from('users')
              .update(updateData)
              .eq('id', id);
        }
        log('public.users UPDATE OK para $id (preservou nome: ${existing['nome']})');
      }
    } catch (e) {
      log('Aviso: falha no upsert de public.users: $e');
    }
  }

  /// Salva o FCM token atual em public.users.
  /// Chamado após login social para garantir que o token seja persistido
  /// mesmo que setupFCM() tenha rodado antes do usuário logar.
  Future<void> _persistFcmTokenIfAvailable() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      final messaging = FirebaseMessaging.instance;

      // iOS: tenta obter token se APNS já estiver disponível
      String? token;
      try {
        token = await messaging.getToken();
      } catch (_) {
        // APNS ainda não disponível — o onTokenRefresh cuidará depois
        return;
      }

      if (token != null) {
        await _supabaseClient
            .from('users')
            .update({'fcm_token': token})
            .eq('id', userId);
        log('FCM token salvo após login: $token');
      }
    } catch (e) {
      log('Erro ao persistir FCM token após login: $e');
    }
  }

  @override
  Future<Either<Exception, void>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _supabaseClient.auth.signInWithOAuth(OAuthProvider.google);
        return const Right(null);
      }

      final googleSignIn = GoogleSignIn(
        scopes: ['profile', 'email'],
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? '680098249535-9no4o6m6q0ifs8vnbvii7r9ibtdivpll.apps.googleusercontent.com'
            : null,
        serverClientId:
            '680098249535-fnr8odsclptv0hmpdlr3v1ipg0dkf32c.apps.googleusercontent.com',
      );

      await googleSignIn.signOut().catchError((_) => null);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return Left(Exception('Login com Google cancelado pelo usuário.'));
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) throw Exception('No Access Token found.');
      if (idToken == null) throw Exception('No ID Token found.');

      final authResponse = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final authUser = authResponse.user;
      if (authUser != null) {
        // Google sempre retorna nome e foto — salva/atualiza public.users
        final nome = googleUser.displayName ??
            authUser.userMetadata?['full_name'] as String? ??
            googleUser.email.split('@').first;
        final foto = googleUser.photoUrl ??
            authUser.userMetadata?['avatar_url'] as String?;

        await _upsertPublicUser(
          id: authUser.id,
          nome: nome,
          email: googleUser.email,
          foto: foto,
        );

        // Salva FCM token imediatamente após login (caso setupFCM() tenha
        // rodado antes do login e userId fosse null naquele momento)
        await _persistFcmTokenIfAvailable();
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      log('Erro ao fazer login com Google: $e');
      return Left(Exception('Erro ao fazer login com Google.'));
    }
  }

  @override
  Future<Either<Exception, void>> signInWithApple() async {
    try {
      if (kIsWeb) {
        await _supabaseClient.auth.signInWithOAuth(
          OAuthProvider.apple,
          authScreenLaunchMode: LaunchMode.platformDefault,
        );
        return const Right(null);
      }

      final rawNonce = _supabaseClient.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return Left(Exception('Não foi possível obter o token da Apple.'));
      }

      final authResponse = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final authUser = authResponse.user;
      if (authUser != null) {
        // CRÍTICO: givenName e familyName da Apple chegam APENAS no primeiro login.
        // Nos logins seguintes são null — por isso salvamos agora.
        final firstName = credential.givenName;
        final lastName = credential.familyName;

        // Tenta construir o nome; caso seja relogin (null), usa metadata salvo anteriormente
        String nome;
        if (firstName != null || lastName != null) {
          nome = [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
        } else {
          // Relogin: tenta pegar nome do metadata do auth.users (pode ter sido salvo antes)
          nome = authUser.userMetadata?['full_name'] as String? ??
              authUser.userMetadata?['name'] as String? ??
              credential.email?.split('@').first ??
              authUser.email?.split('@').first ??
              'Usuário Apple';
        }

        final email = credential.email ?? authUser.email;

        await _upsertPublicUser(
          id: authUser.id,
          nome: nome,
          email: email,
          foto: null, // Apple não fornece foto
        );

        // Salva FCM token imediatamente após login (caso setupFCM() tenha
        // rodado antes do login e userId fosse null naquele momento)
        await _persistFcmTokenIfAvailable();
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(Exception(e.message));
    } catch (e) {
      log('Erro ao fazer login com Apple: $e');
      return Left(Exception('Erro ao fazer login com Apple.'));
    }
  }

  @override
  Stream<AuthChangeEvent> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange.map((data) => data.event);
}
