import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/auth/presentation/pages/login_page.dart';
import 'package:agrobravo/features/home/presentation/pages/home_page.dart';
import 'package:agrobravo/features/home/presentation/pages/create_post_page.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/itinerary_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/user_feed_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/connections_page.dart';
import 'package:agrobravo/features/notifications/presentation/pages/notifications_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/settings_page.dart';
import 'package:agrobravo/features/documents/presentation/pages/documents_page.dart';
import 'package:agrobravo/features/documents/presentation/pages/document_details_page.dart';
import 'package:agrobravo/features/documents/domain/entities/document_enums.dart';
import 'package:agrobravo/features/documents/domain/entities/document_entity.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/profile/presentation/pages/food_preferences_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/medical_restrictions_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/notification_preferences_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/account_data_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/privacy_policy_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/about_us_page.dart';
import 'package:agrobravo/features/profile/presentation/pages/profile_tab.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(initialAuthMode: AuthMode.resetPassword),
      ),
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
        final extra = state.extra as Map<String, dynamic>;
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
        return NoTransitionPage(child: ProfileTab(userId: userId));
      },
    ),
    GoRoute(
      path: '/about-us',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AboutUsPage()),
    ),
  ],
);
