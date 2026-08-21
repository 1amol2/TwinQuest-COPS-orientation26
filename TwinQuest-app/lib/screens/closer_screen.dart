import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../services/ble_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/half_card.dart';
import '../widgets/signal_rings.dart';
import '../widgets/radar_scanner.dart';
import '../widgets/app_button.dart';

class CloserScreen extends StatelessWidget {
  const CloserScreen({super.key});

  Future<void> _goBackToPairSearch(BuildContext context) async {
    final game = context.read<GameProvider>();

    await game.returnToPairSearch();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.pairing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.proximityLevel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;

    Color ringColor;
    String statusTitle;
    String statusSubtitle;
    String signalBars;

    switch (level) {
      case ProximityLevel.far:
        ringColor = AppColors.blue;
        statusTitle = '🔵 Mystery partner far away';
        statusSubtitle = 'Scan around the orientation hall to pick up signal!';
        signalBars = '●○○○○';
        break;
      case ProximityLevel.close:
        ringColor = AppColors.orange;
        statusTitle = '🔴 Getting warmer!';
        statusSubtitle = 'You are very close! Walk towards the signal...';
        signalBars = '●●●●○';
        break;
      case ProximityLevel.touch:
        ringColor = AppColors.green;
        statusTitle = '🟢 Touch Zone Reached!';
        statusSubtitle = 'Hold both phones together to confirm match!';
        signalBars = '●●●●●';
        break;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToPairSearch(context);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppHeader(
                title: 'Bluetooth Search 🔍',
                onBack: () => _goBackToPairSearch(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timer & Secret Badge Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_clock_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.amber : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Partner: ??? (Secret)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.amber : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              game.formattedTime,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isDark ? AppColors.amber : AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Signal Rings & Radar Visual
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RadarScanner(accentColor: ringColor, size: 210),
                            SignalRings(accent: ringColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Signal Status Text
                      Text(
                        statusTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ringColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Metrics Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            _MetricRow(
                              label: 'Signal Strength (RSSI)',
                              value: '$signalBars (${game.rssi} dBm)',
                              valueColor: ringColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: cardBorder,
                              ),
                            ),
                            _MetricRow(
                              label: 'Estimated Distance',
                              value: '${game.estimatedDistance.toStringAsFixed(1)} meters',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),



                      // Card Component
                      HalfCard(
                        number: 'Your Piece (${game.imageHalf} Half)',
                        imageAsset: game.imageAsset,
                      ),

                      const SizedBox(height: 20),

                      // Primary Action Button
                      AppButton(
                        label: level == ProximityLevel.touch
                            ? 'TOUCH PHONES NOW 🟢'
                            : 'VERIFY PARTNER & MATCH 🤝',
                        gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.touch);
                        },
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () => _goBackToPairSearch(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('BACK TO PAIR SEARCH'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: isDark
                              ? AppColors.darkText
                              : AppColors.text,
                          side: BorderSide(color: cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const PairQuestBottomNav(
            selectedIndex: 0
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? theme.textTheme.titleMedium?.color,
          ),
        ),
      ],
    );
  }
}