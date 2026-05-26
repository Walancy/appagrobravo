import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/components/full_screen_image_viewer.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool get _imageOnly => attachmentUrl != null && message.isEmpty && !isDeleted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isMe
        ? const Color(0xFF00AA6C)
        : (isDark
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Colors.white);

    final textColor = isMe
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    // "Tail" corner: sharp only on first message of a sequence (showAvatar=true)
    // isMe → tail at top-right; other → tail at top-left
    final tailRadius = showAvatar ? const Radius.circular(4) : const Radius.circular(16);
    final borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(16) : tailRadius,
      topRight: isMe ? tailRadius : const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    // Spacing: to visually align bubbles, add a placeholder on the opposite side
    // so the max-width constraint works symmetrically.
    final avatarPlaceholderWidth = (!isMe && showAvatar) ? 44.0 : 0.0;

    return SwipeTo(
      onRightSwipe: (details) => onReply?.call(),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          padding: EdgeInsets.only(
            top: showAvatar ? 6 : 2,
            bottom: 2,
            left: 12,
            right: 12,
          ),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Selection checkbox
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 8, bottom: 2),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),

              // Avatar (left side, other messages)
              if (!isMe) ...[
                SizedBox(
                  width: 36,
                  child: showAvatar
                      ? _buildAvatar(context)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
              ],

              // Bubble
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72 -
                        avatarPlaceholderWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: _imageOnly ? Colors.transparent : bgColor,
                          borderRadius: borderRadius,
                          boxShadow: _imageOnly
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.18 : 0.06,
                                    ),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: isDeleted
                            ? _buildDeletedBubble(textColor, borderRadius)
                            : _buildContent(context, bgColor, textColor, borderRadius, isDark),
                      ),
                    ],
                  ),
                ),
              ),

              // Spacer for my messages (mirror of avatar space on other side)
              if (isMe) const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedBubble(Color textColor, BorderRadius borderRadius) {
    return Container(
      decoration: BoxDecoration(borderRadius: borderRadius),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 15, color: textColor.withValues(alpha: 0.45)),
          const SizedBox(width: 6),
          Text(
            'Mensagem apagada',
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color bgColor,
    Color textColor,
    BorderRadius borderRadius,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sender name (group, other messages only)
        if (!isMe && isGroupChat && showAvatar)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: _buildHeader(),
          ),

        // Reply preview
        if (repliedMessage != null)
          _buildReplyPreview(context, textColor),

        // Attachment image
        if (attachmentUrl != null)
          _buildAttachment(context, borderRadius, textColor),

        // Message text
        if (message.isNotEmpty)
          _buildMessageText(context, textColor),

        // Time row for image-only (rendered inside the image, see _buildAttachment)
        // For text messages time is inline — handled inside _buildMessageText
      ],
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
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (type == ChatBubbleType.guide && guideRole != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00AA6C),
              borderRadius: BorderRadius.circular(10),
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

  Widget _buildReplyPreview(BuildContext context, Color textColor) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isMe ? Colors.white : Theme.of(context).dividerColor)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF00AA6C),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repliedUserName ?? 'Usuário',
              style: AppTextStyles.bodySmall.copyWith(
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
              style: AppTextStyles.bodySmall.copyWith(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(
    BuildContext context,
    BorderRadius borderRadius,
    Color textColor,
  ) {
    final imageWidget = GestureDetector(
      onTap: () => FullScreenImageViewer.show(context, attachmentUrl!),
      child: Hero(
        tag: attachmentUrl!,
        child: ClipRRect(
          borderRadius: message.isEmpty ? borderRadius : BorderRadius.zero,
          child: CachedNetworkImage(
            imageUrl: attachmentUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 220,
            placeholder: (context, url) => Container(
              height: 220,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            errorWidget: (_, __, e) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

    // Image-only: overlay timestamp on bottom-right of image
    if (_imageOnly) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: imageWidget,
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEdited) ...[
                    Text(
                      'editado  ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Image with caption: show image without corner rounding at bottom
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: imageWidget,
      ),
    );
  }

  Widget _buildMessageText(BuildContext context, Color textColor) {
    // Estimated width for time + "editado" label
    final timeWidth = (isEdited ? 46.0 : 0.0) + 36.0;
    final isLong = message.length > 180;

    if (isLong) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLinkifiedText(textColor),
            const SizedBox(height: 4),
            _buildTimeRow(textColor),
          ],
        ),
      );
    }

    // Short message: Stack trick so time sits at bottom-right inline
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        attachmentUrl != null ? 6 : 10,
        8,
        6,
      ),
      child: Stack(
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontSize: 15,
                height: 1.4,
              ),
              children: [
                ..._buildMessageSpans(textColor),
                WidgetSpan(
                  child: SizedBox(width: timeWidth + 4),
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
  }

  Widget _buildLinkifiedText(Color textColor) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontSize: 15,
          height: 1.4,
        ),
        children: _buildMessageSpans(textColor),
      ),
    );
  }

  List<InlineSpan> _buildMessageSpans(Color textColor) {
    final spans = <InlineSpan>[];
    final linkRegex = RegExp(
      r'((?:https?:\/\/|www\.)[^\s<>()]+)',
      caseSensitive: false,
    );
    var start = 0;

    for (final match in linkRegex.allMatches(message)) {
      if (match.start > start) {
        spans.add(TextSpan(text: message.substring(start, match.start)));
      }

      final rawUrl = match.group(0)!;
      final url = rawUrl.startsWith(
        RegExp(r'https?:\/\/', caseSensitive: false),
      )
          ? rawUrl
          : 'https://$rawUrl';

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              rawUrl,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.secondary,
                decoration: TextDecoration.underline,
                decorationColor: isMe ? Colors.white : AppColors.secondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      );

      start = match.end;
    }

    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start)));
    }

    return spans.isEmpty ? [TextSpan(text: message)] : spans;
  }

  Widget _buildTimeRow(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isEdited) ...[
          Text(
            'editado',
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor.withValues(alpha: 0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
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
          ? CachedNetworkImage(
              imageUrl: userAvatarUrl!,
              fit: BoxFit.cover,
              placeholder: (_, url) => Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300],
              ),
              errorWidget: (_, url, e) => Icon(
                Icons.person,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
                size: 20,
              ),
            )
          : Icon(
              Icons.person,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
              size: 20,
            ),
    );
  }

  Color _getUserColor(String name) {
    if (name.isEmpty) return const Color(0xFF00AA6C);
    const colors = [
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFF673AB7),
      Color(0xFF3F51B5),
      Color(0xFF2196F3),
      Color(0xFF00BCD4),
      Color(0xFF009688),
      Color(0xFF4CAF50),
      Color(0xFF8BC34A),
      Color(0xFFF57C00),
      Color(0xFFFF5722),
      Color(0xFF795548),
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }
}
