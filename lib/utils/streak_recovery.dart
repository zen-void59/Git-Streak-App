import 'package:hive/hive.dart';
import '../models/contribution_day.dart';

/// Manages streak recovery logic.
///
/// Recovery Rules:
/// - Users get 1 free miss per 7-day streak milestone
/// - Recovery can be used if user committed yesterday but not today
/// - Recovery count resets every 7 streak days
class StreakRecovery {
  static const String _recoveryEnabledKey = 'streak_recovery_enabled';
  static const String _lastRecoveryDateKey = 'last_recovery_date';

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if streak recovery is enabled
  static bool isEnabled() {
    final settings = Hive.box('settings');
    return settings.get(_recoveryEnabledKey, defaultValue: true) as bool;
  }

  /// Toggle streak recovery
  static Future<void> setEnabled(bool enabled) async {
    final settings = Hive.box('settings');
    await settings.put(_recoveryEnabledKey, enabled);
  }

  /// Check if recovery has been used today
  static bool isRecoveryUsedToday() {
    final settings = Hive.box('settings');
    final lastUsed = settings.get(_lastRecoveryDateKey) as String?;
    if (lastUsed == null) return false;

    final lastDate = DateTime.tryParse(lastUsed);
    if (lastDate == null) return false;

    return _isSameDay(lastDate, DateTime.now());
  }

  /// Check if user is eligible for recovery.
  ///
  /// Eligibility:
  /// - Recovery is enabled
  /// - Today has no contributions (or no data for today)
  /// - Yesterday has contributions
  /// - Current streak is at least 1 day
  /// - Recovery hasn't been used today
  static bool isEligible(List<ContributionDay> days, int currentStreak) {
    if (!isEnabled()) return false;
    if (isRecoveryUsedToday()) return false;
    if (currentStreak < 1) return false;

    final today = DateTime.now();

    // Check if today has contributions
    final todayContributions = days.where((d) => _isSameDay(d.date, today));

    // If today has contributions, no need for recovery
    if (todayContributions.isNotEmpty &&
        todayContributions.first.count > 0) {
      return false;
    }

    // Check if yesterday has contributions
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayContributions =
        days.where((d) => _isSameDay(d.date, yesterday));

    // Must have contributions yesterday to be eligible
    return yesterdayContributions.isNotEmpty &&
        yesterdayContributions.first.count > 0;
  }

  /// Use recovery for today
  static Future<void> useRecovery() async {
    final settings = Hive.box('settings');
    final today = DateTime.now();
    await settings.put(
        _lastRecoveryDateKey, today.toIso8601String());
  }

  /// Get recovery status message
  static String getStatusMessage(
      List<ContributionDay> days, int currentStreak) {
    if (!isEnabled()) {
      return 'Streak recovery is disabled';
    }
    if (isRecoveryUsedToday()) {
      return 'Recovery already used today';
    }
    if (currentStreak < 1) {
      return 'Start a streak to unlock recovery';
    }
    if (isEligible(days, currentStreak)) {
      return 'Recovery available! Save your streak';
    }
    return 'Commit today to keep your streak';
  }
}
