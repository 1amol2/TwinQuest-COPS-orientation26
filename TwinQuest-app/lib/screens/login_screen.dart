import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;




  Future<void> _handleGuestLogin() async {
    final game = context.read<GameProvider>();
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.authenticateGuest(
        name: 'Guest Freshers',
        avatar: '🦊',
      );

      debugPrint('GUEST AUTH RESPONSE: $response');
      final userId = response['userId']?.toString();

      debugPrint('GUEST USER ID: $userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('Backend did not return a user ID');
      }

      await StorageService.saveUser(
        userId: userId,
        name: response['name']?.toString() ?? 'Guest Freshers',
        email: response['email']?.toString() ?? '',
        avatar: response['avatar']?.toString() ?? '🦊',
        authType: response['authType']?.toString() ?? 'GUEST',
      );

      // Verify that it was actually saved
      final savedUser = await StorageService.getUser();
      debugPrint('SAVED USER: $savedUser');

      if (!mounted) return;

      game.setPlayerDetails(
        name: 'Guest Freshers',
        avatar: '🦊',
      );

      setState(() => _isLoading = false);

      navigator.pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to connect to server: $e'),
        ),
      );
    }
  }

  Future<void> _handleStaffLogin() async {
    final game = context.read<GameProvider>();
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    await StorageService.saveUser(
      name: 'COPS Admin / Staff',
      email: 'admin@copsiitbhu.org',
      avatar: '👑',
      authType: 'STAFF',
    );

    if (mounted) {
      game.setPlayerDetails(name: 'COPS Admin', avatar: '👑');
      setState(() => _isLoading = false);
      navigator.pushReplacementNamed(AppRoutes.hostLobby);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final brandColor = isDark ? AppColors.amber : AppColors.primary;
    final buttonFillColor = isDark ? const Color(0xFF382922) : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Creative PairQuest Title & Branding Header
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: brandColor.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.people_alt_rounded, size: 44, color: brandColor),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'TwinQuest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.text,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'COPS FRESHERS ORIENTATION 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextSoft : theme.textTheme.bodyMedium?.color,
                  letterSpacing: 0.6,
                ),
              ),

              const SizedBox(height: 87),

              // Login Card Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const SizedBox(height: 24),

                    // Staff Login Outlined Button
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkText : AppColors.text,
                          side: BorderSide(color: cardBorder, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleStaffLogin,
                        icon: Icon(Icons.admin_panel_settings_outlined, size: 20, color: brandColor),
                        label: Text(
                          'Staff Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkText : AppColors.text,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Guest Login Outlined Button
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkText : AppColors.text,
                          side: BorderSide(color: cardBorder, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleGuestLogin,
                        icon: Icon(Icons.person_outline_rounded, size: 20, color: brandColor),
                        label: Text(
                          'Guest Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkText : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Footer Text
              Text(
                'By signing in, you agree to our Terms of Service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSoft : theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Made with ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSoft : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const Text('❤️', style: TextStyle(fontSize: 12)),
                  Text(
                    ' by COPS, IIT(BHU)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: brandColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}