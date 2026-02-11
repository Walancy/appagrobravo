import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(mode: HeaderMode.back, title: 'Sobre nós'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            SvgPicture.asset('assets/images/logo_colorida.svg', height: 100),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                'Conexões que transformam o agro.',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildAboutContent(),
            const SizedBox(height: AppSpacing.xxl),
            _buildValues(),
            const SizedBox(height: AppSpacing.xxl),
            _buildVersionInfo(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'A AgroBravo Enterprises é uma plataforma de conexões estratégicas no agronegócio global. Com mais de 12 anos de história e presença em 5 continentes, conectamos o agronegócio entre Brasil, EUA, Ásia, América Latina e Europa.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nossa visão é construir pontes estratégicas para impulsionar o agronegócio além das fronteiras, proporcionando acesso exclusivo às tecnologias mais avançadas e networking de alto nível.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValues() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        children: [
          _buildValueItem(
            Icons.public,
            'Conexão Global',
            'Presença estratégica na Ásia, Europa, EUA e América Latina.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildValueItem(
            Icons.lightbulb_outline,
            'Expertise Técnica',
            'Conhecimento tático e inteligência de mercado aplicada ao campo.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildValueItem(
            Icons.groups_outlined,
            'Networking de Alto Nível',
            'Ecossistema completo de facilitação de negócios internacionais.',
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'AgroBravo Mobile App',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Versão 1.0.0 (Build 2026)',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '© 2026 AgroBravo. Todos os direitos reservados.',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
