import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import '../../../../core/tokens/app_text_styles.dart';
import '../cubit/itinerary_cubit.dart';
import '../widgets/day_slider.dart';
import '../widgets/itinerary_list.dart';
import '../widgets/itinerary_filter_modal.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/itinerary_shimmer.dart';

/// Standalone Widget to be used as a Tab
class ItineraryTab extends StatelessWidget {
  const ItineraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ItineraryCubit>()..loadUserItinerary(),
      child: Scaffold(
        // Inner scaffold to handle background and body
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<ItineraryCubit, ItineraryState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const ItineraryShimmer(),
              error: (msg) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Erro: $msg', textAlign: TextAlign.center),
                ),
              ),
              loaded: (group, items, travelTimes, pendingDocs) {
                return ItineraryContent(
                  group: group,
                  items: items,
                  travelTimes: travelTimes,
                  pendingDocs: pendingDocs,
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

class ItineraryContent extends StatefulWidget {
  final ItineraryGroupEntity group;
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;

  final List<String> pendingDocs;

  const ItineraryContent({
    super.key,
    required this.group,
    required this.items,
    required this.travelTimes,
    required this.pendingDocs,
  });

  @override
  State<ItineraryContent> createState() => _ItineraryContentState();
}

class _ItineraryContentState extends State<ItineraryContent> {
  DateTime? _selectedDate;
  ItineraryFilters _filters = const ItineraryFilters();

  @override
  void initState() {
    super.initState();
    // Default to first day if valid range
    if (widget.group.startDate.year > 0) {
      _selectedDate = widget.group.startDate;
    }
  }

  void _showFilterModal() async {
    // Generate dates between start and end
    final availableDates = List.generate(
      widget.group.endDate.difference(widget.group.startDate).inDays + 1,
      (i) => widget.group.startDate.add(Duration(days: i)),
    );

    final result = await showDialog<ItineraryFilters>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ItineraryFilterModal(
          initialFilters: _filters,
          availableDates: availableDates,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _filters = result;
        if (result.date != null) {
          _selectedDate = result.date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // Light grey background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderSpacer(),
          const SizedBox(height: 10),

          // "Termina em X dias"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Termina em 7 dias', // Dynamic in future
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Day Slider
          DaySlider(
            startDate: widget.group.startDate,
            endDate: widget.group.endDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                // If filter had a different date, we clear it or sync it
                if (_filters.date != null &&
                    !_isSameDay(_filters.date!, date)) {
                  _filters = _filters.copyWith(date: date);
                }
              });
            },
          ),

          const SizedBox(height: 16),

          // Filter Bar
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
                        : AppColors.textSecondary,
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
                      vertical: 10, // Increased for better tap area
                    ),
                    decoration: BoxDecoration(
                      color: _filters.isActive
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _filters.isActive
                            ? AppColors.primary
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: _filters.isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtrar',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _filters.isActive
                                ? AppColors.primary
                                : AppColors.textPrimary,
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

          // List
          Expanded(
            child: ItineraryList(
              items: widget.items,
              travelTimes: widget.travelTimes,
              selectedDate: _selectedDate,
              filters: _filters,
              pendingDocs: widget.pendingDocs,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
