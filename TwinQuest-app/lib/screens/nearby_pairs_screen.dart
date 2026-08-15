import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/avatar.dart';

class NearbyPairsScreen extends StatelessWidget {
  const NearbyPairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    final pairs = [
      ('Pair #1 (Aarav & Ananya)', '2.1 m away', 'A'),
      ('Pair #2 (Rohan & Priya)', '3.8 m away', 'P'),
      ('Pair #3 (Kabir & Diya)', '5.6 m away', 'N'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pairs In Hall 📡', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.iconTheme.color),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.refresh_rounded, size: 19, color: theme.iconTheme.color),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          ...pairs.map(
            (p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Avatar(letter: p.$3, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.$1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                  Text(
                    p.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: [
                Icon(Icons.location_on_outlined, color: primaryAccent, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Move around the hall to detect your partner',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Stronger signal means you are getting closer!',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
