import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit_model.dart';
import '../utils/xp_calculator.dart';

class HabitsProvider extends ChangeNotifier {
  late Box<HabitModel> _habitBox;
  late Box _settingsBox;
  final Set<int> _selectedHabits = {};

  List<HabitModel> get habits => _habitBox.values.toList();
  int get length => _habitBox.length;
  bool get isEmpty => _habitBox.isEmpty;
  Set<int> get selectedHabits => _selectedHabits;
  bool get hasSelection => _selectedHabits.isNotEmpty;

  int get completedCount => _habitBox.values.where((h) => h.completed).length;

  double get completionRate {
    if (_habitBox.isEmpty) return 0;
    return completedCount / _habitBox.length;
  }

  int get totalXp {
    final totalCommits =
        _settingsBox.get('cached_commits', defaultValue: 0) as int;
    final currentStreak =
        _settingsBox.get('current_streak', defaultValue: 0) as int;
    return XpCalculator.totalXp(
      totalCommits: totalCommits,
      completedHabits: completedCount,
      currentStreak: currentStreak,
    );
  }

  int get level => XpCalculator.levelFromXp(totalXp);
  String get title => XpCalculator.titleFromXp(totalXp);
  double get progress => XpCalculator.progressInLevel(totalXp);
  int get xpToNext => XpCalculator.xpToNextLevel(totalXp);

  List<String> get badges {
    final totalCommits =
        _settingsBox.get('cached_commits', defaultValue: 0) as int;
    final currentStreak =
        _settingsBox.get('current_streak', defaultValue: 0) as int;
    final longestStreak =
        _settingsBox.get('longest_streak', defaultValue: 0) as int;
    return XpCalculator.computeBadges(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalContributions: totalCommits,
      totalXp: totalXp,
      completedHabits: completedCount,
    );
  }

  HabitsProvider() {
    _habitBox = Hive.box<HabitModel>('habits');
    _settingsBox = Hive.box('settings');

    if (_habitBox.isEmpty) {
      _habitBox
          .add(HabitModel(name: 'Daily Coding', days: 0, completed: false));
      _habitBox.add(
          HabitModel(name: 'Read 20 min', days: 14, completed: false));
      _habitBox
          .add(HabitModel(name: 'Workout', days: 42, completed: false));
    }
  }

  HabitModel getHabit(int index) => _habitBox.getAt(index)!;

  bool isHabitSelected(int index) => _selectedHabits.contains(index);

  bool isCodingHabit(String name) {
    final lower = name.toLowerCase();
    return lower.contains('code') ||
        lower.contains('coding') ||
        lower.contains('commit') ||
        lower.contains('push') ||
        lower.contains('develop') ||
        lower.contains('program');
  }

  void toggleHabitSelection(int index) {
    if (_selectedHabits.contains(index)) {
      _selectedHabits.remove(index);
    } else {
      _selectedHabits.add(index);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedHabits.clear();
    notifyListeners();
  }

  void addHabit(String name) {
    if (name.trim().isEmpty) return;
    _habitBox.add(HabitModel(
      name: name.trim(),
      days: 0,
      completed: false,
    ));
    notifyListeners();
  }

  void toggleHabitCompleted(int index) {
    final habit = _habitBox.getAt(index)!;
    habit.completed = !habit.completed;
    if (habit.completed) habit.days++;
    habit.save();
    notifyListeners();
  }

  void deleteSelectedHabits() {
    final indexes = _selectedHabits.toList()..sort((a, b) => b.compareTo(a));
    for (final i in indexes) {
      _habitBox.deleteAt(i);
    }
    _selectedHabits.clear();
    notifyListeners();
  }

  void deleteHabit(int index) {
    _habitBox.deleteAt(index);
    _selectedHabits.remove(index);
    notifyListeners();
  }
}
