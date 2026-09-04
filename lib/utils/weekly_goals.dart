import 'package:hive/hive.dart';

/// Manages custom weekly commit goals.
///
/// Users can set their own weekly commit targets.
/// Progress is tracked and displayed on the dashboard.
class WeeklyGoals {
  static const String _weeklyGoalKey = 'weekly_commit_goal';
  static const String _weeklyGoalEnabledKey = 'weekly_goal_enabled';

  /// Default weekly goal
  static const int defaultGoal = 7;

  /// Get the user's weekly goal
  static int getGoal() {
    final settings = Hive.box('settings');
    return settings.get(_weeklyGoalKey, defaultValue: defaultGoal) as int;
  }

  /// Set the weekly goal (1-50 commits)
  static Future<void> setGoal(int goal) async {
    final settings = Hive.box('settings');
    final clampedGoal = goal.clamp(1, 50);
    await settings.put(_weeklyGoalKey, clampedGoal);
  }

  /// Check if weekly goal tracking is enabled
  static bool isEnabled() {
    final settings = Hive.box('settings');
    return settings.get(_weeklyGoalEnabledKey, defaultValue: true) as bool;
  }

  /// Toggle weekly goal tracking
  static Future<void> setEnabled(bool enabled) async {
    final settings = Hive.box('settings');
    await settings.put(_weeklyGoalEnabledKey, enabled);
  }

  /// Calculate progress towards the weekly goal
  /// Returns a value between 0.0 and 1.0
  static double getProgress(int weeklyCommits) {
    final goal = getGoal();
    if (goal <= 0) return 0.0;
    return (weeklyCommits / goal).clamp(0.0, 1.0);
  }

  /// Check if weekly goal is met
  static bool isGoalMet(int weeklyCommits) {
    return weeklyCommits >= getGoal();
  }

  /// Get remaining commits needed for the goal
  static int getRemaining(int weeklyCommits) {
    final goal = getGoal();
    final remaining = goal - weeklyCommits;
    return remaining > 0 ? remaining : 0;
  }

  /// Get goal status message
  static String getStatusMessage(int weeklyCommits) {
    if (!isEnabled()) return '';
    
    final remaining = getRemaining(weeklyCommits);

    if (remaining == 0) {
      return 'Weekly goal met!';
    } else {
      return '$remaining more commits this week';
    }
  }

  /// Get suggested goals based on user's history
  static List<int> getSuggestedGoals(int avgWeeklyCommits) {
    if (avgWeeklyCommits <= 3) return [3, 5, 7];
    if (avgWeeklyCommits <= 7) return [5, 7, 10];
    if (avgWeeklyCommits <= 14) return [7, 10, 14];
    return [10, 14, 21];
  }
}
