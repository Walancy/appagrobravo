import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/auth/presentation/pages/login_page.dart';
import 'package:agrobravo/features/home/presentation/pages/home_page.dart';
import 'package:agrobravo/features/home/presentation/pages/create_post_page.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/itinerary_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/create-post',
      builder: (context, state) {
        final extra = state.extra;
        List<String> images = [];
        PostEntity? postToEdit;

        if (extra is List<String>) {
          images = extra;
        } else if (extra is Map<String, dynamic>) {
          images = (extra['initialImages'] as List?)?.cast<String>() ?? [];
          postToEdit = extra['postToEdit'] as PostEntity?;
        }

        return CreatePostPage(initialImages: images, postToEdit: postToEdit);
      },
    ),

    GoRoute(
      path: '/itinerary/:groupId',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return ItineraryPage(groupId: groupId);
      },
    ),
  ],
);
