import 'dart:convert';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/form_field_entity.dart';
import 'package:agrobravo/features/itinerary/domain/entities/mission_material.dart';
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormPage extends StatefulWidget {
  final MissionMaterialEntity material;

  const FormPage({super.key, required this.material});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late final ItineraryRepository _repository;

  List<FormFieldEntity> _fields = [];
  Map<String, String?> _responses = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _alreadyAnswered = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.I<ItineraryRepository>();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final fieldsResult = await _repository.getFormFields(widget.material.id);
    final responsesResult = await _repository.getFormResponses(widget.material.id);

    setState(() {
      _isLoading = false;
      fieldsResult.fold(
        (e) => _error = e.toString().replaceAll('Exception: ', ''),
        (fields) => _fields = fields,
      );
      responsesResult.fold(
        (_) {},
        (resps) {
          _responses = Map.from(resps);
          _alreadyAnswered = resps.isNotEmpty;
        },
      );
    });
  }

  int get _answeredCount =>
      _fields.where((f) => (_responses[f.id]?.isNotEmpty ?? false)).length;

  bool get _canSubmit {
    for (final field in _fields) {
      if (field.obrigatorio) {
        final val = _responses[field.id];
        if (val == null || val.isEmpty) return false;
      }
    }
    return _fields.isNotEmpty;
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final rows = _fields.map((f) => {
          'campoId': f.id,
          'valor': _responses[f.id] ?? '',
        }).toList();

    final result = await _repository.saveFormResponses(widget.material.id, rows);
    setState(() => _isSaving = false);

    result.fold(
      (e) => _showError(e.toString().replaceAll('Exception: ', '')),
      (_) => setState(() {
        _submitted = true;
        _alreadyAnswered = true;
      }),
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _FormAppBar(
            title: widget.material.name,
            answered: _answeredCount,
            total: _fields.length,
          ),
          if (_isLoading)
            const SliverFillRemaining(child: _FormLoading())
          else if (_error != null)
            SliverFillRemaining(child: _FormError(error: _error!, onRetry: _loadForm))
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
                    final field = _fields[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _FieldCard(
                        field: field,
                        index: index,
                        value: _responses[field.id],
                        onChanged: (val) =>
                            setState(() => _responses[field.id] = val),
                      ),
                    );
                  },
                  childCount: _fields.length,
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
              alreadyAnswered: _alreadyAnswered,
              onSubmit: _submit,
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
// Field Card
// ─────────────────────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  final FormFieldEntity field;
  final int index;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FieldCard({
    required this.field,
    required this.index,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: (value?.isNotEmpty ?? false)
              ? AppColors.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          width: (value?.isNotEmpty ?? false) ? 1.5 : 1,
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
                          field.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (field.obrigatorio)
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
    switch (field.tipo) {
      case 'texto_curto':
        return _TextCurto(value: value, onChanged: onChanged);
      case 'texto_longo':
        return _TextoLongo(value: value, onChanged: onChanged);
      case 'multipla_escolha':
        return _MultiplaEscolha(
          opcoes: field.opcoes,
          value: value,
          onChanged: onChanged,
        );
      case 'checkbox':
        return _CheckboxField(
          opcoes: field.opcoes,
          value: value,
          onChanged: onChanged,
        );
      case 'nota':
        return _NotaField(value: value, onChanged: onChanged);
      default:
        return const SizedBox.shrink();
    }
  }

  IconData get _fieldIcon {
    switch (field.tipo) {
      case 'texto_curto': return Icons.short_text_rounded;
      case 'texto_longo': return Icons.subject_rounded;
      case 'multipla_escolha': return Icons.radio_button_checked_rounded;
      case 'checkbox': return Icons.check_box_rounded;
      case 'nota': return Icons.star_rounded;
      default: return Icons.help_outline;
    }
  }

  Color get _fieldColor {
    switch (field.tipo) {
      case 'texto_curto': return const Color(0xFF2196F3);
      case 'texto_longo': return const Color(0xFF9C27B0);
      case 'multipla_escolha': return const Color(0xFF4CAF50);
      case 'checkbox': return const Color(0xFFFF9800);
      case 'nota': return const Color(0xFFFFC107);
      default: return AppColors.primary;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TextCurto extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TextCurto({required this.value, required this.onChanged});

  @override
  State<_TextCurto> createState() => _TextCurtoState();
}

class _TextCurtoState extends State<_TextCurto> {
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
      onChanged: widget.onChanged,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Digite sua resposta...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
      ),
    );
  }
}

class _TextoLongo extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TextoLongo({required this.value, required this.onChanged});

  @override
  State<_TextoLongo> createState() => _TextoLongoState();
}

class _TextoLongoState extends State<_TextoLongo> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _ctrl,
          onChanged: widget.onChanged,
          maxLines: 4,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Digite sua resposta...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_ctrl.text.length} caracteres',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MultiplaEscolha extends StatelessWidget {
  final List<String> opcoes;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _MultiplaEscolha({
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
          onTap: () => onChanged(opcao),
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
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
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
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

class _CheckboxField extends StatelessWidget {
  final List<String> opcoes;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CheckboxField({
    required this.opcoes,
    required this.value,
    required this.onChanged,
  });

  Set<String> get _selected {
    if (value == null || value!.isEmpty) return {};
    try {
      final list = jsonDecode(value!) as List;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  void _toggle(String opcao) {
    final sel = Set<String>.from(_selected);
    if (sel.contains(opcao)) {
      sel.remove(opcao);
    } else {
      sel.add(opcao);
    }
    onChanged(jsonEncode(sel.toList()));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      children: opcoes.map((opcao) {
        final isChecked = selected.contains(opcao);
        return InkWell(
          onTap: () => _toggle(opcao),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: isChecked
                  ? const Color(0xFFFF9800).withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isChecked
                    ? const Color(0xFFFF9800).withValues(alpha: 0.5)
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
                    borderRadius: BorderRadius.circular(4),
                    color: isChecked ? const Color(0xFFFF9800) : Colors.transparent,
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFFFF9800)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  opcao,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isChecked
                        ? const Color(0xFFFF9800)
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
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

class _NotaField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _NotaField({required this.value, required this.onChanged});

  int get _current => int.tryParse(value ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            final isActive = star <= _current;
            return GestureDetector(
              onTap: () => onChanged(star.toString()),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 38,
                  color: isActive ? const Color(0xFFFFC107) : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
        if (_current > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                _ratingLabel(_current),
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _ratingLabel(int v) {
    switch (v) {
      case 1: return '⭐ Muito ruim';
      case 2: return '⭐⭐ Ruim';
      case 3: return '⭐⭐⭐ Regular';
      case 4: return '⭐⭐⭐⭐ Bom';
      case 5: return '⭐⭐⭐⭐⭐ Excelente!';
      default: return '';
    }
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

  const _SubmitBar({
    required this.canSubmit,
    required this.isSaving,
    required this.alreadyAnswered,
    required this.onSubmit,
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
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alreadyAnswered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Você já respondeu este formulário. Enviar novamente atualizará suas respostas.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canSubmit ? AppColors.primary : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: (canSubmit && !isSaving) ? onSubmit : null,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          alreadyAnswered ? 'Atualizar respostas' : 'Enviar respostas',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

class _FormLoading extends StatelessWidget {
  const _FormLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Carregando formulário...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Respostas enviadas!',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suas respostas foram salvas com sucesso.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
