import 'package:flutter/material.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';

class TravelGuidePage extends StatelessWidget {
  final ItineraryGroupEntity group;

  const TravelGuidePage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // Mocked data for travel guide
    final List<Map<String, dynamic>> mockGuideItems = [
      {
        'icon': Icons.flight_takeoff_rounded,
        'title': 'Regras de Bagagem',
        'content': '• Não leve **aerossóis** ou **objetos cortantes** na mala de mão.\n'
            '• Líquidos devem ter no máximo **100ml**.\n'
            '• **Identifique bem** todas as suas bagagens.'
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Ponto de Encontro',
        'content': 'Fique atento aos horários divulgados. Nosso ponto de encontro principal será sempre no **lobby do hotel** com pelo menos **15 minutos de antecedência** de cada saída.'
      },
    ];

    Widget buildRichText(String text, BuildContext context) {
      final style = AppTextStyles.bodyMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.5,
      );
      final boldStyle = style.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

      final spans = <TextSpan>[];
      final parts = text.split('**');
      for (int i = 0; i < parts.length; i++) {
        spans.add(TextSpan(
          text: parts[i],
          style: i % 2 == 1 ? boldStyle : style,
        ));
      }

      return RichText(
        text: TextSpan(children: spans),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.back,
            title: context.l10n.itineraryTravelGuide,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: mockGuideItems.length,
              itemBuilder: (context, index) {
                final item = mockGuideItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item['icon'],
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['title'],
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buildRichText(item['content'], context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
