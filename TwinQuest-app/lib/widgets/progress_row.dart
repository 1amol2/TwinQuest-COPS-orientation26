import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ProgressRow extends StatelessWidget {
  final String label;
  final String time;
  final bool complete;

  const ProgressRow({
    super.key,
    required this.label,
    required this.time,
    this.complete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          complete ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: complete ? AppColors.green : AppColors.muted,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 9.5, color: AppColors.muted),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.check_circle_rounded,
          size: 14,
          color: complete ? AppColors.green : AppColors.muted,
        ),
      ],
    );
  }
}
