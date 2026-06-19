import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart';
import 'package:agrobravo/features/onboarding/data/models/grupo_formulario_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Page for filling out a GrupoFormulario (non-onboarding) from the admin panel.
/// Supports text, yes_no, and checkbox question types.
class GrupoFormularioPage extends StatefulWidget {
  final GrupoFormularioModel formulario;

  const GrupoFormularioPage({super.key, required this.formulario});

  @override
  State<GrupoFormularioPage> createState() => _GrupoFormularioPageState();
}

class _GrupoFormularioPageState extends State<GrupoFormularioPage> {
  late final ItineraryRepository _repository;
  final Map<String, dynamic> _answers = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _submitted = false;
  bool _showValidation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.I<ItineraryRepository>();
    _loadExistingResponses();
  }

  Future<void> _loadExistingResponses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result =
        await _repository.getGrupoFormularioRespostas(widget.formulario.id);

    setState(() {
      _isLoading = false;
      result.fold(
        (e) => _error = e.toString().replaceAll('Exception: ', ''),
        (respostas) => _answers.addAll(respostas),
      );
    });
  }

  int get _answeredCount {
    return widget.formulario.perguntas.where((p) {
      final answer = _answers[p.id];
      if (answer == null) return false;
      if (answer is String) return answer.trim().isNotEmpty;
      if (answer is List) return answer.isNotEmpty;
      return true; // bool
    }).length;
  }

  bool get _canSubmit {
    for (final p in widget.formulario.perguntas) {
      if (p.required) {
        final answer = _answers[p.id];
        if (answer == null) return false;
        if (answer is String && answer.trim().isEmpty) return false;
        if (answer is List && answer.isEmpty) return false;
      }
    }
    return widget.formulario.perguntas.isNotEmpty;
  }

  int get _missingRequiredCount {
    int count = 0;
    for (final p in widget.formulario.perguntas) {
      if (!p.required) continue;
      final answer = _answers[p.id];
      if (answer == null) { count++; continue; }
      if (answer is String && answer.trim().isEmpty) { count++; continue; }
      if (answer is List && answer.isEmpty) { count++; continue; }
    }
    return count;
  }

  bool _isMissingAnswer(PerguntaModel p) {
    if (!p.required) return false;
    final answer = _answers[p.id];
    if (answer == null) return true;
    if (answer is String && answer.trim().isEmpty) return true;
    if (answer is List && answer.isEmpty) return true;
    return false;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => _showValidation = true);
      return;
    }

    setState(() => _isSaving = true);

    final result = await _repository.saveGrupoFormularioRespostas(
      widget.formulario.id,
      _answers,
    );

    setState(() => _isSaving = false);

    result.fold(
      (e) => _showError(e.toString().replaceAll('Exception: ', '')),
      (_) => setState(() => _submitted = true),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _FormAppBar(
            title: widget.formulario.titulo,
            answered: _answeredCount,
            total: widget.formulario.perguntas.length,
          ),
          if (_isLoading)
            const SliverFillRemaining(child: _FormLoading())
          else if (_error != null)
            SliverFillRemaining(
              child: _FormError(error: _error!, onRetry: _loadExistingResponses),
            )
          else if (_submitted)
            const SliverFillRemaining(child: _FormSuccess())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 120,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pergunta = widget.formulario.perguntas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _PerguntaCard(
                        pergunta: pergunta,
                        index: index,
                        answer: _answers[pergunta.id],
                        showMissing: _showValidation && _isMissingAnswer(pergunta),
                        onChanged: (val) =>
                            setState(() => _answers[pergunta.id] = val),
                      ),
                    );
                  },
                  childCount: widget.formulario.perguntas.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: (_isLoading || _error != null || _submitted)
          ? null
          : _SubmitBar(
              canSubmit: _canSubmit,
              isSaving: _isSaving,
              alreadyAnswered: widget.formulario.hasUserResponse,
              onSubmit: _submit,
              missingCount: _showValidation ? _missingRequiredCount : 0,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _FormAppBar extends StatelessWidget {
  final String title;
  final int answered;
  final int total;

  const _FormAppBar({
    required this.title,
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : answered / total;

    return SliverAppBar(
      expandedHeight: 130,
      collapsedHeight: 60,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$answered/$total',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pergunta Card (supports text, yes_no, checkbox)
// ─────────────────────────────────────────────────────────────────────────────

class _PerguntaCard extends StatelessWidget {
  final PerguntaModel pergunta;
  final int index;
  final dynamic answer;
  final bool showMissing;
  final ValueChanged<dynamic> onChanged;

  const _PerguntaCard({
    required this.pergunta,
    required this.index,
    required this.answer,
    this.showMissing = false,
    required this.onChanged,
  });

  bool get _hasAnswer {
    if (answer == null) return false;
    if (answer is String) return (answer as String).trim().isNotEmpty;
    if (answer is List) return (answer as List).isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: showMissing
              ? const Color(0xFFD32F2F).withValues(alpha: 0.6)
              : _hasAnswer
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
          width: showMissing || _hasAnswer ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _fieldColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_fieldIcon, size: 13, color: _fieldColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pergunta.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (pergunta.required)
                        const Text(
                          ' *',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Descrição opcional
          if (pergunta.descricao != null &&
              pergunta.descricao!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm,
              ),
              child: Text(
                pergunta.descricao!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                  height: 1.4,
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1),
          // Input
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildInput(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (pergunta.type) {
      case FormQuestionType.text:
        return _TextInput(
          value: answer as String?,
          onChanged: onChanged,
        );
      case FormQuestionType.yesNo:
        return _YesNoInput(
          value: answer as bool?,
          onChanged: onChanged,
        );
      case FormQuestionType.checkbox:
        return _CheckboxInput(
          opcoes: pergunta.options,
          value: answer as String?,
          onChanged: onChanged,
        );
      case FormQuestionType.unknown:
        return const SizedBox.shrink();
    }
  }

  IconData get _fieldIcon {
    switch (pergunta.type) {
      case FormQuestionType.text:
        return Icons.short_text_rounded;
      case FormQuestionType.yesNo:
        return Icons.check_circle_outline_rounded;
      case FormQuestionType.checkbox:
        return Icons.check_box_rounded;
      case FormQuestionType.unknown:
        return Icons.help_outline;
    }
  }

  Color get _fieldColor {
    switch (pergunta.type) {
      case FormQuestionType.text:
        return const Color(0xFF2196F3);
      case FormQuestionType.yesNo:
        return const Color(0xFF4CAF50);
      case FormQuestionType.checkbox:
        return const Color(0xFFFF9800);
      case FormQuestionType.unknown:
        return AppColors.primary;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TextInput extends StatefulWidget {
  final String? value;
  final ValueChanged<dynamic> onChanged;
  const _TextInput({required this.value, required this.onChanged});

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: (v) => widget.onChanged(v),
      maxLines: 4,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Digite sua resposta...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}

class _YesNoInput extends StatelessWidget {
  final bool? value;
  final ValueChanged<dynamic> onChanged;

  const _YesNoInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OptionTile(
            label: 'Sim',
            icon: Icons.check_rounded,
            selected: value == true,
            color: const Color(0xFF4CAF50),
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _OptionTile(
            label: 'Não',
            icon: Icons.close_rounded,
            selected: value == false,
            color: const Color(0xFFD32F2F),
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxInput extends StatelessWidget {
  final List<String> opcoes;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _CheckboxInput({
    required this.opcoes,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: opcoes.map((opcao) {
        final isSelected = value == opcao;
        return InkWell(
          onTap: () => onChanged(isSelected ? null : opcao),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                      width: isSelected ? 5 : 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  opcao,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final bool canSubmit;
  final bool isSaving;
  final bool alreadyAnswered;
  final VoidCallback onSubmit;
  final int missingCount;

  const _SubmitBar({
    required this.canSubmit,
    required this.isSaving,
    required this.alreadyAnswered,
    required this.onSubmit,
    this.missingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning: missing required fields
          if (missingCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        missingCount == 1
                            ? 'Preencha 1 pergunta obrigatória (*) para enviar.'
                            : 'Preencha $missingCount perguntas obrigatórias (*) para enviar.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (alreadyAnswered && missingCount == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Você já respondeu este formulário. Enviar novamente atualizará suas respostas.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: !isSaving ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      alreadyAnswered ? 'Atualizar Respostas' : 'Enviar',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / Error / Success states
// ─────────────────────────────────────────────────────────────────────────────

class _FormLoading extends StatelessWidget {
  const _FormLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _FormError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _FormError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSuccess extends StatelessWidget {
  const _FormSuccess();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4CAF50),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Respostas enviadas com sucesso!',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas respostas foram registradas.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
