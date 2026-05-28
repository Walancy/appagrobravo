import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/l10n/generated/app_localizations.dart';

class ItineraryFilters {
  final Set<ItineraryType> types;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const ItineraryFilters({this.types = const {}, this.startTime, this.endTime});

  bool get isActive => types.isNotEmpty || startTime != null || endTime != null;

  int get count =>
      types.length + (startTime != null ? 1 : 0) + (endTime != null ? 1 : 0);

  ItineraryFilters copyWith({
    Set<ItineraryType>? types,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return ItineraryFilters(
      types: types ?? this.types,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
}

class ItineraryFilterModal extends StatefulWidget {
  final ItineraryFilters initialFilters;

  const ItineraryFilterModal({
    super.key,
    required this.initialFilters,
  });

  @override
  State<ItineraryFilterModal> createState() => _ItineraryFilterModalState();
}

class _ItineraryFilterModalState extends State<ItineraryFilterModal> {
  late Set<ItineraryType> _selectedTypes;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.initialFilters.types);
    _selectedStartTime = widget.initialFilters.startTime;
    _selectedEndTime = widget.initialFilters.endTime;
  }

  void _toggleType(ItineraryType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.itineraryFiltersTitle,
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            context.l10n.itineraryFilterEventType,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ItineraryType.flight,
              ItineraryType.connection,
              ItineraryType.disembark,
              ItineraryType.hotel,
              ItineraryType.checkin,
              ItineraryType.checkout,
              ItineraryType.food,
              ItineraryType.leisure,
              ItineraryType.visit,
              ItineraryType.returnType,
              ItineraryType.transfer,
            ].map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return FilterChip(
                    selected: isSelected,
                    avatar: Icon(
                      _getTypeIcon(type),
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    label: Text(_getTypeLabel(context.l10n, type)),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => _toggleType(type),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  );
                })
                .toList(),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.itineraryFilterStartTime,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _pickTime(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedStartTime != null
                                  ? _selectedStartTime!.format(context)
                                  : context.l10n.itineraryFilterSelectTime,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.itineraryFilterEndTime,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _pickTime(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedEndTime != null
                                  ? _selectedEndTime!.format(context)
                                  : context.l10n.itineraryFilterSelectTime,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      const ItineraryFilters(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.itineraryFilterClear,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // BUG-004: Validate that endTime is not before startTime
                    if (_selectedStartTime != null && _selectedEndTime != null) {
                      final startMin = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
                      final endMin = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
                      if (endMin <= startMin) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.itineraryFilterEndBeforeStart),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                    }
                    Navigator.pop(
                      context,
                      ItineraryFilters(
                        types: _selectedTypes,
                        startTime: _selectedStartTime,
                        endTime: _selectedEndTime,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.itineraryFilterApply,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ItineraryType type) {
    switch (type) {
      case ItineraryType.flight:
        return Icons.flight;
      case ItineraryType.visit:
        return Icons.location_on;
      case ItineraryType.hotel:
        return Icons.hotel;
      case ItineraryType.food:
      case ItineraryType.meal:
        return Icons.restaurant;
      case ItineraryType.leisure:
        return Icons.pool; // or local_play
      case ItineraryType.transfer:
        return Icons.directions_bus;
      case ItineraryType.returnType:
        return Icons.swap_horiz_rounded;
      case ItineraryType.checkin:
        return Icons.login;
      case ItineraryType.checkout:
        return Icons.logout;
      case ItineraryType.disembark:
        return Icons.flight_land;
      case ItineraryType.connection:
        return Icons.sync_alt;
      case ItineraryType.aiRecommendation:
        return Icons.auto_awesome;
      default:
        return Icons.event;
    }
  }

  String _getTypeLabel(AppLocalizations l10n, ItineraryType type) {
    switch (type) {
      case ItineraryType.flight:
        return l10n.itineraryTypeFlight;
      case ItineraryType.visit:
        return l10n.itineraryTypeVisit;
      case ItineraryType.hotel:
        return l10n.itineraryTypeHotel;
      case ItineraryType.food:
        return l10n.itineraryTypeFood;
      case ItineraryType.meal:
        return l10n.itineraryTypeMeal;
      case ItineraryType.leisure:
        return l10n.itineraryTypeLeisure;
      case ItineraryType.transfer:
        return l10n.itineraryTypeTransfer;
      case ItineraryType.returnType:
        return l10n.itineraryTypeReturn;
      case ItineraryType.checkin:
        return l10n.itineraryTypeCheckin;
      case ItineraryType.checkout:
        return l10n.itineraryTypeCheckout;
      case ItineraryType.disembark:
        return l10n.itineraryTypeDisembark;
      case ItineraryType.connection:
        return l10n.itineraryTypeConnection;
      case ItineraryType.aiRecommendation:
        return l10n.itineraryTypeAiRecommendation;
      default:
        return l10n.itineraryTypeOther;
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initialTime = isStart
        ? (_selectedStartTime ?? TimeOfDay.now())
        : (_selectedEndTime ?? TimeOfDay.now());

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    // BUG-004: Validate that endTime > startTime immediately on pick
    if (!isStart && _selectedStartTime != null) {
      final startMin = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
      final endMin = time.hour * 60 + time.minute;
      if (endMin <= startMin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.itineraryFilterEndBeforeStart),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    if (isStart && _selectedEndTime != null) {
      final startMin = time.hour * 60 + time.minute;
      final endMin = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
      if (startMin >= endMin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.itineraryFilterStartAfterEnd),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      if (isStart) {
        _selectedStartTime = time;
      } else {
        _selectedEndTime = time;
      }
    });
  }
}
