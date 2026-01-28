import 'package:flutter/material.dart';
import 'package:year_dots/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final shadowColor = isDark 
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.08);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
