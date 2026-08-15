import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/game_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final leaderboard = game.leaderboard;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Leaderboard',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => game.fetchLeaderboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Fastest Pairs to Match ⚡',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'COPS Freshers Orientation 2026',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Leaderboard Items
                      if (leaderboard.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No pairs matched yet. Be the first pair!',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leaderboard.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = leaderboard[index];
                            final rank = item['rank'] ?? (index + 1);
                            final partner1 = item['partner1'] ?? 'Player A';
                            final partner2 = item['partner2'] ?? 'Player B';
                            final avatar1 = item['avatar1'] ?? '⚡';
                            final avatar2 = item['avatar2'] ?? '🌟';
                            final timeFormatted = item['timeFormatted'] ?? '00:30.00';
                            final isUserPair = item['isUserPair'] ?? false;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isUserPair
                                    ? primaryAccent.withValues(alpha: 0.15)
                                    : cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isUserPair ? primaryAccent : cardBorder,
                                  width: isUserPair ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Rank badge
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getRankColor(rank).withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$rank',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Avatars and Pair Names
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$partner1 $avatar1  &  $partner2 $avatar2',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: isUserPair
                                                ? primaryAccent
                                                : theme.textTheme.titleMedium?.color,
                                          ),
                                        ),
                                        if (isUserPair)
                                          Text(
                                            'YOUR PAIR ⭐',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: primaryAccent,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Time Taken
                                  Text(
                                    timeFormatted,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: primaryAccent,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 1),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFB800); // Gold
      case 2:
        return const Color(0xFFA3A3A3); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }
}