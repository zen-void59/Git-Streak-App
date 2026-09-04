import 'package:hive/hive.dart';
import '../models/contribution_day.dart';
import '../models/contribution_stats.dart';

class WeeklyDigest {
  static const String _lastDigestDateKey = 'last_digest_date';
  static const String _digestEnabledKey = 'weekly_digest_enabled';

  static bool isEnabled() {
    final settings = Hive.box('settings');
    return settings.get(_digestEnabledKey, defaultValue: true);
  }

  static Future<void> setEnabled(bool enabled) async {
    final settings = Hive.box('settings');
    await settings.put(_digestEnabledKey, enabled);
  }

  /// Get the last date a digest was sent
  static DateTime? getLastDigestDate() {
    final settings = Hive.box('settings');
    final dateStr = settings.get(_lastDigestDateKey);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  /// Mark digest as sent
  static Future<void> markDigestSent() async {
    final settings = Hive.box('settings');
    await settings.put(_lastDigestDateKey, DateTime.now().toIso8601String());
  }

  /// Check if digest should be sent (every Sunday)
  static bool shouldSendDigest() {
    if (!isEnabled()) return false;

    final lastDigest = getLastDigestDate();
    final now = DateTime.now();

    // Only send on Sunday
    if (now.weekday != DateTime.sunday) return false;

    // Don't send if already sent today
    if (lastDigest != null) {
      if (lastDigest.year == now.year &&
          lastDigest.month == now.month &&
          lastDigest.day == now.day) {
        return false;
      }
    }

    return true;
  }

  /// Generate weekly digest content
  static WeeklyDigestData generateDigest({
    required List<ContributionDay> contributions,
    required ContributionStats stats,
  }) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Get this week's contributions
    final weekContributions = contributions.where((day) {
      return day.date.isAfter(weekAgo);
    }).toList();

    final weeklyTotal = weekContributions.fold<int>(0, (sum, day) => sum + day.count);
    final daysActive = weekContributions.where((d) => d.count > 0).length;
    final bestDay = weekContributions.isNotEmpty
        ? weekContributions.reduce((a, b) =>
            a.count > b.count ? a : b)
        : null;

    // Calculate streak impact
    final hadMissedDays = weekContributions.any((d) => d.count == 0);

    return WeeklyDigestData(
      weeklyTotal: weeklyTotal,
      daysActive: daysActive,
      bestDayContribution: bestDay?.count ?? 0,
      bestDayName: _getDayName(bestDay?.date),
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      hadMissedDays: hadMissedDays,
      message: _generateMessage(weeklyTotal, daysActive, hadMissedDays),
    );
  }

  static String _getDayName(DateTime? date) {
    if (date == null) return 'N/A';
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  static String _generateMessage(int total, int daysActive, bool hadMissed) {
    if (total >= 50) {
      return 'Incredible week! You crushed it with $total contributions!';
    } else if (total >= 20) {
      return 'Strong week with $total contributions. Keep it up!';
    } else if (total >= 10) {
      return 'Decent week. Try to push for more next week!';
    } else if (daysActive >= 5) {
      return 'Consistent this week! Small steps lead to big results.';
    } else if (hadMissed) {
      return 'You missed some days. Use recovery if needed!';
    } else {
      return 'Keep building your streak. Every commit counts!';
    }
  }

  /// Generate the notification title
  static String getNotificationTitle(int weeklyTotal) {
    if (weeklyTotal >= 50) {
      return 'Legendary Week!';
    } else if (weeklyTotal >= 20) {
      return 'Strong Week!';
    } else if (weeklyTotal >= 10) {
      return 'Weekly Recap';
    } else {
      return 'Weekly Digest';
    }
  }
}

class WeeklyDigestData {
  final int weeklyTotal;
  final int daysActive;
  final int bestDayContribution;
  final String bestDayName;
  final int currentStreak;
  final int longestStreak;
  final bool hadMissedDays;
  final String message;

  const WeeklyDigestData({
    required this.weeklyTotal,
    required this.daysActive,
    required this.bestDayContribution,
    required this.bestDayName,
    required this.currentStreak,
    required this.longestStreak,
    required this.hadMissedDays,
    required this.message,
  });
}
