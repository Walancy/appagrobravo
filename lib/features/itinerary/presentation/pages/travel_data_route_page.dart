import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/travel_data_page.dart';

/// Wrapper para a rota `/travel-data/:groupId`.
/// Busca os dados do grupo no Supabase e exibe [TravelDataPage].
class TravelDataRoutePage extends StatefulWidget {
  final String groupId;
  const TravelDataRoutePage({super.key, required this.groupId});

  @override
  State<TravelDataRoutePage> createState() => _TravelDataRoutePageState();
}

class _TravelDataRoutePageState extends State<TravelDataRoutePage> {
  ItineraryGroupEntity? _group;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    try {
      final row = await Supabase.instance.client
          .from('grupos')
          .select('id, nome, missao_id, data_inicio, data_fim, status, missoes(nome)')
          .eq('id', widget.groupId)
          .maybeSingle();

      if (row == null) {
        if (mounted) setState(() { _error = 'Grupo não encontrado'; _loading = false; });
        return;
      }

      final missao = row['missoes'] as Map<String, dynamic>?;
      final group = ItineraryGroupEntity(
        id: row['id'] as String,
        name: (row['nome'] as String?) ?? 'Grupo',
        missionName: missao?['nome'] as String?,
        startDate: DateTime.tryParse(row['data_inicio'] as String? ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(row['data_fim'] as String? ?? '') ?? DateTime.now(),
        status: row['status'] as String?,
      );

      if (mounted) setState(() { _group = group; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erro: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null || _group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dados da Viagem')),
        body: Center(child: Text(_error ?? 'Erro desconhecido')),
      );
    }
    return TravelDataPage(group: _group!);
  }
}
