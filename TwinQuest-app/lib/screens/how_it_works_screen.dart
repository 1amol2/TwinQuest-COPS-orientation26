import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../widgets/app_button.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    final steps = [
      (Icons.person_add_alt_1_rounded, 'Join the Lobby', 'Enter your name and join with event code ORIENT26.'),
      (Icons.radar_rounded, 'Pair Assignment', 'Get assigned a secret puzzle image half (partner is hidden!).'),
      (Icons.bluetooth_searching_rounded, 'Follow Signal Rings', 'Move around hall: 🔵 Far ➔ 🔴 Warm ➔ 🟢 Touch Zone!'),
      (Icons.phonelink_ring_rounded, 'Touch Phones to Reveal!', 'Hold both phones together for 3 seconds to reveal identity & merge picture!'),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'How To Play TwinQuest 💡',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: theme.iconTheme.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: steps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final s = steps[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                            ),
                            child: Icon(s.$1, color: primaryAccent, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${i + 1}.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: primaryAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        s.$2,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: theme.textTheme.titleMedium?.color,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.$3,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'READY TO PLAY? JOIN NOW!',
                gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.joinEvent),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}