import 'package:flutter/material.dart';

class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.black, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
