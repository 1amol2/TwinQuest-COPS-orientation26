import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32, // Account for vertical padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Header Section
                      const Text(
                        'TwinQuest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Find your other half',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const Spacer(),

                      // Hero Image
                      Image.asset(
                        'assets/images/hero_pair.png',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),

                      const Spacer(),

                      // Action Buttons
                      AppButton(
                        label: 'Join Event',
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.joinEvent),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'How it works?',
                        outlined: true,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.howItWorks),
                      ),

                      const SizedBox(height: 28),

                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(true),
                          _dot(false),
                          _dot(false),
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

  Widget _dot(bool active) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: active ? 8 : 6,
    height: active ? 8 : 6,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: active ? AppColors.primary : AppColors.peach,
      shape: BoxShape.circle,
    ),
  );
}