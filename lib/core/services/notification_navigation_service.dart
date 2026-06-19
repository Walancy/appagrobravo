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

    final route = _normalizeRoute(targetRoute);
    if (route == null) return;

    if (!_routerReady) {
      _pendingRoute = route;
      return;
    }

    _navigateTo(route);
  }

  static String? _normalizeRoute(String? route) {
    final trimmed = route?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.path.isEmpty || !uri.path.startsWith('/')) {
      return '/notifications';
    }

    return uri.toString();
  }

  static void _navigateTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        appRouter.go(route);
        log('Navigated (go) to: $route', name: 'push');
      } catch (e) {
        log('Error navigating to $route: $e', name: 'push');
        try {
          appRouter.go('/notifications');
        } catch (_) {}
      }
    });
  }
}
