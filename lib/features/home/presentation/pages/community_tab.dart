import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/profile/presentation/pages/social_profile_page.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:agrobravo/features/profile/presentation/widgets/incomplete_profile_banner.dart';
import 'package:agrobravo/features/documents/presentation/widgets/pending_documents_banner.dart';

class CommunityTab extends StatefulWidget {
  final Widget feedWidget;

  const CommunityTab({super.key, required this.feedWidget});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = getIt<FeedRepository>().getCurrentUserId() ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const HeaderSpacer(),
        const SizedBox(height: 16),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final isComplete = profileState.maybeMap(
              loaded: (s) => s.profile.isComplete,
              orElse: () => true,
            );
            if (isComplete) return const SizedBox.shrink();
            return const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: IncompleteProfileBanner(),
              ),
            );
          },
        ),
        BlocBuilder<DocumentsCubit, DocumentsState>(
          builder: (context, documentsState) {
            if (!documentsState.hasPendingAction) return const SizedBox.shrink();
            return const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: PendingDocumentsBanner(),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: isDark ? 0.1 : 0.07,
                ),
                width: 0.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Feed'),
              Tab(text: 'Meu Perfil'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              widget.feedWidget,
              SocialProfilePage(userId: _currentUserId, hideAppBar: true),
            ],
          ),
        ),
      ],
    );
  }
}
