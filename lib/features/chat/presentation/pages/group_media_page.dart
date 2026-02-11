import 'package:flutter/material.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

class GroupMediaPage extends StatelessWidget {
  final List<String> mediaUrls;

  const GroupMediaPage({super.key, required this.mediaUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: 'Mídia e arquivos',
        subtitle: 'Visualize as mídias do grupo',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2), // Match tight grid in image
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      FullScreenMediaPage(imageUrl: mediaUrls[index]),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Image.network(
              mediaUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenMediaPage extends StatelessWidget {
  final String imageUrl;

  const FullScreenMediaPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }
}
