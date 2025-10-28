import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/app_state.dart';
import '../models/meal_entry.dart';
import '../models/sleep_log.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final userName = state.currentUser?.name ?? 'Guest';
          final latestStep =
              state.stepLogs.isNotEmpty ? state.stepLogs.first : null;
          final latestSleep =
              state.sleepLogs.isNotEmpty ? state.sleepLogs.first : null;
          final totalCalories = state.mealEntries.fold<int>(
            0,
            (sum, entry) => sum + entry.calories * entry.quantity,
          );
          final protein = _sumMacro(state.mealEntries, (meal) => meal.protein);
          final carbs = _sumMacro(state.mealEntries, (meal) => meal.carbs);
          final fat = _sumMacro(state.mealEntries, (meal) => meal.fat);

          final goalSteps = latestStep?.goal ?? 10000;
          final currentSteps = latestStep?.steps ?? 0;
          final progress = goalSteps == 0 ? 0.0 : currentSteps / goalSteps;

          final dateLabel =
              DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());
          return RefreshIndicator(
            onRefresh: () async {
              await state.ensureInitialized();
            },
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Pagi,',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        userName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StepProgressCard(
                currentSteps: currentSteps,
                goalSteps: goalSteps,
                progress: progress,
              ),
              const SizedBox(height: 16),
              _WeeklyReportCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SleepCard(
                      sleep: latestSleep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CaloriesCard(
                      totalCalories: totalCalories,
                      target: 2200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Ringkasan Nutrisi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MacroCard(
                      label: 'Protein',
                      value: protein,
                      target: 100,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MacroCard(
                      label: 'Karbo',
                      value: carbs,
                      target: 250,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MacroCard(
                      label: 'Lemak',
                      value: fat,
                      target: 70,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  static int _sumMacro(
    List<MealEntry> entries,
    int Function(MealEntry meal) extractor,
  ) {
    return entries.fold<int>(
      0,
      (previousValue, element) =>
          previousValue + extractor(element) * element.quantity,
    );
  }
}

class _StepProgressCard extends StatelessWidget {
  const _StepProgressCard({
    required this.currentSteps,
    required this.goalSteps,
    required this.progress,
  });

  final int currentSteps;
  final int goalSteps;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 14,
                      value: progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accentOrange,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_walk_rounded,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat('#,###').format(currentSteps),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Langkah',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% dari target $goalSteps langkah',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 120,
              color: const Color(0xFFE0F2F1),
              alignment: Alignment.center,
              child: const Icon(
                Icons.insights,
                size: 56,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Mingguan Anda Sudah Siap!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lihat progres Anda dan dapatkan insight baru untuk minggu depan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: const Text('Lihat Laporan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.sleep});

  final SleepLog? sleep;

  @override
  Widget build(BuildContext context) {
    final durationMinutes = sleep?.durationMinutes ?? 0;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    final quality = sleep?.quality ?? '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEBFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color: Color(0xFF6D28D9),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tidur',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${hours}j ${minutes}m',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kualitas: $quality',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({
    required this.totalCalories,
    required this.target,
  });

  final int totalCalories;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFDEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Kalori',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat('#,###').format(totalCalories),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Target: $target kkal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final int value;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : value / target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 74,
              width: 74,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 8,
                    value: progress.clamp(0, 1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: AppColors.border,
                  ),
                  Text(
                    '$value/$target',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
