import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/core/services/onboarding_service.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/onboarding/data/models/grupo_formulario_model.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  late final List<GrupoFormularioModel> _formularios;

  // Flat list of all (formularioIndex, perguntaIndex) pairs across all forms
  late final List<_PerguntaRef> _perguntaRefs;

  // Answers: formularioId -> { perguntaId -> dynamic }
  final Map<String, Map<String, dynamic>> _answers = {};

  // Current step: 0=welcome, 1..N=questions, N+1=guide
  int _currentStep = 0;

  bool _isSubmitting = false;
  bool _submitError = false;

  @override
  void initState() {
    super.initState();
    _formularios = OnboardingService.instance.formularios;
    _perguntaRefs = _buildPerguntaRefs();

    // Initialize answer maps
    for (final f in _formularios) {
      _answers[f.id] = {};
    }
  }

  List<_PerguntaRef> _buildPerguntaRefs() {
    final refs = <_PerguntaRef>[];
    for (var fi = 0; fi < _formularios.length; fi++) {
      final form = _formularios[fi];
      for (var pi = 0; pi < form.perguntas.length; pi++) {
        refs.add(_PerguntaRef(formIndex: fi, perguntaIndex: pi));
      }
    }
    return refs;
  }

  int get _totalQuestions => _perguntaRefs.length;
  int get _guideStep => _totalQuestions + 1;

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

  /// Returns the answer for the current question (step 1..N)
  dynamic _getAnswer(int step) {
    if (step < 1 || step > _totalQuestions) return null;
    final ref = _perguntaRefs[step - 1];
    final form = _formularios[ref.formIndex];
    return _answers[form.id]?[form.perguntas[ref.perguntaIndex].id];
  }

  void _setAnswer(int step, dynamic value) {
    if (step < 1 || step > _totalQuestions) return;
    final ref = _perguntaRefs[step - 1];
    final form = _formularios[ref.formIndex];
    final pergunta = form.perguntas[ref.perguntaIndex];
    setState(() {
      _answers[form.id] ??= {};
      _answers[form.id]![pergunta.id] = value;
    });
  }

  /// Whether the current question can advance (respects `required`)
  bool _canAdvance(int step) {
    if (step < 1 || step > _totalQuestions) return true;
    final ref = _perguntaRefs[step - 1];
    final form = _formularios[ref.formIndex];
    final pergunta = form.perguntas[ref.perguntaIndex];
    if (!pergunta.required) return true;
    final answer = _answers[form.id]?[pergunta.id];
    if (answer == null) return false;
    if (answer is String) return answer.trim().isNotEmpty;
    if (answer is List) return answer.isNotEmpty;
    return true; // bool etc.
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _submitError = false;
    });
    try {
      final service = OnboardingService.instance;

      // Save all formulario answers — primeiraAcesso stays true until _finish()
      for (final form in _formularios) {
        final respostas = _answers[form.id] ?? {};
        if (respostas.isNotEmpty) {
          await service.saveFormularioRespostas(
            formularioId: form.id,
            respostas: respostas,
          );
        }
      }

      _goToStep(_guideStep);
    } catch (_) {
      setState(() {
        _isSubmitting = false;
        _submitError = true;
      });
    }
  }

  Future<void> _finish() async {
    // Only here — after the user completes the mandatory guide steps — do we
    // set primeiraAcesso = false. This is the single call site for the RPC.
    try {
      await OnboardingService.instance.completeOnboarding();
    } catch (_) {
      // Don't block navigation on RPC failure
    }

    OnboardingService.instance.clearGate();

    await context.read<ItineraryCubit>().loadUserItinerary();
    if (!mounted) return;

    context.read<DocumentsCubit>().loadDocuments();
    context.read<ProfileCubit>().loadProfile();

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final group = OnboardingService.instance.group;

    // Grab the description from the first formulario (if any)
    final descricao = _formularios.isNotEmpty ? _formularios.first.descricao : null;

    // Build pages: welcome + dynamic questions + guide
    final pages = <Widget>[
      _WelcomeStep(
        group: group,
        descricao: descricao,
        onStart: _next,
      ),
      ...List.generate(_totalQuestions, (i) {
        final step = i + 1;
        final ref = _perguntaRefs[i];
        final form = _formularios[ref.formIndex];
        final pergunta = form.perguntas[ref.perguntaIndex];
        final answer = _getAnswer(step);
        final isLast = step == _totalQuestions;

        return _DynamicQuestionStep(
          number: step,
          total: _totalQuestions,
          formTitulo: form.titulo,
          pergunta: pergunta,
          answer: answer,
          onAnswerChanged: (v) => _setAnswer(step, v),
          canAdvance: _canAdvance(step),
          isLast: isLast,
          isSubmitting: _isSubmitting,
          submitError: isLast ? _submitError : false,
          onNext: isLast ? _submit : _next,
        );
      }),
      _GuideStep(onFinish: _finish),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 1 && _currentStep < _guideStep) {
          _prev();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              if (_currentStep >= 1 && _currentStep <= _totalQuestions)
                _ProgressBar(
                  current: _currentStep,
                  total: _totalQuestions,
                  onBack: _currentStep > 1 ? _prev : null,
                ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: reference into a flat list
// ─────────────────────────────────────────────────────────────────────────────

class _PerguntaRef {
  final int formIndex;
  final int perguntaIndex;

  const _PerguntaRef({required this.formIndex, required this.perguntaIndex});
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────────────────────

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
                value: total > 0 ? current / total : 0,
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

// ─────────────────────────────────────────────────────────────────────────────
// Step 0: Welcome
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  final ItineraryGroupEntity? group;
  final String? descricao;
  final VoidCallback onStart;

  const _WelcomeStep({required this.group, this.descricao, required this.onStart});

  String _fmtDate(DateTime? d, BuildContext context) {
    if (d == null) return '—';
    final lang = Localizations.localeOf(context).languageCode;
    final locale = lang == 'en' ? 'en_US' : lang == 'es' ? 'es_ES' : 'pt_BR';
    return DateFormat('dd/MM/yyyy', locale).format(d);
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
            context.l10n.onboardingWelcomeTitle,
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
                    '${_fmtDate(startDate, context)}  →  ${_fmtDate(endDate, context)}',
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
              context.l10n.onboardingWelcomeBody,
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
          // Description from the admin panel (optional)
          if (descricao != null && descricao!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Descrição',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    descricao!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              child: Text(
                context.l10n.onboardingStart,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic question step — handles text, yes_no, checkbox
// ─────────────────────────────────────────────────────────────────────────────

class _DynamicQuestionStep extends StatefulWidget {
  final int number;
  final int total;
  final String formTitulo;
  final PerguntaModel pergunta;
  final dynamic answer;
  final ValueChanged<dynamic> onAnswerChanged;
  final bool canAdvance;
  final bool isLast;
  final bool isSubmitting;
  final bool submitError;
  final VoidCallback? onNext;

  const _DynamicQuestionStep({
    required this.number,
    required this.total,
    required this.formTitulo,
    required this.pergunta,
    required this.answer,
    required this.onAnswerChanged,
    required this.canAdvance,
    required this.isLast,
    required this.isSubmitting,
    required this.submitError,
    this.onNext,
  });

  @override
  State<_DynamicQuestionStep> createState() => _DynamicQuestionStepState();
}

class _DynamicQuestionStepState extends State<_DynamicQuestionStep> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(
      text: widget.pergunta.type == FormQuestionType.text
          ? (widget.answer as String? ?? '')
          : '',
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.pergunta.type) {
      case FormQuestionType.text:
        return TextField(
          controller: _textCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Digite sua resposta aqui...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
          style: AppTextStyles.bodyMedium,
          textInputAction: TextInputAction.done,
          onChanged: widget.onAnswerChanged,
        );

      case FormQuestionType.yesNo:
        final boolAnswer = widget.answer as bool?;
        return Column(
          children: [
            _OptionButton(
              letter: 'A',
              label: 'Sim',
              selected: boolAnswer == true,
              onTap: () => widget.onAnswerChanged(true),
            ),
            const SizedBox(height: 12),
            _OptionButton(
              letter: 'B',
              label: 'Não',
              selected: boolAnswer == false,
              onTap: () => widget.onAnswerChanged(false),
            ),
          ],
        );

      case FormQuestionType.checkbox:
        final selected = List<String>.from(
          widget.answer is List ? widget.answer as List : [],
        );
        return Column(
          children: widget.pergunta.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selected.contains(option);
            final letter =
                String.fromCharCode('A'.codeUnitAt(0) + idx);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                letter: letter,
                label: option,
                selected: isSelected,
                onTap: () {
                  final updated = List<String>.from(selected);
                  if (isSelected) {
                    updated.remove(option);
                  } else {
                    updated.add(option);
                  }
                  widget.onAnswerChanged(updated);
                },
              ),
            );
          }).toList(),
        );

      case FormQuestionType.unknown:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title badge
          if (widget.formTitulo.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.formTitulo,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Question number
          Text(
            '${widget.number} →',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Question title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.pergunta.title,
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
              if (widget.pergunta.required) ...[
                const SizedBox(width: 6),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          _buildContent(context),
          // Submit error
          if (widget.submitError) ...[
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
                      'Erro ao enviar respostas. Tente novamente.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          _OkButton(
            onPressed: widget.canAdvance && !widget.isSubmitting
                ? widget.onNext
                : null,
            label: widget.isLast ? 'Enviar' : 'OK',
            isLoading: widget.isSubmitting,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable option button (A/B style)
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// OK / Next / Submit button
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Last step: Guide (mandatory checklist)
// ─────────────────────────────────────────────────────────────────────────────

class _GuideStep extends StatefulWidget {
  final Future<void> Function() onFinish;

  const _GuideStep({required this.onFinish});

  @override
  State<_GuideStep> createState() => _GuideStepState();
}

class _GuideStepState extends State<_GuideStep> {
  bool _isFinishing = false;

  // Whether medical was opened at least once (optional — no real check needed)
  bool _medicalVisited = false;

  // Completion flags derived from cubit state — refreshed after each sub-page return
  bool _profileComplete = false;
  bool _docsComplete = false;

  @override
  void initState() {
    super.initState();
    _refreshCompletionState();
  }

  void _refreshCompletionState() {
    // Profile: uses ProfileEntity.isComplete (cpf/ssn + phone + birthDate)
    context.read<ProfileCubit>().state.maybeWhen(
      loaded: (profile, _, __, ___) {
        _profileComplete = profile.isComplete;
      },
      orElse: () {},
    );

    // Documents: all mandatory docs uploaded and valid (ignores isAlertDismissed)
    _docsComplete = context.read<DocumentsCubit>().state.areDocumentsComplete;
  }

  bool get _canFinish => _profileComplete && _docsComplete;

  int get _doneCount => (_profileComplete ? 1 : 0) + (_docsComplete ? 1 : 0);

  void _open(String key, String route) {
    if (key == 'medical') {
      // Medical is optional — mark visited immediately and open
      setState(() => _medicalVisited = true);
      context.push(route);
    } else {
      // For required items: open, then re-check state when user returns
      context.push(route).then((_) {
        if (mounted) setState(_refreshCompletionState);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDone = _canFinish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // ── Header icon ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: allDone
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.orange.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allDone
                  ? Icons.check_circle_outline_rounded
                  : Icons.assignment_outlined,
              color: allDone ? AppColors.primary : Colors.orange.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ─────────────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              allDone
                  ? context.l10n.onboardingAllDone
                  : context.l10n.onboardingGuideIncompleteTitle,
              key: ValueKey(allDone),
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            allDone
                ? context.l10n.onboardingParticipationConfirmed
                : context.l10n.onboardingGuideIncompleteBody,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.60),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── Progress chips ─────────────────────────────────────────────────
          if (!allDone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.orange.withOpacity(0.12)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    '$_doneCount/2 ${context.l10n.onboardingGuideMandatoryDone}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ── Cards ─────────────────────────────────────────────────────────
          _GuideCard(
            icon: Icons.person_outline_rounded,
            title: context.l10n.onboardingGuidePersonalDataTitle,
            subtitle: context.l10n.onboardingGuidePersonalDataSub,
            badgeLabel: context.l10n.onboardingBadgeRequired,
            isRequired: true,
            isDone: _profileComplete,
            onTap: () => _open('profile', '/account-data'),
          ),
          const SizedBox(height: 10),
          _GuideCard(
            icon: Icons.description_outlined,
            title: context.l10n.onboardingGuideDocumentsTitle,
            subtitle: context.l10n.onboardingGuideDocumentsSub,
            badgeLabel: context.l10n.onboardingBadgeRequired,
            isRequired: true,
            isDone: _docsComplete,
            onTap: () => _open('docs', '/documents'),
          ),
          const SizedBox(height: 10),
          _GuideCard(
            icon: Icons.medical_information_outlined,
            title: context.l10n.onboardingGuideMedicalTitle,
            subtitle: context.l10n.onboardingGuideMedicalSub,
            badgeLabel: context.l10n.onboardingBadgeOptional,
            isRequired: false,
            isDone: _medicalVisited,
            onTap: () => _open('medical', '/medical-restrictions'),
          ),

          const SizedBox(height: 32),

          // ── Main button ───────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _canFinish ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_canFinish && !_isFinishing)
                    ? () async {
                        setState(() => _isFinishing = true);
                        await widget.onFinish();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _canFinish ? 2 : 0,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.onboardingGoToApp,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_canFinish) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
              ),
            ),
          ),

          if (!_canFinish) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.onboardingGuideCompleteHint,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.40),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final bool isRequired;
  final bool isDone;
  final VoidCallback onTap;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.isRequired,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = isDone
        ? AppColors.primary
        : isRequired
            ? Colors.orange.shade600
            : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone
              ? (isDark
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.04))
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.primary.withOpacity(0.30)
                : isRequired
                    ? Colors.orange.withOpacity(0.35)
                    : Theme.of(context).dividerColor.withOpacity(0.35),
            width: isDone || isRequired ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary.withOpacity(0.12)
                    : isRequired
                        ? Colors.orange.withOpacity(0.10)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDone
                    ? AppColors.primary
                    : isRequired
                        ? Colors.orange.shade600
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.45),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Text + badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.75)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isDone ? context.l10n.onboardingBadgeDone : badgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right icon
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: isDone ? 20 : 14,
              color: isDone
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.28),
            ),
          ],
        ),
      ),
    );
  }
}
