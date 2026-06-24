import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:agrobravo/core/router/app_router.dart';

/// Centralizes handling of FCM notification taps so the app navigates to the
/// correct screen based on the `target_route` metadata sent by the edge function.
///
/// Handles two scenarios:
/// 1. App in background → user taps notification → `onMessageOpenedApp`
/// 2. App terminated → notification opened the app → `getInitialMessage`
class NotificationNavigationService {
  NotificationNavigationService._();

  static bool _initialized = false;
  static bool _routerReady = false;
  static String? _pendingRoute;

  /// Register FCM tap handlers once Firebase is ready.
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    // App was in background and user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // App was terminated and notification opened it
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleMessage(message);
    });

    log('NotificationNavigationService initialized', name: 'push');
  }

  /// Call after MaterialApp.router has mounted so cold-start notification taps
  /// can safely navigate.
  static void markRouterReady() {
    _routerReady = true;
    final route = _pendingRoute;
    if (route == null) return;

    _pendingRoute = null;
    _navigateTo(route);
  }

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final targetRoute = data['target_route']?.toString();

    log(
      'Push notification tapped. data=$data targetRoute=$targetRoute',
      name: 'push',
    );

    // Usa target_route da edge function como fonte primária.
    // Caso seja genérico (/home) ou ausente, tenta resolver localmente
    // usando os campos auxiliares presentes no payload FCM.
    String? resolvedRoute = _normalizeRoute(targetRoute);
    if (resolvedRoute == null || resolvedRoute == '/home') {
      resolvedRoute = _resolveRouteFromData(data) ?? resolvedRoute;
    }

    if (resolvedRoute == null) return;

    if (!_routerReady) {
      _pendingRoute = resolvedRoute;
      return;
    }

    _navigateTo(resolvedRoute);
  }

  /// Fallback local: resolve a rota a partir dos campos auxiliares do FCM
  /// para cobrir cenários onde a edge function retornou /home genérico.
  static String? _resolveRouteFromData(Map<String, dynamic> data) {
    final assunto = data['assunto']?.toString().toLowerCase() ?? '';
    final tipo = data['tipo']?.toString().toLowerCase() ?? '';
    final kind = assunto.isNotEmpty ? assunto : tipo;

    final postId = data['post_id']?.toString();
    final grupoId = data['grupo_id']?.toString();
    final batepapoId = data['batepapo_id']?.toString();
    final docId = data['doc_id']?.toString();
    final solicitacaoUserId = data['solicitacao_user_id']?.toString();

    // Chat de grupo
    if (kind == 'chatgrupo' || kind == 'chat_grupo') {
      if (batepapoId != null && batepapoId.isNotEmpty) return '/chat-group/$batepapoId';
      if (grupoId != null && grupoId.isNotEmpty) return '/chat-group/$grupoId';
    }

    // Chat direto
    if (kind == 'chatdireto' || kind == 'chat_direto') {
      if (batepapoId != null && batepapoId.isNotEmpty) return '/chat-direct/$batepapoId';
    }

    // Documentos
    if (docId != null && docId.isNotEmpty) return '/documents';

    // Missão / itinerário
    if (grupoId != null && grupoId.isNotEmpty) return '/home?tab=0&groupId=$grupoId';

    // Solicitação de conexão — rota já resolvida com user_id pelo edge function,
    // mas por segurança mapeia também o campo solicitacao_user_id
    if (solicitacaoUserId != null && solicitacaoUserId.isNotEmpty) {
      // Sem o userId do destinatário disponível aqui; vai para conexões genéricas
      return null;
    }

    // Post (like/comment): sem acesso ao postOwnerId no cliente, não é possível
    // resolver sem network call. Mantém /home.
    if (postId != null && postId.isNotEmpty) return null;

    return null;
  }

  static String? _normalizeRoute(String? route) {
    final trimmed = route?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.path.isEmpty || !uri.path.startsWith('/')) {
      return '/home';
    }

    return uri.toString();
  }

  /// Maps deep-link routes to their parent home tab so the navigation stack
  /// has the navbar screen behind the detail screen.
  /// Returns (parentRoute, detailRoute) or null if no stacking is needed.
  static (String, String)? _resolveStack(String route) {
    final uri = Uri.tryParse(route);
    if (uri == null) return null;

    // /chat-group/:id → Home chat tab (1) + detail
    if (uri.path.startsWith('/chat-group/')) {
      return ('/home?tab=1', route);
    }

    // /chat-direct/:id → Home chat tab (1) + detail
    if (uri.path.startsWith('/chat-direct/')) {
      return ('/home?tab=1', route);
    }

    // /notifications → Home community tab (2) + notifications
    if (uri.path == '/notifications') {
      return ('/home', route);
    }

    // /profile/:userId → Home community tab (2) + social profile
    if (uri.path.startsWith('/profile/')) {
      return ('/home?tab=2', route);
    }

    // /travel-data/:groupId → Home itinerary tab (0) + travel data
    if (uri.path.startsWith('/travel-data/')) {
      return ('/home?tab=0', route);
    }

    // /travel-guide/:groupId → Home itinerary tab (0) + travel guide
    if (uri.path.startsWith('/travel-guide/')) {
      return ('/home?tab=0', route);
    }

    // /user-feed/:id → Home community tab (2) + user feed
    if (uri.path.startsWith('/user-feed/')) {
      return ('/home?tab=2', route);
    }

    // /connections/:id → Home community tab (2) + connections
    if (uri.path.startsWith('/connections/')) {
      return ('/home?tab=2', route);
    }

    // /documents → Home profile tab (3) + documents
    if (uri.path == '/documents') {
      return ('/home?tab=3', route);
    }

    return null;
  }

  static void _navigateTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Intercept /itinerary/:groupId → itinerary tab inside HomePage
        final itineraryMatch = RegExp(r'^/itinerary/(.+)$').firstMatch(route);
        if (itineraryMatch != null) {
          final resolvedRoute =
              '/home?tab=0&groupId=${itineraryMatch.group(1)}';
          appRouter.go(resolvedRoute);
          log('Navigated (go) to: $resolvedRoute', name: 'push');
          return;
        }

        // For detail screens: go to parent (with navbar) first, then push detail
        final stack = _resolveStack(route);
        if (stack != null) {
          appRouter.go(stack.$1);
          // Small delay to let the parent screen mount before pushing
          Future.delayed(const Duration(milliseconds: 150), () {
            appRouter.push(stack.$2);
            log('Navigated: go(${stack.$1}) + push(${stack.$2})', name: 'push');
          });
          return;
        }

        // Default: just go to the route directly
        appRouter.go(route);
        log('Navigated (go) to: $route', name: 'push');
      } catch (e) {
        log('Error navigating to $route: $e', name: 'push');
        try {
          appRouter.go('/home');
        } catch (_) {}
      }
    });
  }
}
