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
    final rings = success
        ? [
            const Color(0xFFF0F2E8),
            const Color(0xFFE2E9D2),
            const Color(0xFFC9D8A8),
            const Color(0xFF9FBF70),
          ]
        : [
            const Color(0xFFF8EDE2),
            const Color(0xFFF4DFCD),
            const Color(0xFFECC6AA),
            accent,
          ];

    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < rings.length; i++)
            Container(
              width: 205 - i * 39,
              height: 205 - i * 39,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rings[i],
                border: Border.all(color: Colors.white.withOpacity(.45)),
              ),
            ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success ? AppColors.green : accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.14),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              success ? Icons.check_rounded : icon,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}
