import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SignalRings extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final bool success;

  const SignalRings({
    super.key,
    this.accent = AppColors.primary,
    this.icon = Icons.bluetooth_rounded,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = success ? AppColors.green : accent;

    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric Outer Soft Glow Rings
          for (int i = 0; i < 4; i++)
            Container(
              width: 200 - i * 36,
              height: 200 - i * 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentColor.withValues(alpha: 0.08 + (i * 0.05)),
                border: Border.all(
                  color: currentColor.withValues(alpha: 0.3 - (i * 0.05)),
                  width: 1.5,
                ),
              ),
            ),
          // Center Pulsing Beacon Core
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  currentColor,
                  currentColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Icon(
              success ? Icons.check_rounded : icon,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}
