import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/checklist_item.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/domain/entities/mission_material.dart';
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/form_page.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelDataPage extends StatefulWidget {
  final ItineraryGroupEntity group;

  const TravelDataPage({super.key, required this.group});

  @override
  State<TravelDataPage> createState() => _TravelDataPageState();
}

class _TravelDataPageState extends State<TravelDataPage> {
  late final ItineraryRepository _repository;
  late Future<Either<Exception, List<MissionMaterialEntity>>> _materialsFuture;
  late Future<Either<Exception, List<ChecklistItemEntity>>> _checklistFuture;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.I<ItineraryRepository>();
    _materialsFuture = _repository.getMissionMaterials(widget.group.id);
    _checklistFuture = _repository.getChecklist(widget.group.id);
  }

  Future<void> _refresh() async {
    final matFuture = _repository.getMissionMaterials(widget.group.id);
    final checkFuture = _repository.getChecklist(widget.group.id);
    setState(() {
      _materialsFuture = matFuture;
      _checklistFuture = checkFuture;
    });
    await Future.wait([matFuture, checkFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: context.l10n.itineraryTravelData,
        subtitle: widget.group.name,
      ),
      body: FutureBuilder<Either<Exception, List<MissionMaterialEntity>>>(
        future: _materialsFuture,
        builder: (context, snapshot) {
          final materialsResult = snapshot.data;
          final materials = materialsResult?.fold(
                (_) => <MissionMaterialEntity>[],
                (items) => items,
              ) ??
              <MissionMaterialEntity>[];
          final errorMessage = materialsResult?.fold(
            (error) => error.toString().replaceAll('Exception: ', ''),
            (_) => null,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                _TripSummary(group: widget.group),
                const SizedBox(height: AppSpacing.lg),

                // Checklist section
                FutureBuilder<Either<Exception, List<ChecklistItemEntity>>>(
                  future: _checklistFuture,
                  builder: (context, checkSnap) {
                    final checklistResult = checkSnap.data;
                    final checklist = checklistResult?.fold(
                          (_) => <ChecklistItemEntity>[],
                          (items) => items,
                        ) ??
                        <ChecklistItemEntity>[];
                    final isLoadingChecklist =
                        checkSnap.connectionState == ConnectionState.waiting;

                    if (isLoadingChecklist || checklist.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.itineraryChecklistTitle,
                            style: AppTextStyles.h3.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (isLoadingChecklist)
                            const _MaterialsLoading()
                          else
                            _ChecklistSection(
                              items: checklist,
                              repository: _repository,
                            ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Text(
                  context.l10n.itineraryDocumentsTitle,
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _MaterialsLoading()
                else if (materials.isNotEmpty)
                  ...materials.map((material) {
                    if (material.tipo == 'form') {
                      return _FormMaterialTile(
                        material: material,
                        onTap: () async {
                          final answered = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => FormPage(material: material),
                            ),
                          );
                          if (answered == true) _refresh();
                        },
                      );
                    }
                    return _MaterialTile(material);
                  })
                else
                  _EmptyMaterials(errorMessage: errorMessage),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  final ItineraryGroupEntity group;

  const _TripSummary({required this.group});

  @override
  Widget build(BuildContext context) {
    final missionName = group.missionName?.isNotEmpty == true
        ? group.missionName!
        : context.l10n.itineraryCurrentMission;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
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
          _InfoRow(
            icon: Icons.flag_outlined,
            label: context.l10n.itineraryMission,
            value: missionName,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.group_outlined,
            label: context.l10n.itineraryGroup,
            value: group.name,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DateMetric(
                  label: context.l10n.itineraryStarts,
                  value: _relativeStartLabel(group.startDate, context),
                  date: dateFormat.format(group.startDate),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DateMetric(
                  label: context.l10n.itineraryEnds,
                  value: _relativeEndLabel(group.endDate, context),
                  date: dateFormat.format(group.endDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeStartLabel(DateTime startDate, BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(startDate);
    final diff = start.difference(today).inDays;

    if (diff > 1) return context.l10n.itineraryInDays(diff);
    if (diff == 1) return context.l10n.itineraryTomorrow;
    if (diff == 0) return context.l10n.itineraryToday;
    return context.l10n.itineraryStarted;
  }

  String _relativeEndLabel(DateTime endDate, BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final end = _dateOnly(endDate);
    final diff = end.difference(today).inDays;

    if (diff > 1) return context.l10n.itineraryInDays(diff);
    if (diff == 1) return context.l10n.itineraryTomorrow;
    if (diff == 0) return context.l10n.itineraryToday;
    return context.l10n.itineraryEnded;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.52),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateMetric extends StatelessWidget {
  final String label;
  final String value;
  final String date;

  const _DateMetric({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.58),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Checklist
// ---------------------------------------------------------------------------

class _ChecklistSection extends StatefulWidget {
  final List<ChecklistItemEntity> items;
  final ItineraryRepository repository;

  const _ChecklistSection({required this.items, required this.repository});

  @override
  State<_ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<_ChecklistSection> {
  late final List<ChecklistItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  Future<void> _toggle(ChecklistItemEntity item) async {
    final newValue = !item.isChecked;
    setState(() => item.isChecked = newValue);

    final result = await widget.repository.toggleChecklistItem(item.id, newValue);
    result.fold(
      (_) {
        // revert on error
        if (mounted) setState(() => item.isChecked = !newValue);
      },
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final checked = _items.where((i) => i.isChecked).length;
    final total = _items.length;
    final progress = total == 0 ? 0.0 : checked / total;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
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
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$checked/$total',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = _items[index];
              return InkWell(
                onTap: () => _toggle(item),
                borderRadius: index == _items.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(AppSpacing.radiusLg),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: item.isChecked
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: item.isChecked
                                ? AppColors.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.35),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: item.isChecked
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.titulo,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: item.isChecked
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.45)
                                : Theme.of(context).colorScheme.onSurface,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Materials
// ---------------------------------------------------------------------------

class _MaterialTile extends StatelessWidget {
  final MissionMaterialEntity material;

  const _MaterialTile(this.material);

  @override
  Widget build(BuildContext context) {
    final updatedAt = material.updatedAt ?? material.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => _openMaterial(context),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _fileColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(_fileIcon, color: _fileColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (material.size?.isNotEmpty == true)
                            material.size!,
                          if (updatedAt != null)
                            DateFormat('dd/MM/yyyy').format(updatedAt),
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.52),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.open_in_new_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _fileIcon {
    final extension = _extension;
    if (['png', 'jpg', 'jpeg', 'webp'].contains(extension)) {
      return Icons.image_outlined;
    }
    if (['xls', 'xlsx'].contains(extension)) return Icons.table_chart_outlined;
    return Icons.picture_as_pdf_outlined;
  }

  Color get _fileColor {
    final extension = _extension;
    if (['png', 'jpg', 'jpeg', 'webp'].contains(extension)) {
      return AppColors.secondary;
    }
    if (['xls', 'xlsx'].contains(extension)) return AppColors.primary;
    return const Color(0xFFD32F2F);
  }

  String get _extension {
    final uri = Uri.tryParse(material.url);
    final path = uri?.path ?? material.url;
    final fileName = path.split('/').last.toLowerCase();
    if (!fileName.contains('.')) return '';
    return fileName.split('.').last;
  }

  Future<void> _openMaterial(BuildContext context) async {
    final uri = Uri.tryParse(material.url);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.itineraryOpenMaterialError)),
      );
    }
  }
}

class _MaterialsLoading extends StatelessWidget {
  const _MaterialsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 74,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}

class _EmptyMaterials extends StatelessWidget {
  final String? errorMessage;

  const _EmptyMaterials({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.35),
            size: 34,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage ?? context.l10n.itineraryNoMaterials,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form Material Tile
// ---------------------------------------------------------------------------

class _FormMaterialTile extends StatelessWidget {
  final MissionMaterialEntity material;
  final VoidCallback onTap;

  const _FormMaterialTile({required this.material, required this.onTap});

  static const _green = Color(0xFF4CAF50);
  static const _orange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final responded = material.hasUserResponse;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: responded
                    ? _green.withValues(alpha: 0.25)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: _green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Título + label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Formulário',
                              style: TextStyle(
                                color: _green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge respondido/pendente
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: responded
                                  ? _green.withValues(alpha: 0.08)
                                  : _orange.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  responded
                                      ? Icons.check_circle_outline
                                      : Icons.pending_outlined,
                                  size: 10,
                                  color: responded ? _green : _orange,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  responded ? 'Respondido' : 'Pendente',
                                  style: TextStyle(
                                    color: responded ? _green : _orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

