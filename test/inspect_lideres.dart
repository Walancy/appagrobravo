import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';

void main() {
  test('Inspect lideresGrupo table', () async {
    final client = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.anonKey,
    );

    print('\n--- INSPECTING lideresGrupo ---');

    try {
      final res = await client.from('lideresGrupo').select().limit(5);
      print('Amostra de dados: $res');
      if ((res as List).isNotEmpty) {
        print('Colunas detectadas: ${(res.first as Map).keys}');
      } else {
        print('Tabela vazia ou sem acesso.');
      }
    } catch (e) {
      print('Erro ao acessar tabela: $e');
    }
  });
}
