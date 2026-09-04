import '../models/contribution_day.dart';

class StreakCalculator {
  /// Returns the current streak (consecutive days ending today or yesterday).
  static int calculateCurrentStreak(List<ContributionDay> days) {
    if (days.isEmpty) return 0;

    // Sort descending
    final sorted = [...days]..sort((a, b) => b.date.compareTo(a.date));
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Streak must include today or yesterday to be "current"
    if (sorted.first.count == 0) return 0;
    final firstDate = _dateOnly(sorted.first.date);
    if (firstDate != today && firstDate != yesterday) return 0;

    int streak = 0;
    DateTime expected = firstDate;

    for (final day in sorted) {
      final d = _dateOnly(day.date);
      if (d == expected && day.count > 0) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (d == expected && day.count == 0) {
        break;
      } else if (d.isBefore(expected)) {
        break;
      }
    }
    return streak;
  }

  /// Returns the longest ever streak.
  static int calculateLongestStreak(List<ContributionDay> days) {
    if (days.isEmpty) return 0;
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));

    int longest = 0;
    int current = 0;
    DateTime? prev;

    for (final day in sorted) {
      if (day.count > 0) {
        if (prev == null ||
            _dateOnly(day.date).difference(_dateOnly(prev)).inDays == 1) {
          current++;
        } else {
          current = 1;
        }
        if (current > longest) longest = current;
        prev = day.date;
      } else {
        current = 0;
        prev = null;
      }
    }
    return longest;
  }

  /// Total contributions in the list.
  static int totalContributions(List<ContributionDay> days) {
    return days.fold(0, (sum, d) => sum + d.count);
  }

  /// Commits in the last 7 days.
  static int weeklyCommits(List<ContributionDay> days) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return days
        .where((d) => d.date.isAfter(cutoff))
        .fold(0, (sum, d) => sum + d.count);
  }

  /// Commits in the last 30 days.
  static int monthlyCommits(List<ContributionDay> days) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return days
        .where((d) => d.date.isAfter(cutoff))
        .fold(0, (sum, d) => sum + d.count);
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
