class XpCalculator {
  // XP per action
  static const int xpPerCommit = 10;
  static const int xpPerHabitCompletion = 20;
  static const int xpStreakBonus = 50; // per 7-day streak milestone
  static const int xpWeeklyGoal = 100; // bonus for 7+ commits/week

  // Level thresholds
  static const List<int> levelThresholds = [
    0,     // L1
    500,   // L2
    1500,  // L3
    3000,  // L4
    5000,  // L5
    8000,  // L6
    12000, // L7
    18000, // L8
    25000, // L9
    35000, // L10
  ];

  static const List<String> levelTitles = [
    'Novice',
    'Apprentice',
    'Developer',
    'Engineer',
    'Senior Engineer',
    'Tech Lead',
    'Architect',
    'Principal',
    'Distinguished',
    'Fellow',
  ];

  static int computeXpFromCommits(int totalCommits) {
    return totalCommits * xpPerCommit;
  }

  static int computeXpFromHabits(int completedHabits) {
    return completedHabits * xpPerHabitCompletion;
  }

  static int streakBonusXp(int currentStreak) {
    return (currentStreak ~/ 7) * xpStreakBonus;
  }

  static int totalXp({
    int totalCommits = 0,
    required int completedHabits,
    required int currentStreak,
    int weeklyCommits = 0,
  }) {
    int xp = 100 + computeXpFromCommits(totalCommits) +
        computeXpFromHabits(completedHabits) +
        streakBonusXp(currentStreak);
    if (weeklyCommits >= 7) xp += xpWeeklyGoal;
    return xp;
  }

  static int levelFromXp(int xp) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (xp >= levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  static String titleFromXp(int xp) {
    final lvl = levelFromXp(xp);
    return levelTitles[(lvl - 1).clamp(0, levelTitles.length - 1)];
  }

  /// Progress (0.0–1.0) within current level.
  static double progressInLevel(int xp) {
    final level = levelFromXp(xp);
    final idx = (level - 1).clamp(0, levelThresholds.length - 1);
    final currentFloor = levelThresholds[idx];
    final nextFloor = level < levelThresholds.length
        ? levelThresholds[idx + 1]
        : currentFloor + 10000;
    if (nextFloor == currentFloor) return 1.0;
    return ((xp - currentFloor) / (nextFloor - currentFloor)).clamp(0.0, 1.0);
  }

  static int xpToNextLevel(int xp) {
    final level = levelFromXp(xp);
    final idx = (level - 1).clamp(0, levelThresholds.length - 1);
    final nextFloor = level < levelThresholds.length
        ? levelThresholds[idx + 1]
        : levelThresholds[idx] + 10000;
    return (nextFloor - xp).clamp(0, 999999);
  }

  static List<String> computeBadges({
    required int currentStreak,
    required int longestStreak,
    required int totalContributions,
    required int totalXp,
    required int completedHabits,
  }) {
    final badges = <String>[];

    if (currentStreak >= 7) badges.add('🔥 Week Warrior');
    if (currentStreak >= 30) badges.add('💎 Month Master');
    if (longestStreak >= 100) badges.add('🏆 Century Streak');
    if (totalContributions >= 365) badges.add('📅 Year of Code');
    if (totalContributions >= 1000) badges.add('⚡ 1K Commits');
    if (totalXp >= 5000) badges.add('🚀 XP Chaser');
    if (completedHabits >= 50) badges.add('✅ Habit Hero');

    return badges;
  }
}
