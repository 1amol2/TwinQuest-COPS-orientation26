import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/half_card.dart';
import '../widgets/signal_rings.dart';
import '../widgets/app_button.dart';

class TouchMatchScreen extends StatelessWidget {
  const TouchMatchScreen({super.key});

  void _showQrPinDialog(BuildContext context, GameProvider game) {
    final pinController = TextEditingController();
    String? errorMessage;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.pin_rounded, size: 28, color: primaryAccent),
                  const SizedBox(width: 10),
                  const Text(
                    'Partner Verification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Find your partner in the hall! Type the 4-Digit PIN displayed on their screen to complete your match.',
                    style: TextStyle(fontSize: 12.5, color: theme.textTheme.bodyMedium?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Display player's own PIN badge (shown to their partner)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryAccent.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'YOUR SCREEN DISPLAYED PIN',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.pairPin.isNotEmpty ? game.pairPin : '----',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: primaryAccent,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '(Show this PIN to your partner)',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6),
                    decoration: InputDecoration(
                      hintText: '----',
                      labelText: 'Enter Partner\'s 4-Digit PIN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      counterText: '',
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.amber : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final enteredPin = pinController.text.trim();
                          if (enteredPin.length < 4) {
                            setDialogState(() {
                              errorMessage = '❌ Enter full 4-digit PIN!';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            errorMessage = null;
                          });

                          final success = await game.completeMatch(inputPin: enteredPin);

                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(ctx);
                              Navigator.pushReplacementNamed(context, AppRoutes.result);
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                errorMessage = '❌ Invalid PIN! Ask partner for their screen PIN.';
                              });
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm Match 🤝'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Touch to match',
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

                    // Signal Rings Visual
                    const Center(
                      child: SignalRings(success: true),
                    ),
                    const SizedBox(height: 12),

                    // Status Message Header
                    Text(
                      'Partner Search Active 🟢',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your mystery partner and verify their 4-Digit PIN!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Component
                    HalfCard(
                      number: '${game.partnerName} (${game.imageHalf})',
                      imageAsset: game.imageAsset,
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      label: 'VERIFY PARTNER PIN CODE 🔢',
                      gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                      onPressed: () => _showQrPinDialog(context, game),
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