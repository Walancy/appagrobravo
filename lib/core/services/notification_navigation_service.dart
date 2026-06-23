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
