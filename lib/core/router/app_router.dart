import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/router/go_router_refresh_stream.dart';
import 'package:agrobravo/core/services/onboarding_service.dart';
import 'package:agrobravo/features/auth/presentation/pages/login_page.dart';
import 'package:agrobravo/features/home/presentation/pages/home_page.dart';
import 'package:agrobravo/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:agrobravo/features/home/presentation/pages/create_post_page.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/itinerary_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/user_feed_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/connections_page.dart';
import 'package:agrobravo/features/notifications/presentation/pages/notifications_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/settings_page.dart';
import 'package:agrobravo/features/documents/presentation/pages/documents_page.dart';
import 'package:agrobravo/features/documents/presentation/pages/document_details_page.dart';
import 'package:agrobravo/features/documents/presentation/pages/document_history_page.dart';
import 'package:agrobravo/features/documents/domain/entities/document_enums.dart';
import 'package:agrobravo/features/documents/domain/entities/document_entity.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/profile/presentation/pages/food_preferences_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/medical_restrictions_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/notification_preferences_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/account_data_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/privacy_policy_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/about_us_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/social_profile_page.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_group_route_page.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_direct_route_page.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_data_route_page.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_guide_route_page.dart';

/// Rotas que NÃO precisam de autenticação (login, criar conta, esqueceu senha).
const _publicPaths = <String>{'/', '/reset-password'};

/// Combina múltiplos [Listenable]s em um único, para o GoRouter reagir
/// a qualquer um deles (OnboardingService + stream de sessão do Supabase).
class _MultiListenable extends ChangeNotifier {
  _MultiListenable(List<Listenable> listenables) {
    for (final l in listenables) {
      l.addListener(notifyListeners);
    }
  }
}

final _authRefresh = GoRouterRefreshStream(
  Supabase.instance.client.auth.onAuthStateChange,
);

final _routerRefresh = _MultiListenable([
  OnboardingService.instance,
  _authRefresh,
]);

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _routerRefresh,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;
    final currentPath = state.matchedLocation;

    final isPublicRoute = _publicPaths.contains(currentPath);

    dev.log(
      '[ONB] redirect path=$currentPath auth=$isAuthenticated '
      'needsOnboarding=${OnboardingService.instance.needsOnboarding}',
      name: 'router',
    );

    // Se NÃO está autenticado e está tentando acessar rota protegida → login
    if (!isAuthenticated && !isPublicRoute) {
      return '/';
    }

    // Onboarding gate: avaliado ANTES do redirect para /home para que o
    // onboarding sempre vença a corrida de navegação no login/app start.
    // Bloqueia todas as rotas até o onboarding ser concluído, EXCETO as
    // sub-páginas acessíveis a partir do guide step do onboarding.
    const onboardingAllowedPaths = <String>{
      '/onboarding',
      '/account-data',
      '/documents',
      '/document-details',
      '/document-history',
      '/medical-restrictions',
    };
    if (isAuthenticated &&
        OnboardingService.instance.needsOnboarding &&
        !onboardingAllowedPaths.contains(currentPath)) {
      return '/onboarding';
    }

    // Se JÁ está autenticado e está na tela de login → redireciona para home
    if (isAuthenticated && currentPath == '/') {
      return '/home';
    }

    // Nenhum redirecionamento necessário
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return NoTransitionPage(
          child: LoginPage(
            initialAuthMode: AuthMode.otpVerification,
            initialEmail: email,
          ),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '');
        final groupId = state.uri.queryParameters['groupId'];
        return NoTransitionPage(
          child: HomePage(initialTab: tab, initialGroupId: groupId),
        );
      },
    ),
    GoRoute(
      path: '/create-post',
      pageBuilder: (context, state) {
        final extra = state.extra;
        List<dynamic> images = [];
        PostEntity? postToEdit;

        if (extra is List) {
          images = extra;
        } else if (extra is Map<String, dynamic>) {
          images = (extra['initialImages'] as List?) ?? [];
          postToEdit = extra['postToEdit'] as PostEntity?;
        }

        return NoTransitionPage(
          child: CreatePostPage(initialImages: images, postToEdit: postToEdit),
        );
      },
    ),
    GoRoute(
      path: '/itinerary/:groupId',
      pageBuilder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return NoTransitionPage(child: ItineraryPage(groupId: groupId));
      },
    ),
    GoRoute(
      path: '/user-feed/:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final postId = state.uri.queryParameters['postId'];
        return NoTransitionPage(
          child: UserFeedPage(userId: userId, initialPostId: postId),
        );
      },
    ),
    GoRoute(
      path: '/connections/:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final initialIndex =
            int.tryParse(state.uri.queryParameters['initialIndex'] ?? '0') ?? 0;
        return NoTransitionPage(
          child: ConnectionsPage(userId: userId, initialIndex: initialIndex),
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: NotificationsPage()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SettingsPage()),
    ),
    GoRoute(
      path: '/documents',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DocumentsPage()),
    ),
    GoRoute(
      path: '/food-preferences',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: FoodPreferencesPage()),
    ),
    GoRoute(
      path: '/medical-restrictions',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MedicalRestrictionsPage()),
    ),
    GoRoute(
      path: '/notification-preferences',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: NotificationPreferencesPage()),
    ),
    GoRoute(
      path: '/document-details',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const NoTransitionPage(child: DocumentsPage());
        }
        return NoTransitionPage(
          child: DocumentDetailsPage(
            type: extra['type'] as DocumentType,
            currentDocument: extra['document'] as DocumentEntity?,
            cubit: extra['cubit'] as DocumentsCubit?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/document-history',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const NoTransitionPage(child: DocumentsPage());
        }
        return NoTransitionPage(
          child: DocumentHistoryPage(
            type: extra['type'] as DocumentType,
            cubit: extra['cubit'] as DocumentsCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: '/account-data',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AccountDataPage()),
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PrivacyPolicyPage()),
    ),
    GoRoute(
      path: '/profile/:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId'];
        return NoTransitionPage(child: SocialProfilePage(userId: userId));
      },
    ),
    GoRoute(
      path: '/about-us',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AboutUsPage()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OnboardingPage()),
    ),
    GoRoute(
      path: '/chat-group/:groupId',
      pageBuilder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return NoTransitionPage(
          child: ChatGroupRoutePage(groupId: groupId),
        );
      },
    ),
    GoRoute(
      path: '/chat-direct/:guideId',
      pageBuilder: (context, state) {
        final guideId = state.pathParameters['guideId']!;
        return NoTransitionPage(
          child: ChatDirectRoutePage(guideId: guideId),
        );
      },
    ),
    GoRoute(
      path: '/travel-data/:groupId',
      pageBuilder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return NoTransitionPage(
          child: TravelDataRoutePage(groupId: groupId),
        );
      },
    ),
    GoRoute(
      path: '/travel-guide/:groupId',
      pageBuilder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return NoTransitionPage(
          child: TravelGuideRoutePage(groupId: groupId),
        );
      },
    ),
  ],
);
