import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final Gradient? gradient;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: outlined
                ? (isDark ? AppColors.darkText : AppColors.text)
                : Colors.white,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.darkText : AppColors.text,
          side: BorderSide(
            color: isDark ? AppColors.darkBorderHighlight : AppColors.borderHighlight,
            width: 1.5,
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      );
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? (gradient ?? AppColors.primaryGradient)
            : null,
        color: onPressed == null
            ? (isDark ? AppColors.darkMuted : AppColors.muted)
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }
}
