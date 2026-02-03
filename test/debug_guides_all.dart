import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';

void main() {
  test('List All Groups', () async {
    final client = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.anonKey,
    );

    print('\n--- LISTANDO TODOS OS GRUPOS ---');

    final groupsRes = await client.from('grupos').select('id, nome');

    print('Total de grupos: ${(groupsRes as List).length}');
    for (var g in groupsRes) {
      print('Grupo: "${g['nome']}" (ID: ${g['id']})');

      if ((g['nome'] as String).toLowerCase().contains('aprosoja')) {
        print('   -> MATCHED APROSOJA MANUALLY');

        // Fetch participants for this match
        final participantsRes = await client
            .from('gruposParticipantes')
            .select('user_id')
            .eq('grupo_id', g['id']);

        final participantIds = (participantsRes as List)
            .map((e) => e['user_id'])
            .toList();

        if (participantIds.isNotEmpty) {
          final usersRes = await client
              .from('users')
              .select('nome, email, tipouser')
              .inFilter('id', participantIds);

          for (var u in (usersRes as List)) {
            final roles = u['tipouser'].toString().toUpperCase();
            if (roles.contains('GUIA')) {
              print('      >>> GUIA: ${u['nome']} (${u['email']})');
            } else {
              print(
                '      - User: ${u['nome']} (${u['email']}) - Role: $roles',
              );
            }
          }
        } else {
          print('      - Sem participantes.');
        }
      }
    }
  });
}
