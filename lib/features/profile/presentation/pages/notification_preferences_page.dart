import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(mode: HeaderMode.back, title: 'Notificações'),
      body: ListView(
        children: [
          _buildHeader('Geral'),
          _buildSwitchTile(
            'Notificações Push',
            'Receba alertas em tempo real no seu celular',
            _pushNotifications,
            (v) => setState(() => _pushNotifications = v),
          ),
          _buildSwitchTile(
            'E-mails',
            'Informativos e resumos da missão',
            _emailNotifications,
            (v) => setState(() => _emailNotifications = v),
          ),
          const Divider(height: 1),
          _buildHeader('Tipos de Alerta'),
          _buildSwitchTile(
            'Documentação',
            'Alertas de pendências e aprovações de documentos',
            _documentAlerts,
            (v) => setState(() => _documentAlerts = v),
          ),
          _buildSwitchTile(
            'Atualizações da Missão',
            'Mudanças no itinerário e avisos do guia',
            _missionUpdates,
            (v) => setState(() => _missionUpdates = v),
          ),
          _buildSwitchTile(
            'Novas Conexões',
            'Solicitações de seguidores e novas mensagens',
            _connections,
            (v) => setState(() => _connections = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferências de notificação salvas!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  'Salvar Preferências',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          color: AppColors.textSecondary,
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
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
