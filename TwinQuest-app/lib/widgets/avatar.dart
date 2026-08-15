import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class Avatar extends StatelessWidget {
  final String letter;
  final double size;
  final Color? color;

  const Avatar({
    super.key,
    required this.letter,
    this.size = 42,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppColors.primary.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.12);

    final textColor = isDark ? AppColors.amber : AppColors.primary;
    final borderColor = isDark ? AppColors.darkBorderHighlight : AppColors.borderHighlight;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? defaultBg,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * .38,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}
