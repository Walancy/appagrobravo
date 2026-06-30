import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gate singleton que controla se a tela de pré-permissão (primer)
/// de notificações deve ser exibida.
///
/// O GoRouter escuta este ChangeNotifier via refreshListenable e redireciona
/// para /notification-primer quando [needsPrimer] == true.
///
/// Regras:
/// - Exibe o primer se a permissão NÃO está [AuthorizationStatus.authorized]
///   nem [AuthorizationStatus.provisional].
/// - Após o primer ser resolvido (permissão concedida ou negada), marca
///   [needsPrimer] = false para a sessão atual.
/// - Na próxima abertura do app, verifica novamente o status. Se o usuário
///   negou, o primer reaparece (status permanece denied).
class NotificationPermissionService extends ChangeNotifier {
  static final NotificationPermissionService instance =
      NotificationPermissionService._();
  NotificationPermissionService._();

  bool _needsPrimer = false;
  bool _initialized = false;

  bool get needsPrimer => _needsPrimer;

  /// Inicializa o serviço verificando o status atual da permissão.
  /// Deve ser chamado após o login do usuário, antes do router navegar para home.
  Future<void> initialize() async {
    if (!_isFirebaseSupported) {
      _needsPrimer = false;
      return;
    }

    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final status = settings.authorizationStatus;

      dev.log(
        '[PERM] initialize: status=$status',
        name: 'notification_primer',
      );

      // Se já tem permissão concedida ou provisional → não precisa do primer
      final alreadyGranted =
          status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;

      _needsPrimer = !alreadyGranted;
      _initialized = true;
      notifyListeners();
    } catch (e) {
      dev.log('[PERM] initialize error: $e', name: 'notification_primer');
      _needsPrimer = false;
    }
  }

  /// Chamado pela NotificationPrimerPage após o usuário interagir
  /// (seja aceitando ou depois de negar no diálogo nativo).
  /// Fecha o gate para a sessão atual — na próxima abertura, [initialize]
  /// reavalia o status real do sistema.
  void dismissForSession() {
    dev.log('[PERM] dismissForSession', name: 'notification_primer');
    _needsPrimer = false;
    notifyListeners();
  }

  /// Reseta o serviço no logout para que na próxima sessão o gate
  /// seja reavaliado corretamente.
  void reset() {
    _needsPrimer = false;
    _initialized = false;
    // Não chama notifyListeners — o caller gerencia a navegação no logout.
  }

  /// Obtém o FCM token e salva no banco (Supabase).
  /// Útil após a permissão ser concedida no dialog nativo.
  Future<void> retrieveAndSaveToken() async {
    if (!_isFirebaseSupported) return;
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Android não precisa esperar APNS token
      if (!defaultTargetPlatform.name.contains('iOS') &&
          defaultTargetPlatform != TargetPlatform.iOS) {
        final token = await messaging.getToken();
        if (token != null) {
          await _saveFcmToken(token);
        }
        return;
      }

      // iOS: aguarda APNS token com retry exponencial
      for (int attempt = 1; attempt <= 10; attempt++) {
        try {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) {
            final token = await messaging.getToken();
            if (token != null) {
              await _saveFcmToken(token);
            }
            return;
          }
        } catch (_) {}
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    } catch (e) {
      dev.log('Erro ao obter e salvar FCM token: $e', name: 'notification_primer');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);
      dev.log('FCM token salvo com sucesso via primer', name: 'notification_primer');
    } catch (e) {
      dev.log('Erro ao salvar FCM token no Supabase via primer: $e', name: 'notification_primer');
    }
  }

  bool get _isFirebaseSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  // ignore: unused_field
  bool get _wasInitialized => _initialized;
}
