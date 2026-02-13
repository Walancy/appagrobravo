import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_cubit.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_state.dart';
import 'package:agrobravo/features/chat/presentation/pages/group_info_page.dart';
import 'package:agrobravo/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:agrobravo/features/chat/presentation/widgets/chat_input.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatelessWidget {
  final ChatEntity chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // Using manual instantiation as fallback since build_runner failed
    return BlocProvider(
      create: (_) =>
          getIt<ChatDetailCubit>()..loadMessages(chat.id, isGroup: true),
      child: _ChatDetailView(chat: chat),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final ChatEntity chat;

  const _ChatDetailView({required this.chat});

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showScrollToBottom = false;
  String? _editingMessageId;
  final Set<String> _selectedMessageIds = {};
  MessageEntity? _replyingToMessage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: widget.chat.title,
        subtitle: widget.chat.subtitle,
        // Using logo param to show group image, similar to home showing app logo
        logo: ClipOval(
          child: widget.chat.imageUrl != null
              ? Image.network(
                  widget.chat.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
                )
              : _buildPlaceholderAvatar(),
        ),
        onTitleTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GroupInfoPage(chat: widget.chat),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.chatBackground,
          image: DecorationImage(
            image: const AssetImage('assets/images/chat_pattern.png'),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(
                0.0,
              ), // No opacity needed if image is already good, or adjust
              BlendMode.dstATop,
            ),
            opacity: 0.1, // Keep subtle overlay
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
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedMessageIds.length} selecionada(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
                      icon: const Icon(Icons.close),
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
                          // Auto scroll to bottom on new message or list changes if close to bottom
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

                              bool showDateHeader = false;
                              if (index == 0) {
                                showDateHeader = true;
                              } else {
                                final prevMsg = messages[index - 1];
                                final currentDate = DateTime(
                                  msg.timestamp.year,
                                  msg.timestamp.month,
                                  msg.timestamp.day,
                                );
                                final prevDate = DateTime(
                                  prevMsg.timestamp.year,
                                  prevMsg.timestamp.month,
                                  prevMsg.timestamp.day,
                                );
                                if (currentDate.isAfter(prevDate)) {
                                  showDateHeader = true;
                                }
                              }

                              return Column(
                                children: [
                                  if (showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _formatDateHeader(msg.timestamp),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ChatBubble(
                                    message: msg.text,
                                    time:
                                        '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    type: _mapMessageType(msg.type),
                                    userName: msg.userName,
                                    userAvatarUrl: msg.userAvatarUrl,
                                    guideRole: msg.guideRole,
                                    attachmentUrl: msg.attachmentUrl,
                                    isEdited: msg.isEdited,
                                    isDeleted: msg.isDeleted,
                                    isSelected: isSelected,
                                    repliedMessage: msg.repliedToMessage?.text,
                                    repliedUserName:
                                        msg.repliedToMessage?.userName,
                                    onReply: () {
                                      setState(() {
                                        _replyingToMessage = msg;
                                        _editingMessageId = null;
                                      });
                                    },
                                    onLongPress:
                                        msg.type == MessageType.me &&
                                            !msg.isDeleted
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
                                                _selectedMessageIds.remove(
                                                  msg.id,
                                                );
                                              } else {
                                                _selectedMessageIds.add(msg.id);
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                ],
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
              repliedMessage: _replyingToMessage?.text,
              repliedUserName: _replyingToMessage?.userName,
              onCancelReply: () {
                setState(() {
                  _replyingToMessage = null;
                });
              },
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
                  context.read<ChatDetailCubit>().sendMessage(
                    text,
                    replyToId: _replyingToMessage?.id,
                  );
                  setState(() {
                    _replyingToMessage = null;
                  });
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

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hoje';
    } else if (messageDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 40,
      height: 40,
      color: Colors.grey.shade200,
      child: const Icon(Icons.group, color: Colors.grey),
    );
  }
}
