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

  final TextEditingController _staffKeyController =
  TextEditingController();

  String? _staffKeyError;


  @override
  void dispose() {
    _staffKeyController.dispose();
    super.dispose();
  }
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
    setState(() {
      _isLoading = true;
    });

    try {
      await StorageService.saveUser(
        name: 'COPS Admin / Staff',
        email: 'admin@copsiitbhu.org',
        avatar: '👑',
        authType: 'STAFF',
      );

      if (!mounted) return;

      final game = context.read<GameProvider>();

      game.setPlayerDetails(
        name: 'COPS Admin',
        avatar: '👑',
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.hostLobby,
      );
    } catch (e) {
      debugPrint('STAFF LOGIN ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void _showStaffKeyDialog() {
    const adminKey = '1admin23';
    final keyController = TextEditingController();
    String? errorMessage;
    bool isChecking = false;

    showDialog(
      context: context,
      barrierDismissible: !isChecking,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Staff Access',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the staff access key to continue to the Host Lobby.',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: keyController,
                    obscureText: true,
                    autofocus: true,
                    enabled: !isChecking,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      // Optional: trigger the same validation as Proceed
                    },
                    decoration: InputDecoration(
                      labelText: 'Staff Access Key',
                      hintText: 'Enter key',
                      prefixIcon: const Icon(
                        Icons.key_rounded,
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      errorText: errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: isChecking
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isChecking
                      ? null
                      : () async {
                    final enteredKey =
                    keyController.text.trim();

                    if (enteredKey.isEmpty) {
                      setDialogState(() {
                        errorMessage =
                        'Please enter the staff access key.';
                      });
                      return;
                    }

                    setDialogState(() {
                      isChecking = true;
                      errorMessage = null;
                    });

                    // TEMPORARY CHECK
                    //
                    // Replace this with backend verification.
                    const adminKey = '1admin23';

                    await Future.delayed(
                      const Duration(milliseconds: 300),
                    );

                    if (enteredKey != adminKey) {
                      setDialogState(() {
                        isChecking = false;
                        errorMessage =
                        '❌ Invalid staff access key.';
                      });
                      return;
                    }

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    await _handleStaffLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isChecking
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Proceed'),
                ),
              ],
            );
          },
        );
      },
    );
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
                        onPressed: _isLoading ? null : _showStaffKeyDialog,
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