import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/cubits/theme_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/components/settings_shimmer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
    context.read<DocumentsCubit>().loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(mode: HeaderMode.back, title: 'Configurações'),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (profile, _, isMe, __) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildUserCard(context, profile),
                  const SizedBox(height: 8),

                  _buildSectionLabel(context, 'CONTA'),
                  _buildSection(context, [
                    BlocBuilder<DocumentsCubit, DocumentsState>(
                      builder: (context, docState) => _buildTile(
                        context,
                        icon: Icons.description_outlined,
                        iconColor: Colors.blue.shade400,
                        title: 'Meus documentos',
                        onTap: () => context.push('/documents'),
                        badgeText: docState.hasPendingAction ? 'Pendente' : null,
                      ),
                    ),
                    _buildTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      iconColor: AppColors.primary,
                      title: 'Dados da conta',
                      onTap: () => context.push('/account-data'),
                    ),
                  ]),

                  const SizedBox(height: 8),
                  _buildSectionLabel(context, 'PREFERÊNCIAS'),
                  _buildSection(context, [
                    _buildTile(
                      context,
                      icon: Icons.medical_services_outlined,
                      iconColor: Colors.red.shade400,
                      title: 'Condições médicas',
                      onTap: () => context.push('/medical-restrictions'),
                    ),
                    _buildTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      iconColor: Colors.purple.shade400,
                      title: 'Notificações',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) => _buildThemeTile(context, mode),
                    ),
                  ]),

                  const SizedBox(height: 8),
                  _buildSectionLabel(context, 'SUPORTE'),
                  _buildSection(context, [
                    _buildTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      iconColor: Colors.grey.shade500,
                      title: 'Política de privacidade',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    _buildTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.grey.shade500,
                      title: 'Sobre nós',
                      onTap: () => context.push('/about-us'),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'AgroBravo Viajante',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              );
            },
            orElse: () => const SettingsShimmer(),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic profile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 68,
              height: 68,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.backgroundLight,
              child: profile.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, size: 36, color: Colors.grey),
                    )
                  : const Icon(Icons.person, size: 36, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((profile.missionName ?? '').isNotEmpty ||
                    (profile.groupName ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [profile.missionName, profile.groupName]
                          .where((s) => s != null && (s as String).isNotEmpty)
                          .join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if ((profile.email ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      profile.email!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 5),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: List.generate(tiles.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Padding(
              padding: const EdgeInsets.only(left: 68),
              child: Divider(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? const Radius.circular(16) : Radius.zero,
              bottom: i == (tiles.length * 2 - 2) ? const Radius.circular(16) : Radius.zero,
            ),
            child: tiles[i ~/ 2],
          );
        }),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    String? badgeText,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
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
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    return ListTile(
      onTap: () => context.read<ThemeCubit>().toggleTheme(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isDark ? Colors.indigo : Colors.amber.shade600).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          size: 20,
          color: isDark ? Colors.indigo : Colors.amber.shade700,
        ),
      ),
      title: Text(
        'Modo escuro',
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          context.read<ThemeCubit>().setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Sair da conta'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.45), width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) context.go('/');
    }
  }
}
