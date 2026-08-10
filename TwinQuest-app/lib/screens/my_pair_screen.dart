import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/progress_row.dart';
import '../widgets/app_button.dart';

class MyPairScreen extends StatelessWidget {
  const MyPairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Pair',
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Avatar(letter: 'A', size: 76),
                          SizedBox(width: 12),
                          Avatar(letter: 'P', size: 76, color: Color(0xFFF0CDB5)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Heart Indicator
                      const Text(
                        '♥',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.red,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Pair Title & Badge Number
                      const Text(
                        'You & Priya',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pair #37',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Match Time Metric Block
                      const Text(
                        'Matched in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '00:28.16',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 14),
                            ProgressRow(label: 'Paired', time: '12:45 PM'),
                            SizedBox(height: 12),
                            ProgressRow(label: 'Getting closer', time: '12:46 PM'),
                            SizedBox(height: 12),
                            ProgressRow(label: 'Touch to match', time: '12:46 PM'),
                            SizedBox(height: 12),
                            ProgressRow(label: 'Matched', time: '12:46 PM'),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // Action Button
                      AppButton(
                        label: 'Send a Hi! 👋',
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