import 'package:flutter/material.dart';
import 'package:agrobravo/core/components/app_header.dart';

class GroupMediaPage extends StatelessWidget {
  final List<String> mediaUrls;

  const GroupMediaPage({super.key, required this.mediaUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: HeaderSpacer()),
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
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
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey),
                      ),
                    );
                  }, childCount: mediaUrls.length),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(
              mode: HeaderMode.back,
              title: 'Mídia e arquivos',
              subtitle: 'Visualize as mídias do grupo',
            ),
          ),
        ],
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
