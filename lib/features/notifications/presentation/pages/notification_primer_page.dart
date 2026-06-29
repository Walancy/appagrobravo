import 'dart:developer' as dev;
import 'dart:io';

import 'package:agrobravo/core/services/notification_permission_service.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPrimerPage extends StatefulWidget {
  const NotificationPrimerPage({super.key});

  @override
  State<NotificationPrimerPage> createState() => _NotificationPrimerPageState();
}

class _NotificationPrimerPageState extends State<NotificationPrimerPage>
    with SingleTickerProviderStateMixin {
  // Animação somente no botão (pulso sutil)
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  bool _isLoading = false;
  bool _isDenied = false;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _buttonScale = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final denied = settings.authorizationStatus == AuthorizationStatus.denied;
    if (mounted) setState(() => _isDenied = denied);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _onActivate() async {
    if (_isLoading) return;
    _buttonController.stop();

    if (_isDenied) {
      await _openAppSettings();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      dev.log(
        '[PERM] requestPermission result: ${settings.authorizationStatus}',
        name: 'notification_primer',
      );
    } catch (e) {
      dev.log('[PERM] requestPermission error: $e', name: 'notification_primer');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Fecha o gate e navega explicitamente para o home.
    // O GoRouter redireciona para /onboarding se necessário.
    NotificationPermissionService.instance.dismissForSession();
    context.go('/home');
  }

  Future<void> _openAppSettings() async {
    if (Platform.isIOS) {
      final uri = Uri.parse('app-settings:');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } else {
      final uri = Uri.parse('package:com.agrobravo.app');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
    if (!mounted) return;
    NotificationPermissionService.instance.dismissForSession();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF2D5A1B),
              AppColors.primaryDark,
              Color(0xFF1A3A0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.07),

                // ── Ícone estático ─────────────────────────────────────────
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 48,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: screenHeight * 0.045),

                // ── Título ─────────────────────────────────────────────────
                Text(
                  _isDenied
                      ? 'Ative as notificações\nnas Configurações'
                      : 'Fique por dentro\nde tudo!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Subtítulo ──────────────────────────────────────────────
                Text(
                  _isDenied
                      ? 'Você desativou as notificações. Para receber atualizações da sua viagem, ative-as nas Configurações do dispositivo.'
                      : 'As notificações são o nosso canal direto com você. Não queremos que você perca nenhuma informação importante.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // ── Cards de benefícios ────────────────────────────────────
                _BenefitCard(
                  icon: Icons.map_outlined,
                  title: 'Atualizações da viagem',
                  subtitle: 'Mudanças de roteiro, horários e locais em tempo real.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _BenefitCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Mensagens do guia e grupo',
                  subtitle: 'Comunicação direta sem perder nenhuma mensagem.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _BenefitCard(
                  icon: Icons.checklist_rounded,
                  title: 'Documentos e checklists',
                  subtitle: 'Avisos de novos arquivos e itens que precisam da sua atenção.',
                ),

                const Spacer(),

                // ── Botão com pulso sutil ──────────────────────────────────
                ScaleTransition(
                  scale: _isLoading ? const AlwaysStoppedAnimation(1.0) : _buttonScale,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onActivate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryDark,
                              ),
                            )
                          : Text(
                              _isDenied
                                  ? 'Abrir Configurações'
                                  : 'Ativar Notificações',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BenefitCard
// ---------------------------------------------------------------------------

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
