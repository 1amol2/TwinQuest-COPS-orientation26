import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';

class PairQuestBottomNav extends StatelessWidget {
  final int selectedIndex;

  const PairQuestBottomNav({super.key, required this.selectedIndex});

  void _go(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.leaderboard,
      2 => AppRoutes.myPair,
      _ => AppRoutes.profile,
    };
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.bar_chart_rounded, 'Leaderboard'),
      (Icons.people_alt_rounded, 'Pairs'),
      (Icons.person_rounded, 'Profile'),
    ];

    final navBg = isDark ? AppColors.darkSurface : AppColors.background;
    final navBorder = isDark ? AppColors.darkBorder : AppColors.border;
    final activeColor = isDark ? AppColors.amber : AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: navBorder)),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final active = i == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () => _go(context, i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].$1,
                      size: 22,
                      color: active ? activeColor : inactiveColor,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? activeColor : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
