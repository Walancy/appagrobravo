import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../cubit/itinerary_cubit.dart';
import '../widgets/day_slider.dart';
import '../widgets/itinerary_list.dart';

class ItineraryPage extends StatelessWidget {
  final String groupId;

  const ItineraryPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ItineraryCubit>()..loadItinerary(groupId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(child: Text('Erro: $msg')),
              loaded: (group, items) {
                return _ItineraryContent(group: group, items: items);
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

  const _ItineraryContent({required this.group, required this.items});

  @override
  State<_ItineraryContent> createState() => _ItineraryContentState();
}

class _ItineraryContentState extends State<_ItineraryContent> {
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
    return Column(
      children: [
        DaySlider(
          startDate: widget.group.startDate,
          endDate: widget.group.endDate,
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
          },
        ),
        Expanded(
          child: ItineraryList(
            items: widget.items,
            selectedDate: _selectedDate,
          ),
        ),
      ],
    );
  }
}
