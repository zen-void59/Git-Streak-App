import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/github_user.dart';
import '../models/contribution_day.dart';
import '../models/contribution_stats.dart';
import '../providers/dashboard_provider.dart';
import '../services/github_service.dart';
import '../utils/streak_calculator.dart';
import '../utils/constants.dart';
import '../widgets/developer_comparison.dart';
import '../widgets/skeleton_loader.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  GitHubUser? _otherUser;
  ContributionStats? _otherStats;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _compare() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Enter a username');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = context.read<GitHubService>();

      // Fetch user data and contributions
      final results = await Future.wait([
        service.fetchUser(username),
        service.fetchContributions(username),
      ]);

      final user = results[0] as GitHubUser?;
      final contributions = results[1] as List<ContributionDay>;

      if (user == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Calculate stats
      final stats = ContributionStats(
        currentStreak: StreakCalculator.calculateCurrentStreak(contributions),
        longestStreak: StreakCalculator.calculateLongestStreak(contributions),
        weeklyCommits: StreakCalculator.weeklyCommits(contributions),
        monthlyCommits: StreakCalculator.monthlyCommits(contributions),
        totalContributions: StreakCalculator.totalContributions(contributions),
      );

      setState(() {
        _otherUser = user;
        _otherStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Compare Developers'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter GitHub username',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                onSubmitted: (_) => _compare(),
              ),
              const SizedBox(height: 16),

              // Compare button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _compare,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.compare_arrows, size: 18),
                  label: Text(_isLoading ? 'Comparing...' : 'Compare'),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const DashboardSkeleton(),
              ],

              // Comparison result
              if (_otherUser != null && _otherStats != null) ...[
                const SizedBox(height: 24),
                Consumer<DashboardProvider>(
                  builder: (context, dashboard, _) {
                    return DeveloperComparison(
                      user1: dashboard.user,
                      stats1: dashboard.stats,
                      user2: _otherUser,
                      stats2: _otherStats!,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Winner banner
                Consumer<DashboardProvider>(
                  builder: (context, dashboard, _) {
                    final winner = DeveloperComparison.getWinner(
                      dashboard.stats,
                      _otherStats!,
                    );

                    String message;
                    Color color;
                    IconData icon;

                    if (winner == 0) {
                      message = "It's a tie! Both devs are awesome";
                      color = AppColors.primary;
                      icon = Icons.handshake;
                    } else if (winner == 1) {
                      message = 'You lead in overall stats!';
                      color = AppColors.primary;
                      icon = Icons.emoji_events;
                    } else {
                      message = '${_otherUser!.login} leads in overall stats!';
                      color = AppColors.amber;
                      icon = Icons.emoji_events;
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              // Empty state
              if (_otherUser == null && !_isLoading && _error == null) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 64,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Compare your stats with any GitHub developer',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
