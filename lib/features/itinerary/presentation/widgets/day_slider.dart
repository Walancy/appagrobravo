import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

class DaySlider extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DaySlider({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DaySlider> createState() => _DaySliderState();
}

class _DaySliderState extends State<DaySlider> {
  late final ScrollController _scrollController;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _days = _getDaysInBetween(widget.startDate, widget.endDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(DaySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // BUG-012: recalculate _days when group dates change (e.g. after pull-to-refresh)
    if (widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      setState(() {
        _days = _getDaysInBetween(widget.startDate, widget.endDate);
      });
    }
    if (widget.selectedDate != oldWidget.selectedDate) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (widget.selectedDate == null || !mounted) return;

    final index = _days.indexWhere(
      (d) => Utils.isSameDay(d, widget.selectedDate!),
    );
    if (index != -1) {
      // 44 is width, 10 is separator
      double offset = index * (44.0 + 10.0);

      if (_scrollController.hasClients) {
        final viewportWidth = _scrollController.position.viewportDimension;
        final itemCenter = offset + (44.0 / 2);
        offset = itemCenter - (viewportWidth / 2);

        if (offset < _scrollController.position.minScrollExtent) {
          offset = _scrollController.position.minScrollExtent;
        } else if (offset > _scrollController.position.maxScrollExtent) {
          offset = _scrollController.position.maxScrollExtent;
        }
      }

      // Calculate center if possible, but simple scroll is usually fine
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<DateTime> _getDaysInBetween(DateTime start, DateTime end) {
    if (end.isBefore(start)) return [start];
    return List.generate(
      end.difference(start).inDays + 1,
      (i) => start.add(Duration(days: i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = _days[index];
          final dayDate = DateTime(date.year, date.month, date.day);
          final isSelected =
              widget.selectedDate != null &&
              Utils.isSameDay(widget.selectedDate!, date);

          final isPast = dayDate.isBefore(today);

          Color backgroundColor;
          if (isSelected) {
            backgroundColor = AppColors.primary;
          } else {
            if (Theme.of(context).brightness == Brightness.dark) {
              backgroundColor = const Color(0xFF1E1E1E);
            } else {
              backgroundColor = const Color(0xFFF2F4F7);
            }
            if (isPast) {
              backgroundColor = backgroundColor.withOpacity(0.5);
            }
          }

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat(
                      'E',
                      Localizations.localeOf(context).languageCode == 'pt' ? 'pt_BR'
                          : Localizations.localeOf(context).languageCode == 'es' ? 'es_ES'
                          : 'en_US',
                    ).format(date).replaceAll('.', '').capitalize(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: isPast ? 0.3 : 0.6,
                            ),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: isPast ? 0.4 : 1.0,
                            ),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Utils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
