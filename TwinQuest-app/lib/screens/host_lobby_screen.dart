import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';

class HostLobbyScreen extends StatefulWidget {
  const HostLobbyScreen({super.key});

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  Timer? _lobbyTimer;
  List<dynamic> _players = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeHostEvent();

    _lobbyTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
          (_) {
        _fetchLobbyPlayers();
      },
    );
  }
  Future<void> _initializeHostEvent() async {
    try {
      final event = await ApiService.createOrientationEvent();

      print('HOST EVENT CREATED/FOUND: $event');

      if (!mounted) return;

      _fetchLobbyPlayers();
    } catch (e) {
      print('HOST EVENT INITIALIZATION ERROR: $e');
    }
  }
  @override
  void dispose() {
    _lobbyTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLobbyPlayers() async {
    final provider = Provider.of<GameProvider>(context, listen: false);
    final players = await ApiService.getLobbyPlayers(eventId: provider.eventCode);
    if (mounted) {
      setState(() {
        _players = players;
      });
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Host Control Dashboard',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Event Code Banner Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: isDark ? AppColors.goldGradient : AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ORIENTATION EVENT CODE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.eventCode,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ask volunteers to enter this code on their phones to join lobby',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lobby Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Joined Volunteers Roster',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${_players.length} Ready',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Players Grid / List
                    if (_players.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: primaryAccent),
                            const SizedBox(height: 14),
                            Text(
                              'Waiting for more volunteers to enter code and join lobby...',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _players.length,
                        itemBuilder: (context, index) {
                          final p = _players[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  p['avatar'] ?? '⚡',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p['name'] ?? 'Volunteer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 28),

                    // Trigger Matchmaking Action
                    AppButton(
                      label: _isLoading ? 'PAIRING VOLUNTEERS...' : 'START RANDOM PAIR MATCHMAKING 🚀',
                      gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              setState(() => _isLoading = true);
                              await ApiService.startMatchmaking(eventId: game.eventCode);
                              if (mounted) {
                                setState(() => _isLoading = false);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Pairs matched! Volunteers assigned puzzle image halves.'),
                                    backgroundColor: AppColors.green,
                                  ),
                                );
                                navigator.pushNamed(AppRoutes.leaderboard);
                              }
                            },
                    ),

                    const SizedBox(height: 12),

                    AppButton(
                      label: 'RESET EVENT LOBBY 🔄',
                      outlined: true,
                      onPressed: () async {
                        await ApiService.resetEvent(eventId: game.eventCode);
                        _fetchLobbyPlayers();
                      },
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
