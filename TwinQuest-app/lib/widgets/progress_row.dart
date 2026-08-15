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
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          complete ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 18,
          color: complete ? AppColors.green : theme.textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: complete ? AppColors.green : theme.textTheme.bodySmall?.color,
        ),
      ],
    );
  }
}
