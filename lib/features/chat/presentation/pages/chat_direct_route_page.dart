import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/presentation/pages/individual_chat_page.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

/// Wrapper page that resolves guide/user data from Supabase and opens [IndividualChatPage].
/// Used by GoRouter to enable deep linking to direct chats via `/chat-direct/:id`.
/// The id may be either `batePapo.id` or `users.id` for backward compatibility.
class ChatDirectRoutePage extends StatefulWidget {
  final String guideId;

  const ChatDirectRoutePage({super.key, required this.guideId});

  @override
  State<ChatDirectRoutePage> createState() => _ChatDirectRoutePageState();
}

class _ChatDirectRoutePageState extends State<ChatDirectRoutePage> {
  GuideEntity? _guide;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGuideData();
  }

  Future<void> _loadGuideData() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      String resolvedGuideId = widget.guideId;

      final chatRow = await supabase
          .from('batePapo')
          .select('lider_id, user_id')
          .eq('id', widget.guideId)
          .maybeSingle();

      if (chatRow != null) {
        final leaderId = chatRow['lider_id'] as String?;
        final userId = chatRow['user_id'] as String?;
        if (currentUserId != null && leaderId == currentUserId && userId != null) {
          resolvedGuideId = userId;
        } else if (currentUserId != null && userId == currentUserId && leaderId != null) {
          resolvedGuideId = leaderId;
        } else {
          resolvedGuideId = leaderId ?? userId ?? widget.guideId;
        }
      }

      // Fetch user/guide info
      final userRow = await supabase
          .from('users')
          .select('id, nome, foto, cargo')
          .eq('id', resolvedGuideId)
          .maybeSingle();

      if (userRow == null) {
        if (mounted) {
          setState(() {
            _error = 'Usuário não encontrado';
            _loading = false;
          });
        }
        return;
      }

      final guide = GuideEntity(
        id: userRow['id'] as String,
        name: (userRow['nome'] as String?) ?? 'Usuário',
        role: (userRow['cargo'] as String?) ?? '',
        avatarUrl: userRow['foto'] as String?,
      );

      if (mounted) {
        setState(() {
          _guide = guide;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar contato: $e';
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

    if (_error != null || _guide == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(child: Text(_error ?? 'Erro desconhecido')),
      );
    }

    return IndividualChatPage(guide: _guide!);
  }
}
