import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/data/models/travel_guide_models.dart';
import 'package:agrobravo/features/itinerary/data/repositories/travel_guide_repository.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/travel_guide_card_widget.dart';

/// Tela principal do Guia de Viagem.
///
/// Recebe o [groupId] e:
/// 1. Faz carregamento paralelo do guia e dos checks do viajante
/// 2. Exibe skeleton/loading durante o carregamento
/// 3. Trata estado vazio (guia nulo ou oculto) com mensagem amigável
/// 4. Exibe barra de progresso e lista de cards com checkbox
class TravelGuidePage extends StatefulWidget {
  final String groupId;
  final String? groupName;

  const TravelGuidePage({
    super.key,
    required this.groupId,
    this.groupName,
  });

  @override
  State<TravelGuidePage> createState() => _TravelGuidePageState();
}

class _TravelGuidePageState extends State<TravelGuidePage> {
  late final TravelGuideRepository _repository;

  TravelGuide? _guide;
  bool _loading = true;
  String? _error;

  // Controla quais cards estão em processo de salvamento (para UI de loading)
  final Set<String> _savingCards = {};

  @override
  void initState() {
    super.initState();
    _repository = TravelGuideRepository(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Carregamento paralelo: guia + checks
      final results = await Future.wait([
        _repository.getGuide(widget.groupId),
        _repository.getChecks(widget.groupId),
      ]);

      final guide = results[0] as TravelGuide?;
      final checks = results[1] as List<CardCheck>;

      if (guide != null && checks.isNotEmpty) {
        // Mescla o progresso nos cards
        final checksMap = {for (final c in checks) c.cardId: c};
        for (final card in guide.cards) {
          final check = checksMap[card.id];
          if (check != null) {
            card.concluido = check.concluido;
            card.checkedAt = check.checkedAt;
          }
        }
      }

      if (mounted) {
        setState(() {
          _guide = guide;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar o guia. Tente novamente.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _onToggleCheck(TravelGuideCard card, bool newValue) async {
    // 1. Atualização otimista
    setState(() {
      card.concluido = newValue;
      _savingCards.add(card.id);
    });

    // 2. Persistir no backend
    final success = await _repository.toggleCheck(
      cardId: card.id,
      concluido: newValue,
    );

    if (!mounted) return;

    if (!success) {
      // 3. Reverter em caso de erro
      setState(() {
        card.concluido = !newValue;
        _savingCards.remove(card.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível salvar. Tente novamente.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    } else {
      setState(() {
        _savingCards.remove(card.id);
      });
    }
  }

  Future<void> _onToggleAll(bool newValue) async {
    final cards = _guide?.cards;
    if (cards == null || cards.isEmpty) return;

    final cardsToUpdate = cards.where((c) => c.concluido != newValue).toList();
    if (cardsToUpdate.isEmpty) return;

    final cardIdsToUpdate = cardsToUpdate.map((c) => c.id).toList();

    // 1. Atualização otimista
    setState(() {
      for (final card in cardsToUpdate) {
        card.concluido = newValue;
      }
      _savingCards.addAll(cardIdsToUpdate);
    });

    // 2. Persistir no backend
    final success = await _repository.toggleAllChecks(
      cardIds: cardIdsToUpdate,
      concluido: newValue,
    );

    if (!mounted) return;

    if (!success) {
      // 3. Reverter em caso de erro
      setState(() {
        for (final card in cardsToUpdate) {
          card.concluido = !newValue;
        }
        _savingCards.removeAll(cardIdsToUpdate);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível salvar. Tente novamente.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    } else {
      setState(() {
        _savingCards.removeAll(cardIdsToUpdate);
      });
    }
  }

  int get _completedCount =>
      _guide?.cards.where((c) => c.concluido).length ?? 0;
  int get _totalCount => _guide?.cards.length ?? 0;
  double get _progress =>
      _totalCount == 0 ? 0.0 : _completedCount / _totalCount;
  bool get _allDone => _totalCount > 0 && _completedCount == _totalCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.back,
            title: _guide?.titulo ?? 'Guia de Viagem',
            subtitle: widget.groupName,
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _TravelGuideShimmer();

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _loadData,
      );
    }

    if (_guide == null) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          // ── Progresso ──────────────────────────────────────────────────────
          _ProgressHeader(
            completed: _completedCount,
            total: _totalCount,
            progress: _progress,
            allDone: _allDone,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Cards ──────────────────────────────────────────────────────────
          ...(_guide!.cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
                child: TravelGuideCardWidget(
                  card: card,
                  onToggle: (newValue) => _onToggleCheck(card, newValue),
                  isLoading: _savingCards.contains(card.id),
                ),
              ))),

          // ── Marcar todos ───────────────────────────────────────────────────
          if (_totalCount > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CheckboxListTile(
                value: _allDone,
                onChanged: _savingCards.isNotEmpty
                    ? null
                    : (value) => _onToggleAll(value ?? false),
                activeColor: AppColors.primary,
                title: Text(
                  'Marcar todos como concluídos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progresso header
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;
  final bool allDone;

  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.08),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progresso',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$completed de $total concluídos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.h3.copyWith(
                  color: allDone ? AppColors.primary : AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Estado vazio
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 36,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhum guia disponível',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nenhum guia de viagem disponível para este grupo no momento.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado de erro
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.error.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ops! Algo deu errado',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton (shimmer)
// ─────────────────────────────────────────────────────────────────────────────

class _TravelGuideShimmer extends StatelessWidget {
  const _TravelGuideShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget shimmerBox({double height = 20, double? width, double radius = 8}) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        // Progress header shimmer
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  shimmerBox(height: 36, width: 36, radius: AppSpacing.radiusMd),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerBox(height: 12, width: 80),
                      const SizedBox(height: 4),
                      shimmerBox(height: 16, width: 140),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              shimmerBox(height: 8, width: double.infinity, radius: 4),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Card shimmers
        for (int i = 0; i < 3; i++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    shimmerBox(height: 40, width: 40, radius: AppSpacing.radiusMd),
                    const SizedBox(width: AppSpacing.sm + 4),
                    shimmerBox(height: 18, width: 160),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                const SizedBox(height: AppSpacing.sm),
                shimmerBox(height: 14, width: double.infinity),
                const SizedBox(height: 6),
                shimmerBox(height: 14, width: double.infinity),
                const SizedBox(height: 6),
                shimmerBox(height: 14, width: 200),
                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    shimmerBox(height: 22, width: 22, radius: 6),
                    const SizedBox(width: AppSpacing.sm + 4),
                    shimmerBox(height: 14, width: 140),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }
}
