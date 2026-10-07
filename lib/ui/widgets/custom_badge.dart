import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomBadge extends StatelessWidget {
  final Widget child;
  final bool isGold;
  final Color? color;

  const CustomBadge({
    super.key,
    required this.child,
    this.isGold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isGold ? AppColors.gold400.withValues(alpha: 0.15) : (color?.withValues(alpha: 0.15) ?? Colors.white.withValues(alpha: 0.08));
    final border = isGold ? AppColors.gold400.withValues(alpha: 0.4) : (color?.withValues(alpha: 0.4) ?? Colors.white.withValues(alpha: 0.15));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: isGold ? AppColors.gold400 : (color ?? Colors.white70),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        child: child,
      ),
    );
  }
}
