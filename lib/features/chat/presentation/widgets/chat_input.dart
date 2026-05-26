import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final TextEditingController? controller;
  final bool isEditing;
  final VoidCallback? onCancelEdit;
  final String? repliedMessage;
  final String? repliedUserName;
  final VoidCallback? onCancelReply;
  final VoidCallback? onImagePicked;
  final VoidCallback? onCameraPicked;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.controller,
    this.isEditing = false,
    this.onCancelEdit,
    this.repliedMessage,
    this.repliedUserName,
    this.onCancelReply,
    this.onImagePicked,
    this.onCameraPicked,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      _controller.removeListener(_onTextChanged);
      _controller = widget.controller!;
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSendMessage(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Colors.white;
    final iconColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    final showSend = _hasText || widget.isEditing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isEditing)
          _InputBanner(
            icon: Icons.edit_rounded,
            color: AppColors.primary,
            title: 'Editando mensagem',
            onCancel: widget.onCancelEdit,
          ),
        if (widget.repliedMessage != null)
          _InputBanner(
            icon: Icons.reply_rounded,
            color: AppColors.primary,
            title: widget.repliedUserName ?? 'Usuário',
            subtitle: widget.repliedMessage,
            onCancel: widget.onCancelReply,
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field pill
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: fieldBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(width: 12),
                        // Text input
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: widget.isEditing,
                            minLines: 1,
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: widget.isEditing
                                  ? 'Editar mensagem...'
                                  : 'Mensagem',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).hintColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        // Attach + Camera icons (hidden while editing)
                        if (!widget.isEditing) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: IconButton(
                              onPressed: widget.onImagePicked,
                              icon: Icon(
                                Icons.attach_file_rounded,
                                color: iconColor,
                                size: 22,
                              ),
                              padding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 44,
                              ),
                              splashRadius: 18,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 6, bottom: 2),
                            child: IconButton(
                              onPressed: widget.onCameraPicked,
                              icon: Icon(
                                Icons.camera_alt_outlined,
                                color: iconColor,
                                size: 22,
                              ),
                              padding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 44,
                              ),
                              splashRadius: 18,
                            ),
                          ),
                        ] else
                          const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Send / Mic animated button
                GestureDetector(
                  onTap: showSend ? _send : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: showSend
                          ? Icon(
                              widget.isEditing
                                  ? Icons.check_rounded
                                  : Icons.send_rounded,
                              key: const ValueKey('send'),
                              color: Colors.white,
                              size: 22,
                            )
                          : const Icon(
                              Icons.mic_rounded,
                              key: ValueKey('mic'),
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onCancel;

  const _InputBanner({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
