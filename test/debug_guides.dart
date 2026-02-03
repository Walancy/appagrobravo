import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';

void main() {
  test('Find Guides for Aprosoja Group', () async {
    final client = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.anonKey,
    );

    print('\n--- BUSCANDO GRUPO APROSOJA ---');

    // 1. Find Groups
    // Note: 'ilike' might not be available in simple client select if not using filter modifiers correctly or if RLS restricts.
    // simpler to fetch all or use textSearch if column is indexed, but let's try ilike logic or just fetch all and filter in dart for this debug script since dataset is small.
    // Actually, let's try `.ilike('nome', '%aprosoja%')`

    final groupsRes = await client
        .from('grupos')
        .select('id, nome')
        .ilike('nome', '%aprosoja%');

    print('Grupos Encontrados: $groupsRes');

    if ((groupsRes as List).isEmpty) {
      print('Nenhum grupo com "aprosoja" no nome encontrado.');
      return;
    }

    for (var g in groupsRes) {
      print('\nAnalizando Grupo: ${g['nome']} (ID: ${g['id']})');

      // 2. Fetch Participants
      final participantsRes = await client
          .from('gruposParticipantes')
          .select('user_id')
          .eq('grupo_id', g['id']);

      final participantIds = (participantsRes as List)
          .map((e) => e['user_id'])
          .toList();

      if (participantIds.isEmpty) {
        print('   - Sem participantes.');
        continue;
      }

      // 3. Fetch User Details to check for GUIDES
      final usersRes = await client
          .from('users')
          .select('nome, email, tipouser')
          .inFilter('id', participantIds);

      print('   - Total de participantes: ${usersRes.length}');

      bool guideFound = false;
      for (var u in (usersRes as List)) {
        final roles = u['tipouser'].toString().toUpperCase();
        if (roles.contains('GUIA')) {
          print('   >>> GUIA: ${u['nome']} (${u['email']})');
          guideFound = true;
        }
      }
      if (!guideFound) {
        print('   - Nenhum guia encontrado neste grupo.');
      }
    }
  });
}
