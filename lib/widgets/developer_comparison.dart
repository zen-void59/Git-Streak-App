import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/github_user.dart';
import '../models/contribution_stats.dart';
import '../utils/constants.dart';

class DeveloperComparison extends StatelessWidget {
  final GitHubUser? user1;
  final ContributionStats stats1;
  final GitHubUser? user2;
  final ContributionStats stats2;

  const DeveloperComparison({
    super.key,
    required this.user1,
    required this.stats1,
    required this.user2,
    required this.stats2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare_arrows, color: AppColors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Developer Comparison',
                style: AppTextStyles.headline3,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header row
          Row(
            children: [
              Expanded(child: _UserHeader(user: user1, isLeft: true)),
              const SizedBox(width: 8),
              const Text('VS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(width: 8),
              Expanded(child: _UserHeader(user: user2, isLeft: false)),
            ],
          ),
          const SizedBox(height: 16),

          // Stats comparison
          _ComparisonRow(
            label: 'Current Streak',
            value1: '${stats1.currentStreak}',
            value2: '${stats2.currentStreak}',
            color1: AppColors.primary,
            color2: AppColors.primary,
          ),
          const SizedBox(height: 12),

          _ComparisonRow(
            label: 'Longest Streak',
            value1: '${stats1.longestStreak}',
            value2: '${stats2.longestStreak}',
            color1: AppColors.amber,
            color2: AppColors.amber,
          ),
          const SizedBox(height: 12),

          _ComparisonRow(
            label: 'Total Contributions',
            value1: '${stats1.totalContributions}',
            value2: '${stats2.totalContributions}',
            color1: AppColors.blue,
            color2: AppColors.blue,
          ),
          const SizedBox(height: 12),

          _ComparisonRow(
            label: 'This Week',
            value1: '${stats1.weeklyCommits}',
            value2: '${stats2.weeklyCommits}',
            color1: AppColors.primary,
            color2: AppColors.primary,
          ),
          const SizedBox(height: 12),

          _ComparisonRow(
            label: 'This Month',
            value1: '${stats1.monthlyCommits}',
            value2: '${stats2.monthlyCommits}',
            color1: AppColors.purple,
            color2: AppColors.purple,
          ),
        ],
      ),
    );
  }

  /// Determine which user wins based on combined stats
  static int getWinner(ContributionStats stats1, ContributionStats stats2) {
    int score1 = 0;
    int score2 = 0;

    if (stats1.currentStreak > stats2.currentStreak) score1++;
    if (stats2.currentStreak > stats1.currentStreak) score2++;

    if (stats1.longestStreak > stats2.longestStreak) score1++;
    if (stats2.longestStreak > stats1.longestStreak) score2++;

    if (stats1.totalContributions > stats2.totalContributions) score1++;
    if (stats2.totalContributions > stats1.totalContributions) score2++;

    if (score1 > score2) return 1;
    if (score2 > score1) return 2;
    return 0; // tie
  }
}

class _UserHeader extends StatelessWidget {
  final GitHubUser? user;
  final bool isLeft;

  const _UserHeader({required this.user, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isLeft ? AppColors.primary : AppColors.purple,
              width: 2,
            ),
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
        const SizedBox(height: 6),
        Text(
          user?.login ?? 'User',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value1;
  final String value2;
  final Color color1;
  final Color color2;

  const _ComparisonRow({
    required this.label,
    required this.value1,
    required this.value2,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    final v1 = int.tryParse(value1) ?? 0;
    final v2 = int.tryParse(value2) ?? 0;
    final winner = v1 > v2 ? 1 : (v2 > v1 ? 2 : 0);

    return Row(
      children: [
        // User 1 value
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: winner == 1
                  ? color1.withValues(alpha: 0.15)
                  : AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: winner == 1
                  ? Border.all(color: color1.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (winner == 1) ...[
                  Icon(Icons.emoji_events, color: color1, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  value1,
                  style: TextStyle(
                    color: winner == 1 ? color1 : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // User 2 value
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: winner == 2
                  ? color2.withValues(alpha: 0.15)
                  : AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: winner == 2
                  ? Border.all(color: color2.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value2,
                  style: TextStyle(
                    color: winner == 2 ? color2 : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (winner == 2) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.emoji_events, color: color2, size: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
