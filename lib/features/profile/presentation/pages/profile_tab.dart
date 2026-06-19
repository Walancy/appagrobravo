import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_flags/country_flags.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/cubits/theme_cubit.dart';
import 'package:agrobravo/core/cubits/locale_cubit.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/settings_shimmer.dart';
import 'package:agrobravo/core/components/image_source_bottom_sheet.dart';
import 'package:agrobravo/core/components/image_cropper_modal.dart';

class ProfileTab extends StatefulWidget {
  final String? userId;
  const ProfileTab({super.key, this.userId});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isUploadingPhoto = false;

  // ── Pick, crop, and upload profile photo ─────────────────────────────
  Future<void> _pickAndCropProfilePhoto() async {
    // 1. Ask for source (camera or gallery)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSourceBottomSheet(
        title: context.l10n.profileChangePhoto,
      ),
    );
    if (source == null || !mounted) return;

    // 2. Pick image
    final picker = ImagePicker();
    final XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(source: source);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.homeCameraError),
          ),
        );
      }
      return;
    }
    if (pickedFile == null || !mounted) return;

    // 3. Open crop modal
    final croppedBytes = await ImageCropperModal.show(
      context,
      imageProvider: FileImage(File(pickedFile.path)),
    );
    if (croppedBytes == null || !mounted) return;

    // 4. Upload cropped image
    setState(() => _isUploadingPhoto = true);
    try {
      final tempFile = XFile.fromData(
        croppedBytes,
        name: 'profile_cropped.png',
        mimeType: 'image/png',
      );
      if (mounted) {
        await context.read<ProfileCubit>().updateProfilePhoto(tempFile);
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
            return state.maybeWhen(
              loaded: (profile, _, isMe, __) {
                return RefreshIndicator(
                  onRefresh: () async => context.read<ProfileCubit>().loadProfile(),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const HeaderSpacer(),
                      _buildUserCard(context, profile),
                      const SizedBox(height: 8),

                      _buildSectionLabel(context, context.l10n.settingsSectionAccount),
                      _buildSection(context, [
                        BlocBuilder<DocumentsCubit, DocumentsState>(
                          builder: (context, docState) => _buildTile(
                            context,
                            icon: Icons.description_outlined,
                            iconColor: Colors.blue.shade400,
                            title: context.l10n.settingsMyDocuments,
                            onTap: () => context.push('/documents'),
                            badgeText: docState.hasPendingAction ? context.l10n.commonPending : null,
                          ),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.primary,
                          title: context.l10n.settingsAccountData,
                          onTap: () => context.push('/account-data'),
                        ),
                      ]),

                      const SizedBox(height: 8),
                      _buildSectionLabel(context, context.l10n.settingsSectionPreferences),
                      _buildSection(context, [
                        _buildTile(
                          context,
                          icon: Icons.medical_services_outlined,
                          iconColor: Colors.red.shade400,
                          title: context.l10n.settingsMedicalConditions,
                          onTap: () => context.push('/medical-restrictions'),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.notifications_none_rounded,
                          iconColor: Colors.purple.shade400,
                          title: context.l10n.settingsNotifications,
                          onTap: () => context.push('/notification-preferences'),
                        ),
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, mode) => _buildThemeTile(context, mode),
                        ),
                        _buildLanguageTile(context),
                      ]),

                      const SizedBox(height: 8),
                      _buildSectionLabel(context, context.l10n.settingsSectionSupport),
                      _buildSection(context, [
                        _buildTile(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          iconColor: Colors.grey.shade500,
                          title: context.l10n.settingsPrivacyPolicy,
                          onTap: () => context.push('/privacy-policy'),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.grey.shade500,
                          title: context.l10n.settingsAboutUs,
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
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
              orElse: () => const Column(
                children: [
                  HeaderSpacer(),
                  Expanded(child: SettingsShimmer()),
                ],
              ),
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
          // Avatar with camera icon overlay
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickAndCropProfilePhoto,
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 68,
                    height: 68,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.backgroundLight,
                    child: _isUploadingPhoto
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : profile.avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: profile.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.person, size: 36, color: Colors.grey),
                              )
                            : const Icon(Icons.person, size: 36, color: Colors.grey),
                  ),
                ),
                // Camera icon badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: () {
        context.read<ThemeCubit>().setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
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
        isDark ? context.l10n.settingsDarkMode : context.l10n.settingsLightMode,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          context.read<ThemeCubit>().setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
        activeColor: Colors.white,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(context.l10n.settingsSignOut),
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

  Widget _buildLanguageTile(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        final cubit = context.read<LocaleCubit>();
        final displayName = cubit.currentLanguageName(context);
        return ListTile(
          onTap: () => _showLanguagePicker(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language_rounded, size: 20, color: Colors.teal),
          ),
          title: Text(
            context.l10n.settingsLanguage,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (ctx, locale) => Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      context.l10n.languagePickerTitle,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LanguageOption(
                    countryCode: 'BR',
                    label: context.l10n.languagePortuguese,
                    selected: locale?.languageCode == 'pt' || locale == null,
                    onTap: () {
                      cubit.setLocale(const Locale('pt'));
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  _LanguageOption(
                    countryCode: 'US',
                    label: context.l10n.languageEnglish,
                    selected: locale?.languageCode == 'en',
                    onTap: () {
                      cubit.setLocale(const Locale('en'));
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  _LanguageOption(
                    countryCode: 'ES',
                    label: context.l10n.languageSpanish,
                    selected: locale?.languageCode == 'es',
                    onTap: () {
                      cubit.setLocale(const Locale('es'));
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsSignOutDialogTitle),
        content: Text(context.l10n.settingsSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.commonSignOut),
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

class _LanguageOption extends StatelessWidget {
  final String countryCode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.countryCode,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CountryFlag.fromCountryCode(
        countryCode,
        theme: const ImageTheme(width: 38, height: 26, shape: RoundedRectangle(4)),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
    );
  }
}

