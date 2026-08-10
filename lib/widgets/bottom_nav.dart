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
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.bar_chart_rounded, 'Leaderboard'),
      (Icons.people_alt_rounded, 'Pairs'),
      (Icons.person_rounded, 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
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
                      size: 20,
                      color: active ? AppColors.primary : AppColors.muted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? AppColors.primary : AppColors.muted,
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
