import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/image_combine_animation.dart';

class MatchResultScreen extends StatelessWidget {
  const MatchResultScreen({super.key});

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
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 12),

              // Match Title & Partner Reveal
              Text(
                "🎉 Mystery Solved!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.headlineMedium?.color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You found your partner: ${game.partnerName} (${game.partnerAvatar})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: primaryAccent,
                ),
              ),
              const SizedBox(height: 24),

              // Animated Merged Image Component
              // Reveals this pair's own unique image (from the backend) once
              // matched — every other pair sees a different picture.
              Center(
                child: ImageCombineAnimation(
                  imageAsset: game.imageAsset,
                  leftImageDataUri: game.revealedLeftImage,
                  rightImageDataUri: game.revealedRightImage,
                ),
              ),
              const SizedBox(height: 24),

              // Completion Subtitle
              Text(
                'Two puzzle halves merged into one picture!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleMedium?.color,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),

              // Time Metrics Block
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'MATCH COMPLETION TIME',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.bodyMedium?.color,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      game.formattedTime.isNotEmpty ? game.formattedTime : '00:28.16',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: primaryAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppButton(
                label: 'VIEW LIVE LEADERBOARD 🏆',
                gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.leaderboard);
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'BACK TO HOME 🏠',
                outlined: true,
                onPressed: () {
                  game.resetGame();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 0),
    );
  }
}