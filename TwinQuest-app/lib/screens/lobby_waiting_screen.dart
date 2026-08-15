import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/radar_scanner.dart';

class LobbyWaitingScreen extends StatefulWidget {
  const LobbyWaitingScreen({super.key});

  @override
  State<LobbyWaitingScreen> createState() => _LobbyWaitingScreenState();
}

class _LobbyWaitingScreenState extends State<LobbyWaitingScreen> {
  Timer? _pollTimer;
  List<dynamic> _players = [];
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      _checkAndFetch();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndFetch() async {
    if (_isNavigating) return;

    final game = Provider.of<GameProvider>(context, listen: false);

    // 1. Ensure current player is joined on backend
    if (game.playerId.isEmpty) {
      await game.joinEvent(
        name: game.playerName.isNotEmpty ? game.playerName : 'Volunteer',
        code: game.eventCode,
        avatarSymbol: game.avatar,
      );
    }

    // 2. Fetch updated player list for lobby status
    final players = await ApiService.getLobbyPlayers(eventId: game.eventCode);

    if (mounted) {
      setState(() {
        _players = players;
      });
    }

    // 3. Check if player has match assigned on backend
    if (game.playerId.isNotEmpty) {
      final matchData = await ApiService.getPlayerMatch(playerId: game.playerId);
      if (matchData != null && matchData.containsKey('id')) {
        String pId = matchData['id'] ?? 'PAIR_1';
        String r = matchData['role'] ?? 'LEFT';
        String partner = matchData['partnerName'] ?? 'Orientation Partner';
        String pAvatar = matchData['partnerAvatar'] ?? '🌟';

        game.assignPair(
          pairId: pId,
          partnerName: partner,
          partnerAvatar: pAvatar,
          imageHalf: r,
        );

        if (mounted && !_isNavigating) {
          setState(() => _isNavigating = true);
          _pollTimer?.cancel();
          Navigator.pushReplacementNamed(context, AppRoutes.pairing);
          return;
        }
      }
    }

    // 4. Auto-trigger matchmaking if player count is even >= 2 and no pair assigned yet
    final isEvenAndReady = players.length >= 2 && players.length % 2 == 0;
    if (isEvenAndReady && game.pairId.isEmpty) {
      await ApiService.startMatchmaking(eventId: game.eventCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    final count = _players.length;
    final isOdd = count % 2 != 0;
    final statusMessage = count < 2
        ? 'Waiting for at least 1 more player to form pairs...'
        : (isOdd
            ? 'Odd player count ($count). Invite 1 more friend to pair everyone!'
            : 'Even count reached ($count)! Assigning secret pairs...');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Lobby',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Radar Animation
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RadarScanner(accentColor: primaryAccent, size: 180),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '⏳',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Text
                    Text(
                      'WAITING FOR PLAYERS TO JOIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: primaryAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Online Roster Badge Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Lobby Roster',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count Online',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_players.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(color: primaryAccent),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _players.map((p) {
                                final isSelf = (p['name'] ?? '') == game.playerName;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelf
                                        ? primaryAccent.withValues(alpha: 0.18)
                                        : (isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelf ? primaryAccent : cardBorder,
                                      width: isSelf ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        p['avatar'] ?? '⚡',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        p['name'] ?? 'Player',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isSelf
                                              ? primaryAccent
                                              : theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      if (isSelf) ...[
                                        const SizedBox(width: 4),
                                        const Text(' (YOU)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bring Friends Invitation Banner Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryAccent.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.groups_rounded, size: 36, color: primaryAccent),
                          const SizedBox(height: 8),
                          Text(
                            'Get your friends in!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: primaryAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ask your friends to join the game! More the players, more exciting gets the hunt. Who knows who your secret match be?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.35,
                            ),
                          ),
                        ],
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
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 0),
    );
  }
}
