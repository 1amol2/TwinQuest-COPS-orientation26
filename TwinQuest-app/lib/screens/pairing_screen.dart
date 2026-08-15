import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/half_card.dart';

class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
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
              title: 'Pair Assigned',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Mystery Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_clock_rounded, size: 18, color: primaryAccent),
                              const SizedBox(width: 6),
                              Text(
                                'PARTNER ASSIGNED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: primaryAccent,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Scan the hall using Bluetooth signal! Partner identity is secret until you physically touch phones together.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Half Card Component
                    HalfCard(
                      number: 'Your Half Piece (${game.imageHalf} Half)',
                      imageAsset: game.imageAsset,
                    ),

                    const SizedBox(height: 20),

                    // Gameplay rules summary card
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
                            'Bluetooth Signal Guide:',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('🔵 Blue – Mystery partner is far away'),
                          const SizedBox(height: 6),
                          const Text('🔴 Red – Getting close to mystery partner'),
                          const SizedBox(height: 6),
                          const Text('🟢 Green – Touch both phones together to reveal identity!'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      label: 'START BLUETOOTH SIGNAL SEARCH 🔍',
                      gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                      onPressed: () {
                        game.startProximitySearch();
                        Navigator.pushNamed(context, AppRoutes.closer);
                      },
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 0),
    );
  }
}