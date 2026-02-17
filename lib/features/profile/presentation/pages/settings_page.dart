import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/cubits/theme_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProfileCubit>()..loadProfile()),
        BlocProvider(
          create: (context) => getIt<DocumentsCubit>()..loadDocuments(),
        ),
      ],
      child: Scaffold(
        appBar: const AppHeader(mode: HeaderMode.back, title: 'Configurações'),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (profile, _, isMe, __) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildUserHeader(context, profile),
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    BlocBuilder<DocumentsCubit, DocumentsState>(
                      builder: (context, state) {
                        return _buildOption(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Meus documentos',
                          onTap: () => context.push('/documents'),
                          hasBadge: state.hasPendingAction,
                        );
                      },
                    ),
                    _buildOption(
                      context,
                      icon: Icons.person_outline,
                      title: 'Dados da conta',
                      onTap: () => context.push('/account-data'),
                    ),
                    _buildOption(
                      context,
                      icon: Icons.restaurant_menu_outlined,
                      title: 'Preferências alimentares',
                      onTap: () => context.push('/food-preferences'),
                    ),
                    _buildOption(
                      context,
                      icon: Icons.medical_services_outlined,
                      title: 'Restrições médicas',
                      onTap: () => context.push('/medical-restrictions'),
                    ),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) {
                        return _buildOption(
                          context,
                          icon: mode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          title: 'Modo Escuro',
                          trailing: Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (value) {
                              context.read<ThemeCubit>().setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                            activeColor: AppColors.primary,
                          ),
                          onTap: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        );
                      },
                    ),
                    _buildOption(
                      context,
                      icon: Icons.notifications_none_outlined,
                      title: 'Preferências de notificações',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                    _buildOption(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Política de privacidade',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    _buildOption(
                      context,
                      icon: Icons.info_outline,
                      title: 'Sobre nós',
                      onTap: () => context.push('/about-us'),
                    ),
                    _buildOption(
                      context,
                      icon: Icons.logout,
                      title: 'Sair da conta',
                      isDestructive: true,
                      onTap: () async {
                        await getIt<AuthRepository>().signOut();
                        if (context.mounted) context.go('/');
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.backgroundLight,
                  ),
                  child: profile.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: profile.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.missionName ?? ''}${profile.missionName != null && profile.groupName != null ? ' - ' : ''}${profile.groupName ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
                Text(
                  profile.email ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
                Text(
                  profile.phone ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool hasBadge = false,
    Widget? trailing,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 4,
          ),
          leading: Icon(
            icon,
            color: isDestructive
                ? AppColors.error
                : Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          title: Row(
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDestructive
                      ? AppColors.error
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasBadge) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pendente',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing:
              trailing ??
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 64, right: AppSpacing.lg),
          child: Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
