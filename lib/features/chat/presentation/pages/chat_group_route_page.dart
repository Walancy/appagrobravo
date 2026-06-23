import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

/// Wrapper page that resolves group data from Supabase and opens [ChatDetailPage].
/// Used by GoRouter to enable deep linking to group chats via `/chat-group/:id`.
/// The id may be either `batePapo.id` or `grupos.id` for backward compatibility.
class ChatGroupRoutePage extends StatefulWidget {
  final String groupId;

  const ChatGroupRoutePage({super.key, required this.groupId});

  @override
  State<ChatGroupRoutePage> createState() => _ChatGroupRoutePageState();
}

class _ChatGroupRoutePageState extends State<ChatGroupRoutePage> {
  ChatEntity? _chat;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      final supabase = Supabase.instance.client;
      String resolvedGroupId = widget.groupId;

      final chatRow = await supabase
          .from('batePapo')
          .select('grupo_id')
          .eq('id', widget.groupId)
          .maybeSingle();

      final chatGroupId = chatRow?['grupo_id'] as String?;
      if (chatGroupId != null && chatGroupId.isNotEmpty) {
        resolvedGroupId = chatGroupId;
      }

      // Fetch group info
      final groupRow = await supabase
          .from('grupos')
          .select('id, nome, logo')
          .eq('id', resolvedGroupId)
          .maybeSingle();

      if (groupRow == null) {
        if (mounted) {
          setState(() {
            _error = 'Grupo não encontrado';
            _loading = false;
          });
        }
        return;
      }

      // Count members
      final membersResp = await supabase
          .from('gruposParticipantes')
          .select('user_id')
          .eq('grupo_id', resolvedGroupId);
      final memberCount = (membersResp as List).length;

      final chat = ChatEntity(
        id: groupRow['id'] as String,
        title: (groupRow['nome'] as String?) ?? 'Grupo',
        subtitle: '$memberCount participantes',
        imageUrl: groupRow['logo'] as String?,
        memberCount: memberCount,
      );

      if (mounted) {
        setState(() {
          _chat = chat;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar grupo: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _chat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(child: Text(_error ?? 'Erro desconhecido')),
      );
    }

    return ChatDetailPage(chat: _chat!);
  }
}
