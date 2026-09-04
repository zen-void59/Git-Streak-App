import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habits_provider.dart';
import '../utils/constants.dart';
import '../utils/xp_calculator.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/badge_chip.dart';
import '../widgets/empty_state.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addHabit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Habit'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Code for 1 hour',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.clear();
            },
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;
              context.read<HabitsProvider>().addHabit(_controller.text);
              _controller.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Habits'),
        actions: [
          Consumer<HabitsProvider>(
            builder: (context, habits, _) {
              if (habits.hasSelection) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  onPressed: () => habits.deleteSelectedHabits(),
                  tooltip: 'Delete selected',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<HabitsProvider>(
        builder: (context, habits, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Header
              const Text('Daily Habits,', style: AppTextStyles.headline1),
              const SizedBox(height: 4),
              const Text('Stay disciplined. Stay ahead.',
                  style: AppTextStyles.body),
              const SizedBox(height: 20),

              // Stats row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HabitStatCard(
                      label: 'Total Habits',
                      value: '${habits.length}',
                      icon: Icons.list_alt_rounded,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 12),
                    _HabitStatCard(
                      label: 'Completion',
                      value:
                          '${(habits.completionRate * 100).toStringAsFixed(0)}%',
                      icon: Icons.check_circle_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _HabitStatCard(
                      label: 'XP Earned',
                      value: habits.totalXp >= 1000
                          ? '${(habits.totalXp / 1000).toStringAsFixed(1)}K'
                          : '${habits.totalXp}',
                      icon: Icons.bolt,
                      color: AppColors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // XP Progress Bar
              XpProgressBar(
                totalXp: habits.totalXp,
                progress: habits.progress,
                level: habits.level,
                title: habits.title,
                xpToNext: habits.xpToNext,
              ),
              const SizedBox(height: 16),

              // Badges
              if (habits.badges.isNotEmpty) ...[
                const Text('Achievements', style: AppTextStyles.headline3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      habits.badges.map((b) => BadgeChip(badge: b)).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Habits list
              const Text('Your Habits', style: AppTextStyles.headline3),
              const SizedBox(height: 10),

              if (habits.isEmpty)
                const EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'No habits yet',
                  subtitle: 'Tap + to add your first habit!',
                )
              else
                ...List.generate(habits.length, (index) {
                  final habit = habits.getHabit(index);
                  final isSelected = habits.isHabitSelected(index);
                  final isCoding = habits.isCodingHabit(habit.name);

                  return GestureDetector(
                    onLongPress: () => habits.toggleHabitSelection(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Leading icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: habit.completed
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isCoding
                                  ? Icons.code_rounded
                                  : Icons.task_alt_rounded,
                              color: habit.completed
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      habit.name,
                                      style: TextStyle(
                                        color: habit.completed
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        decoration: habit.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (isCoding) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '⚡ GitHub',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${habit.days} day${habit.days != 1 ? 's' : ''} streak  •  +${XpCalculator.xpPerHabitCompletion} XP',
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Complete toggle
                          GestureDetector(
                            onTap: () => habits.toggleHabitCompleted(index),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                habit.completed
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                key: ValueKey(habit.completed),
                                color: habit.completed
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HabitStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
