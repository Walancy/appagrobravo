import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';

class DaySlider extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final days = _getDaysInBetween(startDate, endDate);

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected =
              selectedDate != null && Utils.isSameDay(selectedDate!, date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Theme.of(context).colorScheme.surface),
                borderRadius: BorderRadius.circular(15),
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
                      'pt_BR',
                    ).format(date).replaceAll('.', '').capitalize(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  List<DateTime> _getDaysInBetween(DateTime start, DateTime end) {
    if (end.isBefore(start)) return [start];
    return List.generate(
      end.difference(start).inDays + 1,
      (i) => start.add(Duration(days: i)),
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
