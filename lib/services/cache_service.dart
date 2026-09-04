import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../models/contribution_day.dart';

class CacheService {
  static const String _userKey = 'cached_user';
  static const String _reposKey = 'cached_repos';
  static const String _contributionsKey = 'cached_contributions';
  static const String _timestampSuffix = '_ts';
  static const int _ttlMinutes = 30;

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('cache');
  }

  bool _isExpired(String key) {
    final ts = _box.get('$key$_timestampSuffix');
    if (ts == null) return true;
    final saved = DateTime.parse(ts as String);
    return DateTime.now().difference(saved).inMinutes > _ttlMinutes;
  }

  void _updateTimestamp(String key) {
    _box.put('$key$_timestampSuffix', DateTime.now().toIso8601String());
  }

  // User cache
  Future<void> saveUser(GitHubUser user) async {
    _box.put(_userKey, jsonEncode({
      'login': user.login,
      'name': user.name,
      'avatar_url': user.avatarUrl,
      'bio': user.bio,
      'company': user.company,
      'blog': user.blog,
      'location': user.location,
      'html_url': user.htmlUrl,
      'public_repos': user.publicRepos,
      'followers': user.followers,
      'following': user.following,
    }));
    _updateTimestamp(_userKey);
  }

  GitHubUser? getCachedUser() {
    if (_isExpired(_userKey)) return null;
    final raw = _box.get(_userKey);
    if (raw == null) return null;
    return GitHubUser.fromJson(jsonDecode(raw as String));
  }

  // Repos cache
  Future<void> saveRepos(List<GitHubRepo> repos) async {
    _box.put(
      _reposKey,
      jsonEncode(repos
          .map((r) => {
                'name': r.name,
                'description': r.description,
                'html_url': r.htmlUrl,
                'stargazers_count': r.stars,
                'forks_count': r.forks,
                'open_issues_count': r.openIssues,
                'language': r.language,
                'default_branch': r.defaultBranch,
                'pushed_at': r.pushedAt?.toIso8601String(),
                'private': r.isPrivate,
              })
          .toList()),
    );
    _updateTimestamp(_reposKey);
  }

  List<GitHubRepo>? getCachedRepos() {
    if (_isExpired(_reposKey)) return null;
    final raw = _box.get(_reposKey);
    if (raw == null) return null;
    final List data = jsonDecode(raw as String);
    return data.map((r) => GitHubRepo.fromJson(r as Map<String, dynamic>)).toList();
  }

  // Contributions cache
  Future<void> saveContributions(List<ContributionDay> days) async {
    _box.put(
      _contributionsKey,
      jsonEncode(days.map((d) => d.toJson()).toList()),
    );
    _updateTimestamp(_contributionsKey);
  }

  List<ContributionDay>? getCachedContributions() {
    if (_isExpired(_contributionsKey)) return null;
    final raw = _box.get(_contributionsKey);
    if (raw == null) return null;
    final List data = jsonDecode(raw as String);
    return data
        .map((d) => ContributionDay.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  void clearAll() {
    _box.clear();
  }
}
