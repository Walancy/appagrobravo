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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Erro: $msg', textAlign: TextAlign.center),
                ),
              ),
              loaded: (group, items) {
                return ItineraryContent(group: group, items: items);
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

  const ItineraryContent({super.key, required this.group, required this.items});

  @override
  State<ItineraryContent> createState() => _ItineraryContentState();
}

class _ItineraryContentState extends State<ItineraryContent> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to first day if valid range
    if (widget.group.startDate.year > 0) {
      _selectedDate = widget.group.startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // Light grey background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spacer for header - reduced to bring content closer
          SizedBox(height: MediaQuery.of(context).padding.top + 20),

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
              setState(() => _selectedDate = date);
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
                  'Sem filtros aplicados',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filtrar',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
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
              selectedDate: _selectedDate,
            ),
          ),
        ],
      ),
    );
  }
}
