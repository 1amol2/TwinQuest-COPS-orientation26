import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/game_provider.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/progress_row.dart';
import '../widgets/app_button.dart';

class MyPairScreen extends StatelessWidget {
  const MyPairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Active Pair',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),

                      // Avatars Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Avatar(
                            letter: game.playerName.isNotEmpty ? game.playerName[0].toUpperCase() : 'V',
                            size: 76,
                          ),
                          const SizedBox(width: 12),
                          Avatar(
                            letter: game.partnerName.isNotEmpty ? game.partnerName[0].toUpperCase() : '?',
                            size: 76,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Heart Indicator
                      const Text(
                        '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 3,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Pair Title & Badge Number
                      Text(
                        '${game.playerName} & ${game.partnerName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.headlineMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assigned Pair Code: ${game.pairId}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Match Time Metric Block
                      Text(
                        'Match Completion Speed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.formattedTime.isNotEmpty ? game.formattedTime : '00:28.16',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: primaryAccent,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Journey Timeline',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.titleMedium?.color,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const ProgressRow(label: 'Pair Assigned by Backend', time: '12:45 PM'),
                            const SizedBox(height: 12),
                            const ProgressRow(label: 'Bluetooth Search Initiated', time: '12:46 PM'),
                            const SizedBox(height: 12),
                            const ProgressRow(label: 'Green Touch Zone Reached', time: '12:46 PM'),
                            const SizedBox(height: 12),
                            const ProgressRow(label: 'Phones Touched & Matched!', time: '12:46 PM'),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // Action Button
                      AppButton(
                        label: 'SAY HI TO PARTNER 👋',
                        gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 2),
    );
  }
}