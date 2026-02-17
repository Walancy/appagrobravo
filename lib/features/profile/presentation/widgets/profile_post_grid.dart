import 'package:flutter/material.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePostGrid extends StatelessWidget {
  final List<PostEntity> posts;

  const ProfilePostGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final firstImage = post.images.isNotEmpty ? post.images.first : '';
        final isCarousel = post.images.length > 1;

        return GestureDetector(
          onTap: () {
            context.push('/user-feed/${post.userId}?postId=${post.id}');
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (firstImage.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: firstImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[200],
                  ),
                  errorWidget: (context, url, err) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              else
                Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200],
                ),
              if (isCarousel)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 20,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
