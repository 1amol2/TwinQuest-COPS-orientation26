import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'core/routes.dart';
import 'screens/home_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/closer_screen.dart';
import 'screens/touch_match_screen.dart';
import 'screens/match_result_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/my_pair_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/join_event_screen.dart';
import 'screens/nearby_pairs_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PairQuestApp());
}

class PairQuestApp extends StatelessWidget {
  const PairQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PairQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.pairing: (_) => const PairingScreen(),
        AppRoutes.closer: (_) => const CloserScreen(),
        AppRoutes.touch: (_) => const TouchMatchScreen(),
        AppRoutes.result: (_) => const MatchResultScreen(),
        AppRoutes.leaderboard: (_) => const LeaderboardScreen(),
        AppRoutes.myPair: (_) => const MyPairScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.howItWorks: (_) => const HowItWorksScreen(),
        AppRoutes.joinEvent: (_) => const JoinEventScreen(),
        AppRoutes.nearby: (_) => const NearbyPairsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
