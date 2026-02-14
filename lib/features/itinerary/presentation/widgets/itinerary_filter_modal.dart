import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';
import '../../domain/entities/itinerary_item.dart';

class ItineraryFilters {
  final Set<ItineraryType> types;
  final DateTime? date;
  final TimeOfDay? startTime;

  const ItineraryFilters({this.types = const {}, this.date, this.startTime});

  bool get isActive => types.isNotEmpty || date != null || startTime != null;

  int get count =>
      types.length + (date != null ? 1 : 0) + (startTime != null ? 1 : 0);

  ItineraryFilters copyWith({
    Set<ItineraryType>? types,
    DateTime? date,
    TimeOfDay? startTime,
    bool clearDate = false,
    bool clearTime = false,
  }) {
    return ItineraryFilters(
      types: types ?? this.types,
      date: clearDate ? null : (date ?? this.date),
      startTime: clearTime ? null : (startTime ?? this.startTime),
    );
  }
}

class ItineraryFilterModal extends StatefulWidget {
  final ItineraryFilters initialFilters;
  final List<DateTime> availableDates;

  const ItineraryFilterModal({
    super.key,
    required this.initialFilters,
    required this.availableDates,
  });

  @override
  State<ItineraryFilterModal> createState() => _ItineraryFilterModalState();
}

class _ItineraryFilterModalState extends State<ItineraryFilterModal> {
  late Set<ItineraryType> _selectedTypes;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.initialFilters.types);
    _selectedDate = widget.initialFilters.date;
    _selectedTime = widget.initialFilters.startTime;
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
                'Filtros',
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
            'Tipo de evento',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItineraryType.values
                .where((t) => t != ItineraryType.other)
                .map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return FilterChip(
                    selected: isSelected,
                    avatar: Icon(
                      _getTypeIcon(type),
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    label: Text(_getTypeLabel(type)),
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
                            : Theme.of(context).dividerColor.withOpacity(0.1),
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
                      'Data',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickDate,
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
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!)
                                  : 'Selecionar',
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
                      'Hora início',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickTime,
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
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Selecionar',
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
                    setState(() {
                      _selectedTypes = {};
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Limpar',
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
                    Navigator.pop(
                      context,
                      ItineraryFilters(
                        types: _selectedTypes,
                        date: _selectedDate,
                        startTime: _selectedTime,
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
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(
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
        return Icons.restaurant;
      case ItineraryType.leisure:
        return Icons.pool; // or local_play
      case ItineraryType.transfer:
        return Icons.directions_bus;
      case ItineraryType.returnType:
        return Icons.swap_horiz_rounded;
      default:
        return Icons.event;
    }
  }

  String _getTypeLabel(ItineraryType type) {
    switch (type) {
      case ItineraryType.flight:
        return 'Voo';
      case ItineraryType.visit:
        return 'Visita';
      case ItineraryType.hotel:
        return 'Hotel';
      case ItineraryType.food:
        return 'Alimentação';
      case ItineraryType.leisure:
        return 'Lazer';
      case ItineraryType.transfer:
        return 'Transfer';
      case ItineraryType.returnType:
        return 'Retorno';
      default:
        return 'Outro';
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.availableDates.first,
      firstDate: widget.availableDates.first,
      lastDate: widget.availableDates.last,
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
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }
}
