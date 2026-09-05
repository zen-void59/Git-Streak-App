import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../providers/dashboard_provider.dart';
import '../services/github_service.dart';
import '../services/cache_service.dart';
import '../utils/constants.dart';
import '../widgets/repo_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _cache = CacheService();
  final _service = GitHubService();

  GitHubUser? _user;
  List<GitHubRepo> _repos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _cache.init();
      final box = Hive.box('settings');
      final username = box.get('github_username', defaultValue: '') as String;

      // Ensure token is set for authenticated API calls
      if (!mounted) return;
      final dashboard = context.read<DashboardProvider>();
      if (dashboard.user != null) {
        // Reuse dashboard data if available
        setState(() {
          _user = dashboard.user;
          _repos = dashboard.repos;
          _loading = false;
          _error = null;
        });
        return;
      }

      var user = _cache.getCachedUser();
      var repos = _cache.getCachedRepos();

      if (user == null) {
        user = await _service.fetchUser(username);
        if (user != null) await _cache.saveUser(user);
      }
      if (repos == null) {
        repos = await _service.fetchRepositories(username, perPage: 30);
        if (repos.isNotEmpty) await _cache.saveRepos(repos);
      }

      if (mounted) {
        setState(() {
          _user = user;
          _repos = repos ?? [];
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load profile. Pull to refresh.';
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareProfile() {
    final dashboard = context.read<DashboardProvider>();
    ProfileCard.shareProfile(
      user: dashboard.user,
      stats: dashboard.stats,
    );
  }

  List<GitHubRepo> get _topRepos {
    final sorted = [..._repos]..sort((a, b) => b.stars.compareTo(a.stars));
    return sorted.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/compare'),
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Compare Developers',
          ),
          IconButton(
            onPressed: _shareProfile,
            icon: const Icon(Icons.share),
            tooltip: 'Share Profile',
          ),
          IconButton(
            onPressed: () {
              if (_user != null) _launchUrl(_user!.htmlUrl);
            },
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: 'Open on GitHub',
          ),
        ],
      ),
      body: _loading
          ? const DashboardSkeleton()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() { _loading = true; _error = null; });
                          _loadData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _cache.clearAll();
                    setState(() => _loading = true);
                    await _loadData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeader(user: _user, onLaunch: _launchUrl),
                        const SizedBox(height: 20),
                        _StatsRow(user: _user),
                        const SizedBox(height: 24),
                        if (_topRepos.isNotEmpty) ...[
                          const Text('Top Repositories',
                              style: AppTextStyles.headline3),
                          const SizedBox(height: 12),
                          ..._topRepos.map((r) => RepoCard(
                                repo: r,
                                onTap: () => _launchUrl(r.htmlUrl),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────
// Profile header card
// ─────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final GitHubUser? user;
  final Future<void> Function(String) onLaunch;

  const _ProfileHeader({required this.user, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.surface,
              backgroundImage: user != null
                  ? CachedNetworkImageProvider(user!.avatarUrl)
                  : null,
              child:
                  user == null ? const Icon(Icons.person, size: 40) : null,
            ),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            user?.name.isNotEmpty == true ? user!.name : user?.login ?? 'User',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 4),
          Text(
            '@${user?.login ?? ''}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          // Bio
          if (user?.bio != null && user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              user!.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
          const SizedBox(height: 14),
          // Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user?.location != null) ...[
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textMuted, size: 14),
                const SizedBox(width: 4),
                Text(user!.location!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 16),
              ],
              if (user?.company != null) ...[
                const Icon(Icons.business_outlined,
                    color: AppColors.textMuted, size: 14),
                const SizedBox(width: 4),
                Text(user!.company!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ],
          ),
          if (user?.blog != null && user!.blog!.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => onLaunch(user!.blog!.startsWith('http')
                  ? user!.blog!
                  : 'https://${user!.blog}'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    user!.blog!,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final GitHubUser? user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: AppDecorations.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(
            label: 'Repos',
            value: '${user?.publicRepos ?? 0}',
            color: AppColors.primary,
          ),
          _StatColumn(
            label: 'Followers',
            value: '${user?.followers ?? 0}',
            color: AppColors.blue,
          ),
          _StatColumn(
            label: 'Following',
            value: '${user?.following ?? 0}',
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatColumn(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}
