import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/components/full_screen_image_viewer.dart';
import 'package:swipe_to/swipe_to.dart';

enum ChatBubbleType { me, other, guide }

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final ChatBubbleType type;
  final String? userName;
  final String? userAvatarUrl;
  final String? guideRole;
  final String? attachmentUrl;
  final bool isGroupChat;
  final bool showAvatar;
  final bool isSelected;
  final bool isEdited;
  final bool isDeleted;
  final VoidCallback? onReply;
  final String? repliedMessage;
  final String? repliedUserName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.type,
    this.userName,
    this.userAvatarUrl,
    this.guideRole,
    this.attachmentUrl,
    this.isGroupChat = true,
    this.showAvatar = true,
    this.isEdited = false,
    this.isDeleted = false,
    this.isSelected = false,
    this.onReply,
    this.repliedMessage,
    this.repliedUserName,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
    this.onTap,
  });

  bool get isMe => type == ChatBubbleType.me;

  @override
  Widget build(BuildContext context) {
    // Coloring Logic:
    // Me = Green (0xFF00AA6C)
    // Others = White

    final bool useGreen = isMe;

    final bgColor = useGreen
        ? const Color(0xFF00AA6C)
        : Theme.of(context).colorScheme.surface;
    final textColor = useGreen
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    final align = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
      topRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    return SwipeTo(
      onRightSwipe: (details) => onReply?.call(),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Container(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: align,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 10),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              if (!isMe && showAvatar) ...[
                _buildAvatarWidget(context),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.2
                                    : 0.05,
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDeleted)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.block,
                                      size: 16,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mensagem apagada',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: textColor.withOpacity(0.5),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    0,
                                  ),
                                  child: _buildHeader(),
                                ),
                              if (attachmentUrl != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    4,
                                    4,
                                    4,
                                    0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      FullScreenImageViewer.show(
                                        context,
                                        attachmentUrl!,
                                      );
                                    },
                                    child: Hero(
                                      tag: attachmentUrl!,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: attachmentUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                          placeholder: (context, url) => Container(
                                            height: 200,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[800]
                                                : Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.primary),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (repliedMessage != null)
                                GestureDetector(
                                  onTap: () {
                                    // Scroll to original message would be cool here
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                      10,
                                      10,
                                      10,
                                      0,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          (isMe
                                                  ? Colors.white
                                                  : Theme.of(
                                                      context,
                                                    ).dividerColor)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border(
                                        left: BorderSide(
                                          color: isMe
                                              ? Colors.white
                                              : const Color(0xFF00AA6C),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          repliedUserName ?? 'Usuário',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: isMe
                                                    ? Colors.white
                                                    : const Color(0xFF00AA6C),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          repliedMessage!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: textColor.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (message.isNotEmpty)
                                if (message.isNotEmpty)
                                  Builder(
                                    builder: (context) {
                                      final isLong =
                                          message.length >
                                          200; // Increased threshold slightly
                                      if (isLong) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            12,
                                            6,
                                            6,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                child: _buildMessageText(
                                                  textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              _buildTimeRow(textColor),
                                            ],
                                          ),
                                        );
                                      }

                                      // Compact layout for shorter messages
                                      // Estimated width for time (~6 chars 12px) and editing
                                      final timeWidth =
                                          (isEdited ? 45.0 : 0.0) + 40.0;

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          10,
                                          6,
                                          4,
                                        ),
                                        child: Stack(
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      color: textColor,
                                                      fontSize: 16,
                                                    ),
                                                children: [
                                                  TextSpan(text: message),
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: SizedBox(
                                                      width: timeWidth,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: _buildTimeRow(textColor),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else if (attachmentUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      4,
                                      12,
                                      8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          time,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: textColor.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar mensagem'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Excluir mensagem',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageText(Color color) {
    // Simple "Ver mais" simulation
    final isLong = message.length > 150;
    if (isLong) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${message.substring(0, 150)}...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ver mais...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    return Text(
      message,
      style: AppTextStyles.bodyMedium.copyWith(color: color, fontSize: 16),
    );
  }

  Widget _buildAvatarWidget(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: userAvatarUrl != null
          ? Image.network(
              userAvatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
            )
          : Icon(
              Icons.person,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            userName ?? 'Usuário',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getUserColor(userName ?? 'Usuário'),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (type == ChatBubbleType.guide && guideRole != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00AA6C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              guideRole!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeRow(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEdited) ...[
          Text(
            'editado',
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor.withOpacity(0.5),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getUserColor(String name) {
    if (name.isEmpty) return const Color(0xFF00AA6C);

    final colors = [
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFF57C00),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
    ];

    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }
}
