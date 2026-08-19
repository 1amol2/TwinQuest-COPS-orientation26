import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../providers/game_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';

class JoinEventScreen extends StatefulWidget {
  const JoinEventScreen({super.key});

  @override
  State<JoinEventScreen> createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Rohan');
  final TextEditingController _codeController = TextEditingController(text: 'ORIENT26');
  String _selectedAvatar = '⚡';
  bool _isLoading = false;

  final List<String> _avatars = ['⚡', '🌟', '🚀', '🔥', '🎯', '✨', '🦊', '🎨'];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputFill = isDark ? AppColors.darkSurface : AppColors.surface;
    final inputBorder = isDark ? AppColors.darkBorderHighlight : AppColors.border;
    final primaryAccent = isDark ? AppColors.amber : AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                title: 'Join Event',
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Ready to find your twin?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.headlineMedium?.color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your name and pick an avatar!',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              Text(
                'Your Name / Nickname',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'e.g. Rohan',
                  hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                  fillColor: inputFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Code Field
              Text(
                'Orientation Event Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'e.g. ORIENT26',
                  hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                  fillColor: inputFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar Selection
              Text(
                'Select Player Avatar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _avatars.map((av) {
                  final isSel = av == _selectedAvatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = av),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isSel
                            ? primaryAccent.withValues(alpha: 0.18)
                            : inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? primaryAccent : inputBorder,
                          width: isSel ? 2.5 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          av,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              AppButton(
                label: _isLoading ? 'CONNECTING TO GAME...' : 'ENTER LOBBY',
                gradient: isDark ? AppColors.goldGradient : AppColors.primaryGradient,
                onPressed: _isLoading
                    ? null
                    : () async {
                  final provider = context.read<GameProvider>();
                  final navigator = Navigator.of(context);

                  setState(() => _isLoading = true);

                  try {
                    print('JOIN EVENT: starting...');
                    print('NAME: ${_nameController.text.trim()}');
                    print('CODE: ${_codeController.text.trim()}');
                    print('AVATAR: $_selectedAvatar');

                    await provider.joinEvent(
                      name: _nameController.text.trim(),
                      code: _codeController.text.trim(),
                      avatarSymbol: _selectedAvatar,
                    );

                    print('JOIN EVENT: SUCCESS');

                    if (!mounted) return;

                    setState(() => _isLoading = false);

                    navigator.pushReplacementNamed(
                      AppRoutes.waitingLobby,
                    );
                  } catch (e) {
                    print('JOIN EVENT ERROR: $e');

                    if (!mounted) return;

                    setState(() => _isLoading = false);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to join event: $e',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}