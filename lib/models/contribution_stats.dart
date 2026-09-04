class ContributionStats {
  final int currentStreak;
  final int longestStreak;
  final int weeklyCommits;
  final int monthlyCommits;
  final int totalContributions;

  const ContributionStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.weeklyCommits = 0,
    this.monthlyCommits = 0,
    this.totalContributions = 0,
  });

  static const ContributionStats empty = ContributionStats();
}
