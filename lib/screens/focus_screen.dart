import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:focuszen/theme.dart';
import 'package:focuszen/services/user_service.dart';
import 'package:focuszen/services/session_service.dart';
import 'package:focuszen/services/character_service.dart';
import 'package:focuszen/services/app_blocker_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _selectedMinutes = 25;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _currentSessionId;

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    AppBlockerService.stopBlocking();
    super.dispose();
  }

  void _startTimer() async {
    if (_isRunning) return;

    final supported = await AppBlockerService.isSupported();
    if (supported) {
      // Best-effort: the native side will no-op if permission isn't granted.
      await AppBlockerService.requestAuthorization();
      await AppBlockerService.startBlocking(durationSeconds: _selectedMinutes * 60);
    }

    final userService = context.read<UserService>();
    final sessionService = context.read<SessionService>();

    if (userService.currentUser == null) return;

    final session = await sessionService.createSession(
      userService.currentUser!.id,
      _selectedMinutes,
    );

    sessionService.setFocusLocked(true);

    setState(() {
      _isRunning = true;
      _remainingSeconds = _selectedMinutes * 60;
      _currentSessionId = session.id;
    });

    WakelockPlus.enable();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() async {
    _timer?.cancel();
    WakelockPlus.disable();
    await AppBlockerService.stopBlocking();

    if (_currentSessionId != null) {
      final userService = context.read<UserService>();
      final sessionService = context.read<SessionService>();

      await sessionService.completeSession(_currentSessionId!, _selectedMinutes);
      await userService.completeSession(_selectedMinutes);

      if (mounted) {
        _showCompletionDialog();
      }
    }

    if (mounted) {
      context.read<SessionService>().setFocusLocked(false);
    }

    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
      _currentSessionId = null;
    });
  }

  void _showCompletionDialog() {
    final points = (_selectedMinutes / 5).floor() * 10;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('🎉 Seans Tamamlandı!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$points puan kazandın!', style: context.textStyles.titleLarge?.copyWith(color: AppColors.cyan)),
            const SizedBox(height: 8),
            Text('Harika gidiyorsun, devam et!', style: context.textStyles.bodyMedium),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, _) {
        final user = userService.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final character = CharacterService.getCharacterById(user.equippedCharacter);

        return Padding(
          padding: AppSpacing.horizontalLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Odak', style: context.textStyles.headlineLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.cyan, size: 20),
                        const SizedBox(width: 8),
                        Text('${user.points}', style: context.textStyles.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkCardBorder, width: 2),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(character?.emoji ?? '🔮', style: const TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              _isRunning ? _formatTime(_remainingSeconds) : '$_selectedMinutes:00',
                              style: context.textStyles.displayLarge?.copyWith(fontSize: 48),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRunning ? 'Odakta kal...' : 'Süreyi ayarla',
                              style: context.textStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!_isRunning) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (_selectedMinutes > 5) {
                          setState(() => _selectedMinutes -= 5);
                        }
                      },
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text('$_selectedMinutes', style: context.textStyles.displaySmall),
                        Text('dakika', style: context.textStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(width: 40),
                    _buildCircleButton(
                      icon: Icons.add,
                      onTap: () {
                        if (_selectedMinutes < 120) {
                          setState(() => _selectedMinutes += 5);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [5, 10, 15, 25, 45, 60].map((min) => _buildQuickButton(min)).toList(),
                ),
              ] else ...[
                Center(
                  child: Text('Seans devam ediyor', style: context.textStyles.bodyMedium),
                ),
              ],
              const SizedBox(height: 32),
              if (!_isRunning)
                Center(
                  child: ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 56)),
                    child: const Text('Odağı Başlat'),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkCard,
          border: Border.all(color: AppColors.darkCardBorder),
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }

  Widget _buildQuickButton(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    return InkWell(
      onTap: () => setState(() => _selectedMinutes = minutes),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.darkCardBorder,
          ),
        ),
        child: Text('${minutes} dk', style: context.textStyles.titleMedium),
      ),
    );
  }
}
