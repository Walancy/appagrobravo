import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _documentAlerts = true;
  bool _missionUpdates = true;
  bool _connections = true;
  bool _isLoading = true;

  late ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProfileCubit>();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _cubit.getNotificationPreferences();
    if (mounted) {
      setState(() {
        _pushNotifications = prefs['pushNotifications'] ?? true;
        _emailNotifications = prefs['emailNotifications'] ?? true;
        _documentAlerts = prefs['documentAlerts'] ?? true;
        _missionUpdates = prefs['missionUpdates'] ?? true;
        _connections = prefs['connections'] ?? true;
        _isLoading = false;
      });
    }
  }

  void _savePrefs() {
    _cubit.updateNotificationPreferences({
      'pushNotifications': _pushNotifications,
      'emailNotifications': _emailNotifications,
      'documentAlerts': _documentAlerts,
      'missionUpdates': _missionUpdates,
      'connections': _connections,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppHeader(mode: HeaderMode.back, title: 'Notificações'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildHeader('Geral'),
                _buildSwitchTile(
                  'Notificações Push',
                  'Receba alertas em tempo real no seu celular',
                  _pushNotifications,
                  (v) {
                    setState(() => _pushNotifications = v);
                    _savePrefs();
                  },
                ),
                _buildSwitchTile(
                  'E-mails',
                  'Informativos e resumos da missão',
                  _emailNotifications,
                  (v) {
                    setState(() => _emailNotifications = v);
                    _savePrefs();
                  },
                ),
                const Divider(height: 1),
                _buildHeader('Tipos de Alerta'),
                _buildSwitchTile(
                  'Documentação',
                  'Alertas de pendências e aprovações de documentos',
                  _documentAlerts,
                  (v) {
                    setState(() => _documentAlerts = v);
                    _savePrefs();
                  },
                ),
                _buildSwitchTile(
                  'Atualizações da Missão',
                  'Mudanças no itinerário e avisos do guia',
                  _missionUpdates,
                  (v) {
                    setState(() => _missionUpdates = v);
                    _savePrefs();
                  },
                ),
                _buildSwitchTile(
                  'Novas Conexões',
                  'Solicitações de seguidores e novas mensagens',
                  _connections,
                  (v) {
                    setState(() => _connections = v);
                    _savePrefs();
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Suas preferências são salvas automaticamente.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
