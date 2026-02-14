import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_cubit.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_state.dart';
import 'package:agrobravo/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:agrobravo/features/chat/presentation/widgets/chat_input.dart';
import 'package:agrobravo/core/di/injection.dart';

class IndividualChatPage extends StatelessWidget {
  final GuideEntity guide;

  const IndividualChatPage({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    // Assuming we can load by guide ID
    return BlocProvider(
      create: (_) =>
          getIt<ChatDetailCubit>()..loadMessages(guide.id, isGroup: false),
      child: _IndividualChatView(guide: guide),
    );
  }
}

class _IndividualChatView extends StatefulWidget {
  final GuideEntity guide;

  const _IndividualChatView({required this.guide});

  @override
  State<_IndividualChatView> createState() => _IndividualChatViewState();
}

class _IndividualChatViewState extends State<_IndividualChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showScrollToBottom = false;
  String? _editingMessageId;
  final Set<String> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isAtBottom = maxScroll - currentScroll <= 200;

    if (isAtBottom && _showScrollToBottom) {
      setState(() => _showScrollToBottom = false);
    } else if (!isAtBottom && !_showScrollToBottom) {
      setState(() => _showScrollToBottom = true);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        context.read<ChatDetailCubit>().sendMessage('', image: image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao selecionar imagem')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.chatBackgroundDark
          : AppColors.chatBackground,
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: widget.guide.name,
        subtitle: widget.guide.role,
        logo: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            image: widget.guide.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(widget.guide.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.guide.avatarUrl == null
              ? Icon(
                  Icons.person,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                )
              : null,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.chatBackgroundDark
              : AppColors.chatBackground,
          image: DecorationImage(
            image: const AssetImage('assets/images/chat_pattern.png'),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.0),
              BlendMode.dstATop,
            ),
            opacity: Theme.of(context).brightness == Brightness.dark
                ? 0.05
                : 0.1,
          ),
        ),
        child: Column(
          children: [
            if (_selectedMessageIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedMessageIds.length} selecionada(s)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedMessageIds.length == 1)
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () {
                          context.read<ChatDetailCubit>().state.whenOrNull(
                            loaded: (messages) {
                              final msg = messages.firstWhere(
                                (m) => m.id == _selectedMessageIds.first,
                              );
                              setState(() {
                                _editingMessageId = msg.id;
                                _messageController.text = msg.text;
                                _selectedMessageIds.clear();
                              });
                            },
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<ChatDetailCubit>().deleteMessages(
                          _selectedMessageIds.toList(),
                        );
                        setState(() {
                          _selectedMessageIds.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedMessageIds.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  BlocConsumer<ChatDetailCubit, ChatDetailState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        loaded: (messages) {
                          if (!_showScrollToBottom) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _scrollToBottom();
                            });
                          }
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return state.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (msg) => Center(
                          child: Text(
                            'Erro: $msg',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        loaded: (messages) {
                          if (messages.isEmpty) {
                            return const Center(child: Text('Sem mensagens'));
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final isSelected = _selectedMessageIds.contains(
                                msg.id,
                              );
                              return ChatBubble(
                                message: msg.text,
                                time:
                                    '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                type: _mapMessageType(msg.type),
                                userName: msg.userName,
                                userAvatarUrl: msg.userAvatarUrl,
                                guideRole: msg.guideRole,
                                attachmentUrl: msg.attachmentUrl,
                                isGroupChat: false,
                                showAvatar: false,
                                isEdited: msg.isEdited,
                                isDeleted: msg.isDeleted,
                                isSelected: isSelected,
                                onLongPress:
                                    msg.type == MessageType.me && !msg.isDeleted
                                    ? () {
                                        setState(() {
                                          _selectedMessageIds.add(msg.id);
                                        });
                                      }
                                    : null,
                                onTap:
                                    _selectedMessageIds.isNotEmpty &&
                                        msg.type == MessageType.me &&
                                        !msg.isDeleted
                                    ? () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedMessageIds.remove(msg.id);
                                          } else {
                                            _selectedMessageIds.add(msg.id);
                                          }
                                        });
                                      }
                                    : null,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ChatInput(
              controller: _messageController,
              isEditing: _editingMessageId != null,
              onCancelEdit: () {
                setState(() {
                  _editingMessageId = null;
                });
              },
              onImagePicked: () => _pickImage(ImageSource.gallery),
              onCameraPicked: () => _pickImage(ImageSource.camera),
              onSendMessage: (text) {
                if (_editingMessageId != null) {
                  context.read<ChatDetailCubit>().editMessage(
                    _editingMessageId!,
                    text,
                  );
                  setState(() {
                    _editingMessageId = null;
                  });
                } else {
                  context.read<ChatDetailCubit>().sendMessage(text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  ChatBubbleType _mapMessageType(MessageType type) {
    switch (type) {
      case MessageType.me:
        return ChatBubbleType.me;
      case MessageType.other:
        return ChatBubbleType.other;
      case MessageType.guide:
        return ChatBubbleType.guide;
    }
  }
}
