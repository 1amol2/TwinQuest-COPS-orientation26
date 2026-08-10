import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('1', 'Amol & Rahul', 'AR', '00:28.16'),
      ('2', 'Priya & Ankit', 'PA', '00:31.42'),
      ('3', 'Neha & Rohan', 'NR', '00:32.07'),
      ('4', 'Sneha & Karan', 'SK', '00:33.21'),
      ('5', 'Aditya & Meera', 'AM', '00:34.86'),
      ('6', 'Vivaan & Isha', 'VI', '00:36.11'),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🏆  Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            const Text(
              'Fastest pairs win!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSoft,
              ),
            ),
            const SizedBox(height: 16),

            // Filter Tabs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _Tab(label: 'All Pairs', active: true),
                  SizedBox(width: 8),
                  _Tab(label: 'Friends'),
                  SizedBox(width: 8),
                  _Tab(label: 'Nearby'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Leaderboard List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: rows.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final r = rows[index];
                  final isFirst = r.$1 == '1';

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            r.$1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isFirst ? AppColors.orange : AppColors.textSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Avatar(letter: r.$3, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.$2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Text(
                          r.$4,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 1),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;

  const _Tab({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.textSoft,
          ),
        ),
      ),
    );
  }
}