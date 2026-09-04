import 'package:flutter_test/flutter_test.dart';
import 'package:moss_app/utils/xp_calculator.dart';

void main() {
  group('XpCalculator', () {
    group('computeXpFromCommits', () {
      test('returns 0 for 0 commits', () {
        expect(XpCalculator.computeXpFromCommits(0), 0);
      });

      test('returns 10 per commit', () {
        expect(XpCalculator.computeXpFromCommits(5), 50);
        expect(XpCalculator.computeXpFromCommits(10), 100);
      });
    });

    group('computeXpFromHabits', () {
      test('returns 0 for 0 habits', () {
        expect(XpCalculator.computeXpFromHabits(0), 0);
      });

      test('returns 20 per habit completion', () {
        expect(XpCalculator.computeXpFromHabits(3), 60);
        expect(XpCalculator.computeXpFromHabits(5), 100);
      });
    });

    group('streakBonusXp', () {
      test('returns 0 for streak less than 7', () {
        expect(XpCalculator.streakBonusXp(0), 0);
        expect(XpCalculator.streakBonusXp(6), 0);
      });

      test('returns 50 per 7-day streak milestone', () {
        expect(XpCalculator.streakBonusXp(7), 50);
        expect(XpCalculator.streakBonusXp(14), 100);
        expect(XpCalculator.streakBonusXp(21), 150);
      });
    });

    group('totalXp', () {
      test('calculates total XP from all sources', () {
        final xp = XpCalculator.totalXp(
          totalCommits: 10,
          completedHabits: 5,
          currentStreak: 7,
        );
        // 10*10 (commits) + 5*20 (habits) + 50 (streak bonus) = 250
        expect(xp, 250);
      });

      test('adds weekly goal bonus when 7+ commits', () {
        final xp = XpCalculator.totalXp(
          totalCommits: 7,
          completedHabits: 0,
          currentStreak: 0,
          weeklyCommits: 7,
        );
        // 7*10 (commits) + 100 (weekly goal) = 170
        expect(xp, 170);
      });
    });

    group('levelFromXp', () {
      test('returns level 1 for 0 XP', () {
        expect(XpCalculator.levelFromXp(0), 1);
      });

      test('returns level 1 for XP less than 500', () {
        expect(XpCalculator.levelFromXp(499), 1);
      });

      test('returns level 2 for 500 XP', () {
        expect(XpCalculator.levelFromXp(500), 2);
      });

      test('returns correct level for high XP', () {
        expect(XpCalculator.levelFromXp(35000), 10);
      });
    });

    group('titleFromXp', () {
      test('returns Novice for level 1', () {
        expect(XpCalculator.titleFromXp(0), 'Novice');
      });

      test('returns Apprentice for level 2', () {
        expect(XpCalculator.titleFromXp(500), 'Apprentice');
      });

      test('returns Fellow for level 10', () {
        expect(XpCalculator.titleFromXp(35000), 'Fellow');
      });
    });

    group('progressInLevel', () {
      test('returns 0 for start of level', () {
        expect(XpCalculator.progressInLevel(0), 0.0);
      });

      test('returns 0.5 for middle of level', () {
        // Level 1 is 0-499, so 250 is 50%
        expect(XpCalculator.progressInLevel(250), closeTo(0.5, 0.01));
      });

      test('returns 1.0 at level cap', () {
        expect(XpCalculator.progressInLevel(500), 1.0);
      });
    });

    group('xpToNextLevel', () {
      test('returns 500 for level 1 start', () {
        expect(XpCalculator.xpToNextLevel(0), 500);
      });

      test('returns correct XP needed', () {
        expect(XpCalculator.xpToNextLevel(250), 250);
      });
    });

    group('computeBadges', () {
      test('returns empty list for low stats', () {
        final badges = XpCalculator.computeBadges(
          currentStreak: 0,
          longestStreak: 0,
          totalContributions: 0,
          totalXp: 0,
          completedHabits: 0,
        );
        expect(badges, isEmpty);
      });

      test('returns Week Warrior for 7+ day streak', () {
        final badges = XpCalculator.computeBadges(
          currentStreak: 7,
          longestStreak: 7,
          totalContributions: 0,
          totalXp: 0,
          completedHabits: 0,
        );
        expect(badges, contains('Week Warrior'));
      });

      test('returns multiple badges for high stats', () {
        final badges = XpCalculator.computeBadges(
          currentStreak: 30,
          longestStreak: 100,
          totalContributions: 1000,
          totalXp: 5000,
          completedHabits: 50,
        );
        expect(badges.length, 5);
        expect(badges, contains('Week Warrior'));
        expect(badges, contains('Month Master'));
        expect(badges, contains('Century Streak'));
        expect(badges, contains('1K Commits'));
        expect(badges, contains('XP Chaser'));
      });
    });
  });
}
