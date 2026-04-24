import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focuszen/theme.dart';
import 'package:focuszen/services/user_service.dart';
import 'package:focuszen/services/session_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserService, SessionService>(
      builder: (context, userService, sessionService, _) {
        final user = userService.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final weekSessions = sessionService.getThisWeekSessions();

        return SingleChildScrollView(
          padding: AppSpacing.horizontalLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text('İstatistiklerin', style: context.textStyles.headlineLarge),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.access_time,
                      iconColor: AppColors.purple,
                      value: '${user.totalFocusMinutes} dk',
                      label: 'Toplam Odak',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.auto_awesome,
                      iconColor: AppColors.cyan,
                      value: '${user.points}',
                      label: 'Kazanılan Puan',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: AppColors.yellow,
                      value: '${user.dayStreak}',
                      label: 'Gün Serisi',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      iconColor: AppColors.pink,
                      value: '${user.sessionsCompleted}',
                      label: 'Seans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bu Hafta', style: context.textStyles.titleLarge),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 150,
                      child: weekSessions.isEmpty
                          ? Center(
                              child: Text(
                                'Bu hafta henüz seans yok',
                                style: context.textStyles.bodyMedium,
                              ),
                            )
                          : _WeekChart(sessions: weekSessions),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: context.textStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: context.textStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List sessions;

  const _WeekChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final Map<int, int> dayMinutes = {};
    for (int i = 0; i < 7; i++) {
      dayMinutes[i] = 0;
    }
    
    for (var session in sessions) {
      final dayIndex = session.startTime.difference(weekStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dayMinutes[dayIndex] = ((dayMinutes[dayIndex]!) + session.durationMinutes) as int;
      }
    }
    
    final maxMinutes = dayMinutes.values.isEmpty ? 0 : dayMinutes.values.reduce((a, b) => a > b ? a : b);
    if (maxMinutes == 0) {
      return Center(child: Text('Veri yok', style: context.textStyles.bodyMedium));
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final minutes = dayMinutes[index] ?? 0;
        final height = maxMinutes > 0 ? (minutes / maxMinutes) * 120 : 0.0;
        final days = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 32,
              height: height.clamp(4.0, 120.0),
              decoration: BoxDecoration(
                color: index == now.weekday - 1 ? AppColors.purple : AppColors.purple.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[index], style: context.textStyles.labelSmall),
          ],
        );
      }),
    );
  }
}
