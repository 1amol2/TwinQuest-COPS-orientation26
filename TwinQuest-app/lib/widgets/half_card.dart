import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HalfCard extends StatelessWidget {
  final String number;
  final String imageAsset;
  final String label;
  final bool isHidden;

  const HalfCard({
    super.key,
    required this.number,
    required this.imageAsset,
    this.label = 'Your Piece',
    this.isHidden = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorderHighlight : AppColors.borderHighlight;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isHidden ? (isDark ? AppColors.darkSurfaceSoft : const Color(0xFFF7F2EC)) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHidden ? primaryAccent.withValues(alpha: 0.3) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isHidden
                ? Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 28,
                      color: primaryAccent,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      imageAsset,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHidden ? '🔒 Secret Puzzle Piece' : number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                if (isHidden) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Revealed when PIN match is verified!',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSoft : AppColors.textSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
