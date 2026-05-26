import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:agrobravo/core/services/onboarding_service.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  // Steps: 0=welcome, 1-5=questions, 6=guide
  static const int _totalQuestions = 5;
  int _currentStep = 0;

  // Answers
  bool _docsAcknowledged = false;
  final TextEditingController _familiaresCtrl = TextEditingController();
  final TextEditingController _particularidadesCtrl = TextEditingController();
  bool? _autorizaImagem;
  bool? _concordaDeclaracao;

  bool _isSubmitting = false;
  bool _submitError = false;

  @override
  void dispose() {
    _pageController.dispose();
    _familiaresCtrl.dispose();
    _particularidadesCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goToStep(_currentStep + 1);
  void _prev() => _goToStep(_currentStep - 1);

  Future<void> _submit() async {
    if (!(_concordaDeclaracao ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _submitError = false;
    });
    try {
      await OnboardingService.instance.completeOnboarding(
        familiaresViajantes: _familiaresCtrl.text.trim(),
        particularidades: _particularidadesCtrl.text.trim(),
        autorizaImagem: _autorizaImagem,
      );
      // Move to guide step without unblocking navigation yet
      _goToStep(6);
    } catch (_) {
      setState(() {
        _isSubmitting = false;
        _submitError = true;
      });
    }
  }

  Future<void> _finish() async {
    // Always await dismiss so the RPC completes before the itinerary reloads
    await OnboardingService.instance.dismiss();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final group = OnboardingService.instance.group;

    return PopScope(
      // Allow back only within questionnaire steps; never on welcome or guide
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 1 && _currentStep < 6) {
          _prev();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              if (_currentStep >= 1 && _currentStep <= 5)
                _ProgressBar(
                  current: _currentStep,
                  total: _totalQuestions,
                  onBack: _currentStep > 1 ? _prev : null,
                ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(group: group, onStart: _next),
                    _DocsStep(
                      acknowledged: _docsAcknowledged,
                      onChanged: (v) => setState(() => _docsAcknowledged = v),
                      onNext: _docsAcknowledged ? _next : null,
                    ),
                    _FamiliaresStep(
                      controller: _familiaresCtrl,
                      onNext: _next, // optional
                    ),
                    _ParticularidadesStep(
                      controller: _particularidadesCtrl,
                      onNext: _next, // optional
                    ),
                    _ImagemStep(
                      value: _autorizaImagem,
                      onChanged: (v) => setState(() => _autorizaImagem = v),
                      onNext: _autorizaImagem != null ? _next : null,
                    ),
                    _DeclaracaoStep(
                      value: _concordaDeclaracao,
                      onChanged: (v) => setState(() => _concordaDeclaracao = v),
                      onSubmit: _concordaDeclaracao == true && !_isSubmitting
                          ? _submit
                          : null,
                      isSubmitting: _isSubmitting,
                      hasError: _submitError,
                    ),
                    _GuideStep(onFinish: _finish),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Progress bar
// ────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onBack;

  const _ProgressBar({
    required this.current,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / total,
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$current/$total',
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 0: Welcome
// ────────────────────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  final ItineraryGroupEntity? group;
  final VoidCallback onStart;

  const _WelcomeStep({required this.group, required this.onStart});

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final missionName = group?.missionName ?? 'Nova Missão';
    final groupName = group?.name ?? '';
    final startDate = group?.startDate;
    final endDate = group?.endDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Icon / Illustration
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Bem-vindo à missão!',
            style: AppTextStyles.h2.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            missionName,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          if (groupName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              groupName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_fmtDate(startDate)}  →  ${_fmtDate(endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Você foi adicionado a esta missão. Antes de confirmar sua participação, '
              'leia as informações a seguir com atenção. Este processo leva apenas alguns minutos.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.75),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Iniciar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared question scaffold
// ────────────────────────────────────────────────────────────────────────────

class _QuestionScaffold extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final Widget content;
  final Widget? action;

  const _QuestionScaffold({
    required this.number,
    required this.title,
    required this.description,
    required this.content,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number →',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          content,
          if (action != null) ...[
            const SizedBox(height: 32),
            action!,
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Reusable option button (A/B style)
// ────────────────────────────────────────────────────────────────────────────

class _OptionButton extends StatelessWidget {
  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.25),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// OK / Next button
// ────────────────────────────────────────────────────────────────────────────

class _OkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const _OkButton({
    this.onPressed,
    this.label = 'OK',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed != null ? AppColors.primary : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (label == 'OK') ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_return_rounded, size: 16),
                  ],
                ],
              ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 1: Docs acknowledgment
// ────────────────────────────────────────────────────────────────────────────

class _DocsStep extends StatelessWidget {
  final bool acknowledged;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onNext;

  const _DocsStep({
    required this.acknowledged,
    required this.onChanged,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionScaffold(
      number: 1,
      title: 'Documentos de Viagem',
      description:
          'Confirme que você está ciente dos documentos necessários para esta missão.',
      content: Column(
        children: [
          _OptionButton(
            letter: 'A',
            label: 'Confirmo que li e estou ciente de todos os documentos necessários '
                '(passaporte, vistos, vacinas, etc.) e sei que é de minha '
                'responsabilidade providenciá-los dentro do prazo.',
            selected: acknowledged,
            onTap: () => onChanged(true),
          ),
        ],
      ),
      action: _OkButton(onPressed: onNext),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 2: Family travelers
// ────────────────────────────────────────────────────────────────────────────

class _FamiliaresStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _FamiliaresStep({
    required this.controller,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionScaffold(
      number: 2,
      title: 'Viajantes Familiares',
      description:
          'Se houver outros membros do seu grupo familiar participando desta missão, informe os nomes abaixo.',
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Ex: Maria Silva, João Silva... (deixe em branco se não houver)',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
        ),
        style: AppTextStyles.bodyMedium,
        textInputAction: TextInputAction.done,
      ),
      action: _OkButton(onPressed: onNext),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 3: Particularities
// ────────────────────────────────────────────────────────────────────────────

class _ParticularidadesStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _ParticularidadesStep({
    required this.controller,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionScaffold(
      number: 3,
      title: 'Particularidades',
      description:
          'Informe particularidades que a equipe organizadora deva saber para esta viagem.',
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText:
              'Ex: necessidades especiais, restrições alimentares, condições de saúde relevantes... (opcional)',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
        ),
        style: AppTextStyles.bodyMedium,
        textInputAction: TextInputAction.done,
      ),
      action: _OkButton(onPressed: onNext),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 4: Image rights
// ────────────────────────────────────────────────────────────────────────────

class _ImagemStep extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onNext;

  const _ImagemStep({
    required this.value,
    required this.onChanged,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionScaffold(
      number: 4,
      title: 'Autorização de Uso de Imagem',
      description:
          'Você autoriza o uso da sua imagem em fotos e vídeos produzidos durante a missão para fins institucionais?',
      content: Column(
        children: [
          _OptionButton(
            letter: 'A',
            label: 'Autorizo o uso da minha imagem para fins institucionais e de divulgação.',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            letter: 'B',
            label: 'Não autorizo o uso da minha imagem.',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
        ],
      ),
      action: _OkButton(onPressed: onNext),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 5: Final declaration
// ────────────────────────────────────────────────────────────────────────────

class _DeclaracaoStep extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final bool hasError;

  const _DeclaracaoStep({
    required this.value,
    required this.onChanged,
    this.onSubmit,
    required this.isSubmitting,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return _QuestionScaffold(
      number: 5,
      title: 'Declaração de Participação',
      description:
          'Para concluir, confirme sua concordância com os termos desta missão.',
      content: Column(
        children: [
          _OptionButton(
            letter: 'A',
            label:
                'Concordo — declaro que li e estou de acordo com todas as informações '
                'e regras desta missão, comprometendo-me a seguir as orientações da equipe organizadora.',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            letter: 'B',
            label: 'Não concordo.',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
          if (value == false) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'É necessário concordar para confirmar sua participação nesta missão.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Erro ao enviar. Verifique sua conexão e tente novamente.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      action: _OkButton(
        onPressed: onSubmit,
        label: 'Enviar',
        isLoading: isSubmitting,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 6: Post-submit guide
// ────────────────────────────────────────────────────────────────────────────

class _GuideStep extends StatefulWidget {
  final Future<void> Function() onFinish;

  const _GuideStep({required this.onFinish});

  @override
  State<_GuideStep> createState() => _GuideStepState();
}

class _GuideStepState extends State<_GuideStep> {
  bool _isFinishing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tudo certo!',
            style: AppTextStyles.h2.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sua participação foi confirmada.\nPara garantir uma viagem tranquila, complete as etapas abaixo.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _GuideCard(
            icon: Icons.person_outline_rounded,
            title: 'Dados Pessoais',
            subtitle: 'Complete seu perfil com nome, foto e informações de contato.',
            onTap: () => context.push('/account-data'),
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.description_outlined,
            title: 'Documentos',
            subtitle: 'Envie passaporte, visto e demais documentos exigidos para a viagem.',
            onTap: () => context.push('/documents'),
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.medical_information_outlined,
            title: 'Condições Médicas',
            subtitle: 'Informe alergias, medicamentos ou restrições de saúde importantes.',
            onTap: () => context.push('/medical-restrictions'),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isFinishing
                  ? null
                  : () async {
                      setState(() => _isFinishing = true);
                      await widget.onFinish();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isFinishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Ir para o app',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isFinishing
                ? null
                : () async {
                    setState(() => _isFinishing = true);
                    await widget.onFinish();
                  },
            child: Text(
              'Pular por agora',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
