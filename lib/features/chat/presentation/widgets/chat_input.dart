import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String path, int durationMs)? onAudioRecorded;
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
    this.onAudioRecorded,
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

  // Recording state
  bool _isRecording = false;
  bool _cancelledBySlide = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  AudioRecorder? _recorder;
  Offset _longPressStartPosition = Offset.zero;

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
    _recordTimer?.cancel();
    _recorder?.dispose();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSendMessage(_controller.text.trim());
    _controller.clear();
  }

  Future<void> _startRecording(Offset globalPosition) async {
    final recorder = AudioRecorder();
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) {
      await recorder.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de microfone necessária para enviar áudios.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
        androidConfig: AndroidRecordConfig(
          audioSource: AndroidAudioSource.mic,
        ),
      ),
      path: path,
    );

    setState(() {
      _recorder = recorder;
      _isRecording = true;
      _cancelledBySlide = false;
      _recordDuration = Duration.zero;
      _longPressStartPosition = globalPosition;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    _recordTimer?.cancel();
    _recordTimer = null;

    final recorder = _recorder;
    _recorder = null;
    final capturedDurationMs = _recordDuration.inMilliseconds;

    setState(() {
      _isRecording = false;
      _cancelledBySlide = false;
      _recordDuration = Duration.zero;
    });

    if (recorder != null) {
      final path = await recorder.stop();
      await recorder.dispose();
      if (!cancel && path != null && mounted) {
        widget.onAudioRecorded?.call(path, capturedDurationMs);
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                // Input area (text or recording indicator)
                Expanded(
                  child: _isRecording
                      ? _buildRecordingIndicator(isDark)
                      : _buildTextField(isDark, showSend),
                ),
                const SizedBox(width: 6),
                // Send / Mic button
                GestureDetector(
                  onTap: showSend && !_isRecording ? _send : null,
                  onLongPressStart: (!showSend && !_isRecording)
                      ? (details) => _startRecording(details.globalPosition)
                      : null,
                  onLongPressMoveUpdate: _isRecording
                      ? (details) {
                          final dx = details.globalPosition.dx - _longPressStartPosition.dx;
                          if (dx < -80 && !_cancelledBySlide) {
                            setState(() => _cancelledBySlide = true);
                            _stopRecording(cancel: true);
                          }
                        }
                      : null,
                  onLongPressEnd: _isRecording
                      ? (details) {
                          if (!_cancelledBySlide) _stopRecording(cancel: false);
                        }
                      : null,
                  onLongPressCancel: _isRecording ? () => _stopRecording(cancel: true) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : AppColors.primary)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: _isRecording
                          ? const Icon(
                              Icons.stop_rounded,
                              key: ValueKey('stop'),
                              color: Colors.white,
                              size: 22,
                            )
                          : showSend
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

  Widget _buildTextField(bool isDark, bool showSend) {
    final fieldBg = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Colors.white;
    final iconColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.07),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
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
                hintText: widget.isEditing ? 'Editar mensagem...' : 'Mensagem',
                hintStyle: TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                isDense: true,
              ),
            ),
          ),
          if (!widget.isEditing) ...[
            IconButton(
              onPressed: widget.onImagePicked,
              icon: Icon(Icons.attach_file_rounded, color: iconColor, size: 22),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
              splashRadius: 18,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                onPressed: widget.onCameraPicked,
                icon: Icon(Icons.camera_alt_outlined, color: iconColor, size: 22),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
                splashRadius: 18,
              ),
            ),
          ] else
            const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withValues(alpha: 0.18)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.red.shade200.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const _PulsingDot(),
          const SizedBox(width: 10),
          Text(
            _formatDuration(_recordDuration),
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '← Deslize para cancelar',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.grey.shade500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
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
