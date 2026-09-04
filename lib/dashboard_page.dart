import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/github_user.dart';
import '../providers/dashboard_provider.dart';
import '../utils/constants.dart';
import '../widgets/contribution_heatmap.dart';
import '../widgets/streak_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/repo_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_view.dart';
import '../widgets/goal_progress_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showRecoveryDialog(BuildContext context, DashboardProvider dashboard) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.shield, color: AppColors.amber, size: 24),
            SizedBox(width: 10),
            Text('Streak Recovery'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use your daily streak recovery to save your current streak?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current streak: ${dashboard.stats.currentStreak} days',
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.shield, size: 16),
            label: const Text('Use Recovery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              dashboard.useRecovery();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Streak saved! Keep coding today.'),
                  backgroundColor: AppColors.cardBg,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  backgroundImage: dashboard.user != null
                      ? CachedNetworkImageProvider(dashboard.user!.avatarUrl)
                      : null,
                  child: dashboard.user == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
              ),
            ),
            title: const Text('Moss'),
            actions: [
              IconButton(
                onPressed: () => dashboard.refresh(),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => dashboard.refresh(),
            child: _buildBody(dashboard),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardProvider dashboard) {
    if (dashboard.isLoading) {
      return const DashboardSkeleton();
    }

    if (dashboard.hasError) {
      return ErrorView(
        message: dashboard.errorMessage ?? 'Something went wrong',
        onRetry: () => dashboard.refresh(),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileCard(user: dashboard.user),
          const SizedBox(height: 20),

          // Streak & stats cards
          Row(
            children: [
              Expanded(
                child: StreakCard(
                  value: dashboard.stats.currentStreak,
                  label: 'Current\nStreak',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreakCard(
                  value: dashboard.stats.longestStreak,
                  label: 'Longest\nStreak',
                  icon: Icons.emoji_events,
                  iconColor: AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.blue,
                  label: 'This\nWeek',
                  value: '${dashboard.stats.weeklyCommits}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppColors.purple,
                  label: 'This Month',
                  value: '${dashboard.stats.monthlyCommits}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.commit,
                  iconColor: AppColors.primary,
                  label: 'Total (365d)',
                  value: '${dashboard.stats.totalContributions}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly Goal Progress
          GoalProgressCard(
            weeklyCommits: dashboard.stats.weeklyCommits,
            showRecovery: dashboard.isRecoveryEnabled,
            isRecoveryEligible: dashboard.isRecoveryEligible,
            recoveryMessage: dashboard.recoveryMessage,
            onRecoveryTap: () => _showRecoveryDialog(context, dashboard),
          ),
          const SizedBox(height: 24),

          // Heatmap section
          const Text('Contribution Activity',
              style: AppTextStyles.headline3),
          const SizedBox(height: 4),
          const Text('Last 365 days of GitHub activity',
              style: AppTextStyles.body),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: dashboard.contributions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No contribution data found.\nMake sure the username is correct.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ContributionHeatmap(days: dashboard.contributions),
          ),
          const SizedBox(height: 24),

          // Repositories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Repositories',
                  style: AppTextStyles.headline3),
              TextButton(
                onPressed: () {
                  if (dashboard.user != null) {
                    _openUrl(
                        'https://github.com/${dashboard.user!.login}?tab=repositories');
                  }
                },
                child: const Text('View All',
                    style: AppTextStyles.labelGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dashboard.repos.take(10).map((repo) => RepoCard(
                repo: repo,
                onTap: () => _openUrl(repo.htmlUrl),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Profile header card
// ─────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final GitHubUser? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surface,
            backgroundImage: user != null
                ? CachedNetworkImageProvider(user!.avatarUrl)
                : null,
            child: user == null ? const Icon(Icons.person, size: 32) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name.isNotEmpty == true
                      ? user!.name
                      : user?.login ?? 'User',
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.login ?? ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.bio!,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SmallStat(label: 'Repos', value: '${user?.publicRepos ?? 0}'),
              const SizedBox(height: 6),
              _SmallStat(label: 'Followers', value: '${user?.followers ?? 0}'),
              const SizedBox(height: 6),
              _SmallStat(label: 'Following', value: '${user?.following ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  const _SmallStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}
