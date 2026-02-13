import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

class ScrollingAlert extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const ScrollingAlert({
    super.key,
    required this.text,
    this.onTap,
    this.onClose,
  });

  @override
  State<ScrollingAlert> createState() => _ScrollingAlertState();
}

class _ScrollingAlertState extends State<ScrollingAlert>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(
            seconds: 15,
          ), // Slightly slower for better readability
        )..addListener(() {
          if (_scrollController.hasClients) {
            final maxExtent = _scrollController.position.maxScrollExtent;
            if (maxExtent > 0) {
              _scrollController.jumpTo(_animationController.value * maxExtent);
            }
          }
        });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 30,
            width: double.infinity,
            color:
                Colors.amber.shade700, // Slightly darker for better visibility
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      widget.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 100),
                  Text(
                    widget.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 200),
                ],
              ),
            ),
          ),
        ),
        if (widget.onClose != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.amber.shade700,
                    Colors.amber.shade700.withOpacity(0.0),
                  ],
                ),
              ),
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
      ],
    );
  }
}
