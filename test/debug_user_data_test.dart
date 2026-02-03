import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';

void main() {
  test('Check User Data for Julia', () async {
    // Initialize Supabase
    // Note: In pure Dart tests without Flutter binding properly initialized for plugins,
    // some Supabase features (like deep linking or local storage) might fail or warn,
    // but REST calls usually work if using pure SupabaseClient.
    // We will use SupabaseClient directly to avoid Flutter plugins dependency if possible,
    // but the constants are there.

    final client = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.anonKey,
    );

    print('\n--- BUSCANDO DADOS ---');

    // 1. Find User
    final userRes = await client
        .from('users')
        .select()
        .eq('email', 'juliamartinez.ff@gmail.com');

    print('User Response: $userRes');

    if ((userRes as List).isEmpty) {
      print('Usuário não encontrado na tabela pública "users".');
      return;
    }

    final user = userRes.first;
    final userId = user['id'];
    print('User ID: $userId');
    print('User Name: ${user['nome']}');
    print('User Role: ${user['tipouser']}');

    // 2. Find Groups
    final groupsPartRes = await client
        .from('gruposParticipantes')
        .select('grupo_id')
        .eq('user_id', userId);

    print('Grupos Participantes: $groupsPartRes');

    final groupIds = (groupsPartRes as List).map((e) => e['grupo_id']).toList();

    if (groupIds.isEmpty) {
      print('Nenhum grupo encontrado.');
      return;
    }

    // 3. Group Details
    final groupsRes = await client
        .from('grupos')
        .select()
        .inFilter('id', groupIds);

    print('Detalhes dos Grupos: $groupsRes');

    for (var g in (groupsRes as List)) {
      print(
        '>>> Grupo: ${g['nome']} (ID: ${g['id']}) - Missão ID: ${g['missao_id']}',
      );

      // 4. Find Guides in this Group
      final participantsRes = await client
          .from('gruposParticipantes')
          .select('user_id')
          .eq('grupo_id', g['id']);

      final participantIds = (participantsRes as List)
          .map((e) => e['user_id'])
          .toList();

      final potentialGuides = await client
          .from('users')
          .select('nome, email, tipouser')
          .inFilter('id', participantIds);

      print('   Participantes do Grupo:');
      for (var p in (potentialGuides as List)) {
        final roles = p['tipouser'].toString().toUpperCase();
        if (roles.contains('GUIA')) {
          print('   *** GUIA ENCONTRADO: ${p['nome']} (${p['email']})');
        } else {
          // print('       Participante: ${p['nome']}');
        }
      }
    }
  });
}
