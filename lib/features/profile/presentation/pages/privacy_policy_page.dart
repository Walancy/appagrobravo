import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(
        mode: HeaderMode.back,
        title: 'Política de Privacidade',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgroBravo Enterprises - Compromisso com sua Privacidade',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'A AgroBravo Enterprises, com sede em Ames, Iowa (EUA) e filial no Brasil, valoriza a confiança que você deposita em nós. Esta política descreve como tratamos suas informações pessoais.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildSection(
              '1. Coleta de Informações',
              'Coletamos informações quando você utiliza nossos serviços, preenche formulários ou participa de nossas missões. Isso inclui nome completo, e-mail, telefone, nome da empresa, informações de pagamento e detalhes necessários para logística de viagens (como passaporte e vistos).',
            ),

            _buildSection(
              '2. Uso dos Dados',
              'Utilizamos seus dados para:\n• Processar e gerenciar missões técnicas e viagens.\n• Enviar atualizações sobre o mercado e novas oportunidades de negócios.\n• Prestar suporte personalizado durante eventos.\n• Cumprir obrigações legais e regulatórias.',
            ),

            _buildSection(
              '3. Compartilhamento e Proteção',
              'Não compartilhamos informações com terceiros, exceto quando necessário para a prestação de serviços (parcerias logísticas, hotéis, órgãos governamentais) ou por obrigação legal. Adotamos práticas de criptografia e medidas de segurança para proteger sua privacidade.',
            ),

            _buildSection(
              '4. Aplicativo Móvel',
              'Nosso aplicativo pode coletar fotos e vídeos fornecidos por você para funcionalidade social e registro de missões. Estes dados não são compartilhados com fins comerciais externos e você pode solicitar a eliminação de sua conta e dados a qualquer momento.',
            ),

            _buildSection(
              '5. Seus Direitos',
              'Você tem o direito de acessar, retificar ou solicitar a exclusão de seus dados pessoais. Para exercer esses direitos, entre em contato conosco através dos canais de suporte no aplicativo.',
            ),

            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                'Última atualização: 22 de Abril de 2025',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
