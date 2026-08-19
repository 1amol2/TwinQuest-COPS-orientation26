import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: Icon(Icons.settings_outlined, size: 22, color: theme.iconTheme.color),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, String>>(
          future: StorageService.getUser(),
          builder: (context, snapshot) {
            final user = snapshot.data ?? {};
            final authType = user['authType'] ?? 'GUEST';
            final name = (user['name']?.isNotEmpty ?? false) ? user['name']! : game.playerName;
            final email = user['email'] ?? 'guest@pairquest.app';
            final isGuest = authType == 'GUEST';

            return Column(
              children: [
                // Scrollable Profile Details
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      const SizedBox(height: 4),

                      // Profile Avatar & Name
                      Center(
                        child: Avatar(
                          letter: name.isNotEmpty ? name[0].toUpperCase() : 'V',
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.headlineMedium?.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGuest
                                ? Colors.amber.withValues(alpha: 0.18)
                                : AppColors.green.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isGuest ? Colors.amber.shade700 : AppColors.green,
                            ),
                          ),
                          child: Text(
                            isGuest ? '⚡ GUEST ACCOUNT' : '✅ GOOGLE VERIFIED',
                            style: TextStyle(
                                fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isGuest ? Colors.amber.shade800 : AppColors.green,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Local Stats
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: StorageService.getSavedMatches(),
                        builder: (context, snapshot) {
                          final matches = snapshot.data ?? [];

                          int totalMatches = matches.length;
                          int bestTimeMs = 0;

                          for (final match in matches) {
                            final duration = match['durationMs'] ?? match['duration'] ?? 0;

                            if (duration is int && duration > 0) {
                              if (bestTimeMs == 0 || duration < bestTimeMs) {
                                bestTimeMs = duration;
                              }
                            }
                          }

                          String formattedBestTime = '--:--.--';

                          if (bestTimeMs > 0) {
                            final totalSeconds = bestTimeMs ~/ 1000;
                            final minutes = totalSeconds ~/ 60;
                            final seconds = totalSeconds % 60;
                            final centiseconds = (bestTimeMs % 1000) ~/ 10;

                            formattedBestTime =
                            '${minutes.toString().padLeft(2, '0')}:'
                                '${seconds.toString().padLeft(2, '0')}.'
                                '${centiseconds.toString().padLeft(2, '0')}';
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.04,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _StatItem(
                                  value: formattedBestTime,
                                  label: 'Best Speed',
                                  icon: Icons.flash_on_rounded,
                                  iconColor:
                                  isDark ? AppColors.amber : AppColors.primary,
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: cardBorder,
                                ),
                                _StatItem(
                                  value: '$totalMatches',
                                  label: 'Matches Played',
                                  icon: Icons.people_outline_rounded,
                                  iconColor:
                                  isDark ? AppColors.amber : AppColors.primary,
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: cardBorder,
                                ),
                                const _StatItem(
                                  value: '--',
                                  label: 'Rank',
                                  icon: Icons.emoji_events_outlined,
                                  iconColor: AppColors.primary,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Recent Matches Section from Backend Database
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Match History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.titleLarge?.color,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (isGuest)
                            Text(
                              'Guest Mode',
                              style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: StorageService.getSavedMatches(),
                        builder: (context, matchSnapshot) {
                          final matches = matchSnapshot.data ?? [];

                          if (matches.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  'No recent matches yet.\nPlay a game to record your times!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            );
                          }

                          return _buildMatchList(
                            matches,
                            cardBg,
                            cardBorder,
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // LOCKED BOTTOM LOGOUT CONTAINER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.background,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await StorageService.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'LOGOUT',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildMatchList(List<Map<String, dynamic>> matches, Color cardBg, Color cardBorder) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: matches.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: cardBorder),
        itemBuilder: (context, index) {
          final m = matches[index];
          final partnerName = m['partnerName'] ?? m['name'] ?? 'Partner';
          final durationMs = m['durationMs'] ?? m['duration'] ?? 0;

          String formattedTime = m['timeFormatted'] ?? m['formattedTime'] ?? '';
          if (formattedTime.isEmpty && durationMs is int && durationMs > 0) {
            final secs = (durationMs / 1000).floor();
            final mins = (secs / 60).floor();
            final remSecs = secs % 60;
            final ms = (durationMs % 1000) ~/ 10;
            formattedTime = '${mins.toString().padLeft(2, '0')}:${remSecs.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
          }
          if (formattedTime.isEmpty) formattedTime = '00:00.00';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: _Recent(
              name: partnerName,
              time: formattedTime,
              date: m['date'] ?? 'Today',
              letter: (m['avatar']?.isNotEmpty ?? false)
                  ? m['avatar']!
                  : (partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'P'),
            ),
          );
        },
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Recent extends StatelessWidget {
  final String name, time, date, letter;
  const _Recent({
    required this.name,
    required this.time,
    required this.date,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Avatar(letter: letter, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleMedium?.color,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}