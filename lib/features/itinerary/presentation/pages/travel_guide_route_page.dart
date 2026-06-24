import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_guide_page.dart';

/// Wrapper para a rota `/travel-guide/:groupId`.
/// Busca o nome do grupo e exibe [TravelGuidePage].
class TravelGuideRoutePage extends StatefulWidget {
  final String groupId;
  const TravelGuideRoutePage({super.key, required this.groupId});

  @override
  State<TravelGuideRoutePage> createState() => _TravelGuideRoutePageState();
}

class _TravelGuideRoutePageState extends State<TravelGuideRoutePage> {
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _loadGroupName();
  }

  Future<void> _loadGroupName() async {
    try {
      final row = await Supabase.instance.client
          .from('grupos')
          .select('nome')
          .eq('id', widget.groupId)
          .maybeSingle();
      if (mounted && row != null) {
        setState(() => _groupName = row['nome'] as String?);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return TravelGuidePage(
      groupId: widget.groupId,
      groupName: _groupName,
    );
  }
}
