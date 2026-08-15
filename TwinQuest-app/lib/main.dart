import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';

import 'screens/login_screen.dart';
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
import 'screens/lobby_waiting_screen.dart';
import 'screens/nearby_pairs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/host_lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PairQuestApp(),
    ),
  );
}

class PairQuestApp extends StatelessWidget {
  const PairQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PairQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
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
        AppRoutes.waitingLobby: (_) => const LobbyWaitingScreen(),
        AppRoutes.nearby: (_) => const NearbyPairsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.hostLobby: (_) => const HostLobbyScreen(),
      },
    );
  }
}
