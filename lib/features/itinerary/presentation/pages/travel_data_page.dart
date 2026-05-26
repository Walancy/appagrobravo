import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/domain/entities/mission_material.dart';
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _repository = GetIt.I<ItineraryRepository>();
    _materialsFuture = _repository.getMissionMaterials(widget.group.id);
  }

  Future<void> _refreshMaterials() async {
    final future = _repository.getMissionMaterials(widget.group.id);
    setState(() {
      _materialsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: 'Dados da viagem',
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
            onRefresh: () async {
              await _refreshMaterials();
            },
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
                Text(
                  'Documentos da missão',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _MaterialsLoading()
                else if (materials.isNotEmpty)
                  ...materials.map((material) => _MaterialTile(material))
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
        : 'Missão Atual';
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
            label: 'Missão',
            value: missionName,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.group_outlined,
            label: 'Grupo',
            value: group.name,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DateMetric(
                  label: 'Começa',
                  value: _relativeStartLabel(group.startDate),
                  date: dateFormat.format(group.startDate),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DateMetric(
                  label: 'Termina',
                  value: _relativeEndLabel(group.endDate),
                  date: dateFormat.format(group.endDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeStartLabel(DateTime startDate) {
    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(startDate);
    final diff = start.difference(today).inDays;

    if (diff > 1) return 'em $diff dias';
    if (diff == 1) return 'amanhã';
    if (diff == 0) return 'hoje';
    return 'iniciada';
  }

  String _relativeEndLabel(DateTime endDate) {
    final today = _dateOnly(DateTime.now());
    final end = _dateOnly(endDate);
    final diff = end.difference(today).inDays;

    if (diff > 1) return 'em $diff dias';
    if (diff == 1) return 'amanhã';
    if (diff == 0) return 'hoje';
    return 'encerrada';
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
        const SnackBar(content: Text('Não foi possível abrir o material')),
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
            errorMessage ?? 'Nenhum material disponível',
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
