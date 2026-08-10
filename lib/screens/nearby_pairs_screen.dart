import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/avatar.dart';

class NearbyPairsScreen extends StatelessWidget {
  const NearbyPairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pairs = [
      ('#41', '2.1 m', 'A'),
      ('#73', '3.8 m', 'P'),
      ('#18', '5.6 m', 'N'),
      ('#92', '6.9 m', 'R'),
      ('#64', '8.3 m', 'S'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pairs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh_rounded, size: 19)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
        children: [
          ...pairs.map(
            (p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              margin: const EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Avatar(letter: p.$3, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  Text(p.$2, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.primary, size: 23),
                SizedBox(height: 5),
                Text(
                  'Move around to find your partner',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Stronger signal means you’re closer!',
                  style: TextStyle(fontSize: 9.5, color: AppColors.textSoft),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
