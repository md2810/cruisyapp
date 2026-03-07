import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.onTap,
    this.isTransparentStyle = false,
    this.size = 40.0,
  });

  final VoidCallback onTap;
  final bool isTransparentStyle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isTransparentStyle
              ? Colors.white.withValues(alpha: 0.2)
              : colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_rounded,
          color: isTransparentStyle ? Colors.white : colorScheme.onPrimaryContainer,
          size: size * 0.5,
        ),
      ),
    );
  }
}
