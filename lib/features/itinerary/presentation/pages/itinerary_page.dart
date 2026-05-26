import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:agrobravo/core/components/itinerary_shimmer.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_data_page.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/day_slider.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_filter_modal.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_list.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/mission_header_card.dart';

class ItineraryPage extends StatelessWidget {
  final String groupId;

  const ItineraryPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ItineraryCubit>()..loadItinerary(groupId),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Itinerário',
            style: AppTextStyles.h3.copyWith(color: AppColors.surface),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<ItineraryCubit, ItineraryState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const ItineraryShimmer(),
              error: (msg) => Center(child: Text('Erro: $msg')),
              loaded: (group, items, travelTimes, pendingDocs) {
                final isEnded =
                    group.status == 'Finalizado' ||
                    group.endDate.isBefore(DateTime.now());
                return _ItineraryContent(
                  group: group,
                  items: items,
                  travelTimes: travelTimes,
                  isEnded: isEnded,
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class _ItineraryContent extends StatefulWidget {
  final ItineraryGroupEntity group;
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;
  final bool isEnded;

  const _ItineraryContent({
    required this.group,
    required this.items,
    required this.travelTimes,
    required this.isEnded,
  });

  @override
  State<_ItineraryContent> createState() => _ItineraryContentState();
}

class _ItineraryContentState extends State<_ItineraryContent> {
  DateTime? _selectedDate;
  ItineraryFilters _filters = const ItineraryFilters();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (widget.group.startDate.year > 0) {
      if (today.isAfter(
            widget.group.startDate.subtract(const Duration(days: 1)),
          ) &&
          today.isBefore(widget.group.endDate.add(const Duration(days: 1)))) {
        _selectedDate = today;
      } else {
        _selectedDate = widget.group.startDate;
      }
    }
    // Normalize
    if (_selectedDate != null) {
      _selectedDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
    }
  }

  void _showFilterModal() async {
    final result = await showDialog<ItineraryFilters>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ItineraryFilterModal(initialFilters: _filters),
      ),
    );
    if (result != null) {
      setState(() => _filters = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isEnded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Missão encerrada',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MissionHeaderCard(
            missionName: widget.group.missionName ?? 'Missão Atual',
            groupName: widget.group.name,
            startDate: widget.group.startDate,
            endDate: widget.group.endDate,
            onTravelDataTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TravelDataPage(group: widget.group),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        DaySlider(
          startDate: widget.group.startDate,
          endDate: widget.group.endDate,
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _filters.isActive
                    ? '${_filters.count} filtros aplicados'
                    : 'Sem filtros aplicados',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _filters.isActive
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: _filters.isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _filters.isActive
                        ? AppColors.primary.withOpacity(0.1)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF2F4F7)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _filters.isActive
                          ? AppColors.primary
                          : Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: _filters.isActive
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filtrar',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _filters.isActive
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ItineraryList(
            items: widget.items,
            travelTimes: widget.travelTimes,
            selectedDate: _selectedDate,
            filters: _filters,
          ),
        ),
      ],
    );
  }
}
