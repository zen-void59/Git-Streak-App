import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../models/contribution_day.dart';
import '../models/contribution_stats.dart';
import '../services/github_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../utils/streak_calculator.dart';
import '../utils/streak_recovery.dart';
import '../utils/weekly_goals.dart';
import '../utils/weekly_digest.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final GitHubService _githubService = GitHubService();
  final AuthService _authService = AuthService();
  final CacheService _cache = CacheService();
  final NotificationService _notificationService = NotificationService();

  DashboardStatus _status = DashboardStatus.initial;
  GitHubUser? _user;
  List<GitHubRepo> _repos = [];
  List<ContributionDay> _contributions = [];
  ContributionStats _stats = ContributionStats.empty;
  String? _errorMessage;

  // Recovery state
  bool _isRecoveryEligible = false;
  String _recoveryMessage = '';

  DashboardStatus get status => _status;
  GitHubUser? get user => _user;
  List<GitHubRepo> get repos => _repos;
  List<ContributionDay> get contributions => _contributions;
  ContributionStats get stats => _stats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get hasError => _status == DashboardStatus.error;

  // Recovery getters
  bool get isRecoveryEligible => _isRecoveryEligible;
  String get recoveryMessage => _recoveryMessage;
  bool get isRecoveryUsedToday => StreakRecovery.isRecoveryUsedToday();
  bool get isRecoveryEnabled => StreakRecovery.isEnabled();

  // Goal getters
  int get weeklyGoal => WeeklyGoals.getGoal();
  bool get isGoalMet => WeeklyGoals.isGoalMet(_stats.weeklyCommits);
  double get goalProgress => WeeklyGoals.getProgress(_stats.weeklyCommits);
  int get goalRemaining => WeeklyGoals.getRemaining(_stats.weeklyCommits);

  DashboardProvider() {
    init();
  }

  Future<void> init() async {
    await _cache.init();
    // Load token from secure storage
    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _githubService.setToken(token);
    }
  }

  String get _username {
    final settings = Hive.box('settings');
    return settings.get('github_username', defaultValue: '') as String;
  }

  Future<void> loadAll({bool forceRefresh = false}) async {
    if (_username.isEmpty) return;

    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cache.init();

      // Ensure token is set
      final token = await _authService.getAccessToken();
      if (token != null) {
        _githubService.setToken(token);
      }

      // Try cache first (unless force refresh)
      GitHubUser? user = forceRefresh ? null : _cache.getCachedUser();
      List<GitHubRepo>? repos = forceRefresh ? null : _cache.getCachedRepos();
      List<ContributionDay>? contributions =
          forceRefresh ? null : _cache.getCachedContributions();

      // Fetch what's missing from API
      // For the authenticated user, use /user endpoint (includes private data)
      if (user == null) {
        user = await _githubService.fetchCurrentUser();
        if (user != null) {
          await _cache.saveUser(user);
          // Update stored username
          final settings = Hive.box('settings');
          await settings.put('github_username', user.login);
        }
      }
      if (repos == null) {
        // Fetch all repos including private
        repos = await _githubService.fetchCurrentUserRepos(perPage: 20);
        if (repos.isNotEmpty) await _cache.saveRepos(repos);
      }
      if (contributions == null) {
        // Fetch contributions including private repo contributions via GraphQL
        contributions = await _githubService.fetchContributions(_username);
        if (contributions.isNotEmpty) {
          await _cache.saveContributions(contributions);
        }
      }

      // Calculate stats
      final stats = ContributionStats(
        currentStreak:
            StreakCalculator.calculateCurrentStreak(contributions),
        longestStreak:
            StreakCalculator.calculateLongestStreak(contributions),
        weeklyCommits: StreakCalculator.weeklyCommits(contributions),
        monthlyCommits: StreakCalculator.monthlyCommits(contributions),
        totalContributions:
            StreakCalculator.totalContributions(contributions),
      );

      // Save stats to settings for XP calculation
      final settings = Hive.box('settings');
      await settings.put('cached_commits', stats.totalContributions);
      await settings.put('current_streak', stats.currentStreak);
      await settings.put('longest_streak', stats.longestStreak);
      await settings.put('weekly_commits', stats.weeklyCommits);

      _user = user;
      _repos = repos;
      _contributions = contributions;
      _stats = stats;

      // Check recovery eligibility
      _updateRecoveryStatus();

      // Check for milestone notifications
      _checkMilestones(stats);

      _status = DashboardStatus.loaded;
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = 'Failed to load data. Check your internet connection.';
    }

    notifyListeners();
  }

  void _updateRecoveryStatus() {
    _isRecoveryEligible = StreakRecovery.isEligible(
      _contributions,
      _stats.currentStreak,
    );
    _recoveryMessage = StreakRecovery.getStatusMessage(
      _contributions,
      _stats.currentStreak,
    );
  }

  void _checkMilestones(ContributionStats stats) {
    // Check streak milestones
    _notificationService.showStreakMilestone(stats.currentStreak);

    // Check commit milestones
    _notificationService.showCommitMilestone(stats.totalContributions);

    // Check weekly digest
    _checkWeeklyDigest();
  }

  void _checkWeeklyDigest() {
    if (WeeklyDigest.shouldSendDigest() && _contributions.isNotEmpty) {
      final digest = WeeklyDigest.generateDigest(
        contributions: _contributions,
        stats: _stats,
      );

      _notificationService.showWeeklyDigest(
        weeklyCommits: digest.weeklyTotal,
        currentStreak: digest.currentStreak,
        goalProgress: (WeeklyGoals.getProgress(digest.weeklyTotal) * 100).toInt(),
      );

      WeeklyDigest.markDigestSent();
    }
  }

  /// Use streak recovery
  Future<void> useRecovery() async {
    if (!_isRecoveryEligible) return;

    await StreakRecovery.useRecovery();
    _isRecoveryEligible = false;
    _recoveryMessage = 'Recovery used for today';

    // Show confirmation notification
    try {
      const androidDetails = AndroidNotificationDetails(
        'streak_recovery',
        'Streak Recovery',
        channelDescription: 'Streak recovery confirmation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await FlutterLocalNotificationsPlugin().show(
        999,
        'Streak Saved!',
        'Your streak is safe for today. Keep coding!',
        details,
      );
    } catch (_) {}

    notifyListeners();
  }

  /// Set weekly goal
  Future<void> setWeeklyGoal(int goal) async {
    await WeeklyGoals.setGoal(goal);
    notifyListeners();
  }

  /// Toggle streak recovery
  Future<void> toggleRecovery(bool enabled) async {
    await StreakRecovery.setEnabled(enabled);
    _updateRecoveryStatus();
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadAll(forceRefresh: true);
  }
}
