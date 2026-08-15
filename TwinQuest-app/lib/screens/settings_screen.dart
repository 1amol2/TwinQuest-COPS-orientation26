import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final themeProvider = context.watch<ThemeProvider>();
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
              title: 'Settings',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme Preferences Section
                    Text(
                      'App Theme Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select Light, Dark, or System Default appearance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ThemeRadioTile(
                            title: 'Light Theme ☀️',
                            mode: ThemeMode.light,
                            currentMode: themeProvider.themeMode,
                            onChanged: (m) => themeProvider.setThemeMode(m),
                          ),
                          Divider(height: 1, thickness: 1, color: cardBorder),
                          _ThemeRadioTile(
                            title: 'Dark Mode 🌙',
                            mode: ThemeMode.dark,
                            currentMode: themeProvider.themeMode,
                            onChanged: (m) => themeProvider.setThemeMode(m),
                          ),
                          Divider(height: 1, thickness: 1, color: cardBorder),
                          _ThemeRadioTile(
                            title: 'System Default 📱',
                            mode: ThemeMode.system,
                            currentMode: themeProvider.themeMode,
                            onChanged: (m) => themeProvider.setThemeMode(m),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Bluetooth & Demo Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toggle demo mode for testing signal strength on emulators without physical Bluetooth devices.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Simulation Switch Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simulated Proximity Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Enable RSSI distance slider for demo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: game.isSimulatedMode,
                            activeTrackColor: primaryAccent,
                            onChanged: (val) => game.setSimulatedMode(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Information Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TwinQuest Engine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v1.0.0 — COPS Orientation 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color,
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
      bottomNavigationBar: const PairQuestBottomNav(selectedIndex: 3),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.mode,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = mode == currentMode;
    final activeColor = isDark ? AppColors.amber : AppColors.orange;

    return InkWell(
      onTap: () => onChanged(mode),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : theme.textTheme.titleMedium?.color,
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? activeColor : theme.textTheme.bodySmall?.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}