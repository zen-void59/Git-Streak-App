import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/github_user.dart';
import '../models/contribution_stats.dart';
import '../utils/constants.dart';

class ProfileCard extends StatelessWidget {
  final GitHubUser? user;
  final ContributionStats stats;

  const ProfileCard({
    super.key,
    required this.user,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: user != null
                      ? CachedNetworkImage(
                          imageUrl: user!.avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.isNotEmpty == true ? user!.name : user?.login ?? 'GitHub User',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${user?.login ?? 'username'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Moss logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'MOSS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Streak stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: '${stats.currentStreak}',
                  label: 'Current',
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                ),
                _StatItem(
                  value: '${stats.longestStreak}',
                  label: 'Longest',
                  color: AppColors.amber,
                  icon: Icons.emoji_events,
                ),
                _StatItem(
                  value: '${stats.totalContributions}',
                  label: 'Total',
                  color: AppColors.primary,
                  icon: Icons.grid_view_rounded,
                ),
                _StatItem(
                  value: '${stats.weeklyCommits}',
                  label: 'This Week',
                  color: AppColors.blue,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          const Text(
            'Built with Moss - Track your streaks',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Share the profile as text (image capture requires native setup)
  static void shareProfile({
    required GitHubUser? user,
    required ContributionStats stats,
  }) {
    final userName = user?.name.isNotEmpty == true ? user!.name : user?.login ?? 'User';
    final text = '🔥 Check out my GitHub streak!\n\n'
        'User: @$userName\n'
        'Current Streak: ${stats.currentStreak} days\n'
        'Longest Streak: ${stats.longestStreak} days\n'
        'Total Contributions: ${stats.totalContributions}\n'
        'This Week: ${stats.weeklyCommits} commits\n\n'
        'Track yours with Moss!';

    Share.share(text);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
