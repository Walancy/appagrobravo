import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/day_slider.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_list.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_filter_modal.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/itinerary_shimmer.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_data_page.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/mission_header_card.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/documents/presentation/widgets/pending_documents_banner.dart';
import 'package:agrobravo/features/profile/presentation/widgets/incomplete_profile_banner.dart';

/// Standalone Widget to be used as a Tab
class ItineraryTab extends StatelessWidget {
  const ItineraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Inner scaffold to handle background and body
      body: BlocBuilder<ItineraryCubit, ItineraryState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const ItineraryShimmer(),
            error: (msg) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${context.l10n.itineraryErrorPrefix}$msg', textAlign: TextAlign.center),
              ),
            ),
            loaded: (group, items, travelTimes, pendingDocs) {
              // BUG-013: use private _ItineraryContent to enforce BlocProvider requirement
              return _ItineraryContent(
                group: group,
                items: items,
                travelTimes: travelTimes,
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// BUG-013: private widget — must only be instantiated inside ItineraryTab
// which provides the required BlocProvider<ItineraryCubit>.
class _ItineraryContent extends StatefulWidget {
  final ItineraryGroupEntity group;
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;

  const _ItineraryContent({
    super.key,
    required this.group,
    required this.items,
    required this.travelTimes,
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
    // BUG-018: removed duplicate/contradicting comment. Default to today if in range,
    // otherwise default to the group start date.
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
    // Normalize _selectedDate to start of day
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
        child: ItineraryFilterModal(
          initialFilters: _filters,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Standardised background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderSpacer(),
          const SizedBox(height: 16),

          // Banners (if any)
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final isComplete = profileState.maybeMap(
                loaded: (s) => s.profile.isComplete,
                orElse: () => true,
              );
              if (isComplete) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: IncompleteProfileBanner(),
                ),
              );
            },
          ),
          
          BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, documentsState) {
              if (!documentsState.hasPendingAction) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: PendingDocumentsBanner(),
                ),
              );
            },
          ),

          // Mission Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MissionHeaderCard(
              missionName: widget.group.missionName ?? context.l10n.itineraryCurrentMission,
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
          const SizedBox(height: 12),

          // Day Slider
          DaySlider(
            startDate: widget.group.startDate,
            endDate: widget.group.endDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                // Normalize selected date from slider
                _selectedDate = DateTime(date.year, date.month, date.day);
              });
            },
          ),

          const SizedBox(height: 10),

          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filters.isActive
                      ? context.l10n.itineraryFiltersActive(_filters.count)
                      : context.l10n.itineraryFiltersNone,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _filters.isActive
                        ? AppColors.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.itineraryFilterButton,
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

          // List
          Expanded(
            child: ItineraryList(
              items: widget.items,
              travelTimes: widget.travelTimes,
              selectedDate: _selectedDate,
              filters: _filters,
            ),
          ),
        ],
      ),
    );
  }
  // BUG-010: removed dead method _isSameDay — was never called in this class.
  // Use Utils.isSameDay from day_slider.dart if needed.
}
