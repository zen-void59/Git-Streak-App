import 'package:flutter_test/flutter_test.dart';
import 'package:moss_app/models/contribution_day.dart';
import 'package:moss_app/utils/streak_calculator.dart';

void main() {
  group('StreakCalculator', () {
    group('calculateCurrentStreak', () {
      test('returns 0 for empty list', () {
        expect(StreakCalculator.calculateCurrentStreak([]), 0);
      });

      test('returns 0 when last day has no contributions', () {
        final days = [
          ContributionDay(date: DateTime.now().subtract(const Duration(days: 2)), count: 5),
          ContributionDay(date: DateTime.now().subtract(const Duration(days: 1)), count: 0),
        ];
        expect(StreakCalculator.calculateCurrentStreak(days), 0);
      });

      test('returns 1 for single day contribution today', () {
        final days = [
          ContributionDay(date: DateTime.now(), count: 3),
        ];
        expect(StreakCalculator.calculateCurrentStreak(days), 1);
      });

      test('returns 2 for consecutive days', () {
        final now = DateTime.now();
        final days = [
          ContributionDay(date: now, count: 3),
          ContributionDay(date: now.subtract(const Duration(days: 1)), count: 2),
        ];
        expect(StreakCalculator.calculateCurrentStreak(days), 2);
      });

      test('returns 0 when streak is broken', () {
        final now = DateTime.now();
        final days = [
          ContributionDay(date: now, count: 3),
          ContributionDay(date: now.subtract(const Duration(days: 1)), count: 0),
          ContributionDay(date: now.subtract(const Duration(days: 2)), count: 5),
        ];
        expect(StreakCalculator.calculateCurrentStreak(days), 0);
      });

      test('returns streak count for 7 consecutive days', () {
        final now = DateTime.now();
        final days = List.generate(7, (i) {
          return ContributionDay(
            date: now.subtract(Duration(days: i)),
            count: i + 1,
          );
        });
        expect(StreakCalculator.calculateCurrentStreak(days), 7);
      });
    });

    group('calculateLongestStreak', () {
      test('returns 0 for empty list', () {
        expect(StreakCalculator.calculateLongestStreak([]), 0);
      });

      test('returns 1 for single day contribution', () {
        final days = [
          ContributionDay(date: DateTime.now(), count: 3),
        ];
        expect(StreakCalculator.calculateLongestStreak(days), 1);
      });

      test('returns correct longest streak with gaps', () {
        final now = DateTime.now();
        final days = [
          // Streak of 3
          ContributionDay(date: now, count: 1),
          ContributionDay(date: now.subtract(const Duration(days: 1)), count: 1),
          ContributionDay(date: now.subtract(const Duration(days: 2)), count: 1),
          // Gap
          ContributionDay(date: now.subtract(const Duration(days: 3)), count: 0),
          // Streak of 2
          ContributionDay(date: now.subtract(const Duration(days: 4)), count: 1),
          ContributionDay(date: now.subtract(const Duration(days: 5)), count: 1),
        ];
        expect(StreakCalculator.calculateLongestStreak(days), 3);
      });

      test('returns 5 for 5 consecutive days', () {
        final now = DateTime.now();
        final days = List.generate(5, (i) {
          return ContributionDay(
            date: now.subtract(Duration(days: i)),
            count: 1,
          );
        });
        expect(StreakCalculator.calculateLongestStreak(days), 5);
      });
    });

    group('totalContributions', () {
      test('returns 0 for empty list', () {
        expect(StreakCalculator.totalContributions([]), 0);
      });

      test('returns sum of all contributions', () {
        final days = [
          ContributionDay(date: DateTime.now(), count: 5),
          ContributionDay(date: DateTime.now().subtract(const Duration(days: 1)), count: 3),
          ContributionDay(date: DateTime.now().subtract(const Duration(days: 2)), count: 2),
        ];
        expect(StreakCalculator.totalContributions(days), 10);
      });
    });

    group('weeklyCommits', () {
      test('returns 0 for empty list', () {
        expect(StreakCalculator.weeklyCommits([]), 0);
      });

      test('returns commits from last 7 days', () {
        final now = DateTime.now();
        final days = [
          ContributionDay(date: now, count: 5),
          ContributionDay(date: now.subtract(const Duration(days: 3)), count: 3),
          ContributionDay(date: now.subtract(const Duration(days: 10)), count: 10), // outside range
        ];
        expect(StreakCalculator.weeklyCommits(days), 8);
      });
    });

    group('monthlyCommits', () {
      test('returns 0 for empty list', () {
        expect(StreakCalculator.monthlyCommits([]), 0);
      });

      test('returns commits from last 30 days', () {
        final now = DateTime.now();
        final days = [
          ContributionDay(date: now, count: 5),
          ContributionDay(date: now.subtract(const Duration(days: 15)), count: 3),
          ContributionDay(date: now.subtract(const Duration(days: 45)), count: 100), // outside range
        ];
        expect(StreakCalculator.monthlyCommits(days), 8);
      });
    });
  });
}
