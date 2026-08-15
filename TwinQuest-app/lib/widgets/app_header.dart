import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

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
                    color: theme.iconTheme.color,
                    padding: EdgeInsets.zero,
                  ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleLarge?.color,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
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
