import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:agrobravo/core/router/app_router.dart';

void _log(String msg) {
  debugPrint('[NOTIF] $msg');
  dev.log(msg, name: 'push');
}

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
  // Pre-fetched cold-start message (captured in main() before runApp()).
  static RemoteMessage? _coldStartMessage;

  /// Store the cold-start notification captured in main() before runApp().
  static void setColdStartMessage(RemoteMessage message) {
    _coldStartMessage = message;
    _log('Cold-start message stored: ${message.data}');
  }

  /// Register FCM tap handlers once Firebase is ready.
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    // App was in background and user tapped notification.
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _log('onMessageOpenedApp fired: ${msg.data}');
      _handleMessage(msg);
    });

    _log('NotificationNavigationService initialized');
  }

  /// Call after MaterialApp.router has mounted so cold-start notification taps
  /// can safely navigate.
  static void markRouterReady() {
    _routerReady = true;
    _log('markRouterReady called. coldStartMessage=${_coldStartMessage?.data} pendingRoute=$_pendingRoute');

    // Primary: use message pre-fetched in main() before runApp().
    final coldMsg = _coldStartMessage;
    if (coldMsg != null) {
      _coldStartMessage = null;
      _log('Processing pre-fetched cold-start message');
      _handleMessage(coldMsg);
      return;
    }

    // Fallback: try getInitialMessage() in case it wasn't set via main().
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _log('Cold-start message (fallback getInitialMessage): ${message.data}');
        _handleMessage(message);
      } else {
        _log('getInitialMessage() returned null — no cold-start notification');
      }
    });

    final route = _pendingRoute;
    if (route == null) return;

    _pendingRoute = null;
    _navigateTo(route);
  }

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final targetRoute = data['target_route']?.toString();

    _log('_handleMessage: data=$data targetRoute=$targetRoute routerReady=$_routerReady');

    String? resolvedRoute = _normalizeRoute(targetRoute);
    _log('_handleMessage: normalizedRoute=$resolvedRoute');

    if (resolvedRoute == null || resolvedRoute == '/home') {
      resolvedRoute = _resolveRouteFromData(data) ?? resolvedRoute;
      _log('_handleMessage: resolvedFromData=$resolvedRoute');
    }

    if (resolvedRoute == null) {
      _log('_handleMessage: resolvedRoute is null — aborting navigation');
      return;
    }

    if (!_routerReady) {
      _log('_handleMessage: router not ready — storing pendingRoute=$resolvedRoute');
      _pendingRoute = resolvedRoute;
      return;
    }

    _log('_handleMessage: calling _navigateTo($resolvedRoute)');
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
    if (kind == 'chat_grupo' || kind == 'chatgrupo') {
      if (batepapoId != null && batepapoId.isNotEmpty) return '/chat-group/$batepapoId';
      if (grupoId != null && grupoId.isNotEmpty) return '/chat-group/$grupoId';
    }

    // Chat direto
    if (kind == 'chat_direto' || kind == 'chatdireto') {
      if (batepapoId != null && batepapoId.isNotEmpty) return '/chat-direct/$batepapoId';
    }

    // Guia de viagem
    if (kind == 'guia_viagem') {
      if (grupoId != null && grupoId.isNotEmpty) return '/travel-guide/$grupoId';
    }

    // Material (formulários, checklists, arquivos → dados da viagem)
    if (kind == 'material') {
      if (grupoId != null && grupoId.isNotEmpty) return '/travel-data/$grupoId';
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
    _log('_navigateTo: scheduling navigation to $route');
    WidgetsBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Intercept /itinerary/:groupId → itinerary tab inside HomePage
        final itineraryMatch = RegExp(r'^/itinerary/(.+)$').firstMatch(route);
        if (itineraryMatch != null) {
          final resolvedRoute = '/home?tab=0&groupId=${itineraryMatch.group(1)}';
          appRouter.go(resolvedRoute);
          _log('Navigated (go) to: $resolvedRoute');
          return;
        }

        final stack = _resolveStack(route);
        _log('_navigateTo: resolveStack($route) = $stack');
        if (stack != null) {
          appRouter.go(stack.$1);
          _log('_navigateTo: called go(${stack.$1}), scheduling push(${stack.$2})');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              appRouter.push(stack.$2);
              _log('Navigated: go(${stack.$1}) + push(${stack.$2})');
            } catch (e) {
              _log('Error pushing ${stack.$2}: $e');
            }
          });
          return;
        }

        appRouter.go(route);
        _log('Navigated (go) to: $route');
      } catch (e) {
        _log('Error navigating to $route: $e');
        try {
          appRouter.go('/home');
        } catch (_) {}
      }
    });
  }
}
