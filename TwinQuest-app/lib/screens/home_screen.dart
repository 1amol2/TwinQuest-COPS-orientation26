import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

import '../services/ble_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    BLEService().requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.amber : AppColors.primary;
    final softTextColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Freshers Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 6),
                              Text(
                                'COPS ORIENTATION 2026',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Section
                      Text(
                        'TwinQuest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ready, Set, Connect!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: softTextColor,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const Spacer(),

                      // Hero Graphic Canvas Container
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorderHighlight : AppColors.borderHighlight,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : primaryColor).withValues(alpha: isDark ? 0.4 : 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/hero_pair.png',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Action Buttons
                      AppButton(
                        label: 'PLAY',
                        gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.joinEvent),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'HOW TO PLAY? 💡',
                        outlined: true,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.howItWorks),
                      ),

                      const SizedBox(height: 24),

                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(true, primaryColor, isDark),
                          _dot(false, primaryColor, isDark),
                          _dot(false, primaryColor, isDark),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 0),
    );
  }

  Widget _dot(bool active, Color activeColor, bool isDark) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 16 : 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? activeColor : (isDark ? AppColors.darkBorderHighlight : AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}