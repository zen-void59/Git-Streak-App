import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../login_page.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../utils/streak_recovery.dart';
import '../utils/weekly_goals.dart';
import '../utils/weekly_digest.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub Account section
            _SectionHeader(label: 'GitHub Account'),
            const SizedBox(height: 10),

            // Current account display
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.card,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.username ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'GitHub Connected via OAuth',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader(label: 'Notifications'),
            const SizedBox(height: 10),

            // Reminder toggle
            _SettingsTile(
              icon: Icons.alarm_rounded,
              iconColor: AppColors.orange,
              title: 'Daily Reminder',
              subtitle: 'Get notified to keep your streak',
              trailing: Switch(
                value: settings.isReminderOn,
                onChanged: (val) => settings.toggleReminder(val),
              ),
            ),
            const SizedBox(height: 10),

            // Time picker
            _SettingsTile(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.blue,
              title: 'Reminder Time',
              subtitle: settings.selectedTime != null
                  ? settings.selectedTime!.format(context)
                  : 'Tap to set time',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: _selectTime,
            ),

            const SizedBox(height: 24),
            _SectionHeader(label: 'Streak Settings'),
            const SizedBox(height: 10),

            // Streak Recovery toggle
            _SettingsTile(
              icon: Icons.shield,
              iconColor: AppColors.amber,
              title: 'Streak Recovery',
              subtitle: 'Get 1 free miss per 7-day streak',
              trailing: Switch(
                value: StreakRecovery.isEnabled(),
                onChanged: (val) async {
                  await StreakRecovery.setEnabled(val);
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),

            // Weekly Goal
            _SettingsTile(
              icon: Icons.flag,
              iconColor: AppColors.blue,
              title: 'Weekly Goal',
              subtitle: '${WeeklyGoals.getGoal()} commits per week',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => _showGoalPicker(context),
            ),
            const SizedBox(height: 10),

            // Weekly Digest toggle
            _SettingsTile(
              icon: Icons.summarize,
              iconColor: AppColors.primary,
              title: 'Weekly Digest',
              subtitle: 'Get notified every Sunday',
              trailing: Switch(
                value: WeeklyDigest.isEnabled(),
                onChanged: (val) async {
                  await WeeklyDigest.setEnabled(val);
                  if (mounted) setState(() {});
                },
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader(label: 'Account'),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.swap_horiz_rounded,
              iconColor: AppColors.purple,
              title: 'Switch Account',
              subtitle: 'Sign in with a different GitHub account',
              onTap: _switchAccount,
            ),

            const SizedBox(height: 24),
            _SectionHeader(label: 'Data & Privacy'),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.refresh_rounded,
              iconColor: AppColors.primary,
              title: 'Clear Cache',
              subtitle: 'Force refresh all data from GitHub',
              onTap: () async {
                await settings.clearCache();
                _showSnack('Cache cleared. Pull to refresh the dashboard.');
              },
            ),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.delete_sweep_rounded,
              iconColor: AppColors.red,
              title: 'Reset App',
              subtitle: 'Clear all data and habits',
              onTap: _resetApp,
              danger: true,
            ),

            const SizedBox(height: 24),
            _SectionHeader(label: 'About'),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_fire_department,
                            color: Color.fromARGB(255, 57, 211, 83)),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Moss',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18)),
                          Text('Version 2.0.0',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your GitHub coding streaks, build habits, and gamify your developer journey.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final settings = context.read<SettingsProvider>();
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      settings.selectTime(picked);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.cardBg,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showGoalPicker(BuildContext context) {
    final currentGoal = WeeklyGoals.getGoal();
    int selectedGoal = currentGoal;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Commit Goal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your target commits per week',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      inactiveTrackColor: AppColors.border,
                    ),
                    child: Slider(
                      value: selectedGoal.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (val) {
                        setState(() => selectedGoal = val.round());
                      },
                    ),
                  ),
                  Text(
                    '$selectedGoal commits per week',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick presets
              Wrap(
                spacing: 8,
                children: [3, 5, 7, 10, 14, 21].map((goal) {
                  final isSelected = selectedGoal == goal;
                  return GestureDetector(
                    onTap: () => setState(() => selectedGoal = goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '$goal',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await WeeklyGoals.setGoal(selectedGoal);
                    if (mounted) {
                      Navigator.pop(ctx);
                      setState(() {});
                      _showSnack('Weekly goal updated to $selectedGoal commits');
                    }
                  },
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Switch Account'),
        content: const Text(
          'This will sign you out and restart the app to switch to a different account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Switch', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _resetApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset App'),
        content: const Text(
            'This will clear all cached data and habits. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (mounted) {
      context.read<SettingsProvider>().resetApp();
      _showSnack('App data cleared.');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (danger ? AppColors.red : iconColor).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: danger ? AppColors.red : iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? AppColors.red : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
