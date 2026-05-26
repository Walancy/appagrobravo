import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Rotas que NÃO precisam de autenticação (login, criar conta, esqueceu senha).
const _publicPaths = <String>{'/', '/reset-password'};

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: OnboardingService.instance,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;
    final currentPath = state.matchedLocation;

    final isPublicRoute = _publicPaths.contains(currentPath);

    // Se NÃO está autenticado e está tentando acessar rota protegida → login
    if (!isAuthenticated && !isPublicRoute) {
      return '/';
    }

    // Se JÁ está autenticado e está na tela de login → redireciona para home
    if (isAuthenticated && currentPath == '/') {
      return '/home';
    }

    // Onboarding gate: bloqueia todas as rotas até o onboarding ser concluído
    if (isAuthenticated &&
        OnboardingService.instance.needsOnboarding &&
        currentPath != '/onboarding') {
      return '/onboarding';
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
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: HomePage()),
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
  ],
);
