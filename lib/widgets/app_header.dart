import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final String? subtitle;

  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: onBack == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: AppColors.text,
                    padding: EdgeInsets.zero,
                  ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 38, child: trailing ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
