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
  final TextEditingController _googleNameController = TextEditingController(text: 'Rohan Sharma');
  final TextEditingController _googleEmailController = TextEditingController(text: 'rohan.freshers26@itbhu.ac.in');
  bool _isLoading = false;

  @override
  void dispose() {
    _googleNameController.dispose();
    _googleEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final brandColor = isDark ? AppColors.amber : AppColors.primary;

        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.g_mobiledata_rounded, size: 36, color: Color(0xFFEA4335)),
              SizedBox(width: 8),
              Text(
                'Google Sign-In',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signing in saves your orientation game stats, best times, and match history to your IIT BHU email database!',
                style: TextStyle(fontSize: 12.5, color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _googleNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _googleEmailController,
                decoration: InputDecoration(
                  labelText: 'Institute Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final game = context.read<GameProvider>();
                final navigator = Navigator.of(context);
                Navigator.pop(context);
                setState(() => _isLoading = true);

                final name = _googleNameController.text.trim().isNotEmpty
                    ? _googleNameController.text.trim()
                    : 'Rohan Sharma';
                final email = _googleEmailController.text.trim().isNotEmpty
                    ? _googleEmailController.text.trim()
                    : 'student@itbhu.ac.in';

                // Call Spring Boot Backend Auth Endpoint
                await ApiService.authenticateGoogle(
                  email: email,
                  name: name,
                  avatar: '⚡',
                );

                await StorageService.saveUser(
                  name: name,
                  email: email,
                  avatar: '⚡',
                  authType: 'GOOGLE',
                );

                if (mounted) {
                  game.setPlayerDetails(name: name, avatar: '⚡');
                  setState(() => _isLoading = false);
                  navigator.pushReplacementNamed(AppRoutes.home);
                }
              },
              child: const Text('Confirm Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGuestLogin() async {
    final game = context.read<GameProvider>();
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    // Call Spring Boot Backend Guest Endpoint
    await ApiService.authenticateGuest(
      name: 'Guest Freshers',
      avatar: '🦊',
    );

    await StorageService.saveUser(
      name: 'Guest Freshers',
      email: 'guest@pairquest.app',
      avatar: '🦊',
      authType: 'GUEST',
    );

    if (mounted) {
      game.setPlayerDetails(name: 'Guest', avatar: '🦊');
      setState(() => _isLoading = false);
      navigator.pushReplacementNamed(AppRoutes.home);
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
                    // Sign in with Google (Primary Filled Button)
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonFillColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: buttonFillColor.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: cardBorder,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkTextSoft : theme.textTheme.bodyMedium?.color,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: cardBorder,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

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
