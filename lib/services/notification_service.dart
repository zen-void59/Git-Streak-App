import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int _dailyReminderId = 0;
  static const int _milestoneBaseId = 100;
  static const int _weeklyDigestId = 200;

  // Milestone thresholds
  static const List<int> streakMilestones = [7, 30, 50, 100, 180, 365];
  static const List<int> commitMilestones = [100, 500, 1000, 5000, 10000];

  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    // Initialize timezone for scheduling
    tz.initializeTimeZones();

    // Request notification permission on Android 13+
    await _requestPermission();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _initialized = true;
  }

  /// Schedule daily reminder at specified time
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    String? customTitle,
    String? customBody,
  }) async {
    if (kIsWeb || !_initialized) return;
    try {
      // Cancel only daily reminder (keep milestones)
      await _plugin.cancel(_dailyReminderId);

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Coding Reminder',
        channelDescription: 'Reminds you to code every day',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule daily at the specified time
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time already passed today, schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _dailyReminderId,
        customTitle ?? '🔥 Keep your streak alive!',
        customBody ??
            'Don\'t forget to commit today to maintain your GitHub streak.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  /// Show streak milestone notification
  Future<void> showStreakMilestone(int streakDays) async {
    if (kIsWeb || !_initialized) return;
    if (!streakMilestones.contains(streakDays)) return;

    // Check if we already showed this milestone today
    final settings = Hive.box('settings');
    final shownKey = 'milestone_shown_$streakDays';
    final lastShown = settings.get(shownKey) as String?;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastShown == today) return;

    String title;
    String body;

    switch (streakDays) {
      case 7:
        title = '🎉 Week Warrior!';
        body = 'Amazing! You\'ve maintained a 7-day streak. Keep going!';
        break;
      case 30:
        title = '💎 Month Master!';
        body = 'Incredible! 30 days of consistent coding. You\'re on fire!';
        break;
      case 50:
        title = '🔥 50 Day Streak!';
        body = 'Half a century of coding! You\'re a true developer.';
        break;
      case 100:
        title = '🏆 Century Streak!';
        body = 'Legendary! 100 days straight. You\'re unstoppable!';
        break;
      case 180:
        title = '🌟 6 Month Streak!';
        body = 'Half a year of dedication. You\'re an inspiration!';
        break;
      case 365:
        title = '👑 Year of Code!';
        body = 'A full year! You\'ve earned the title of Code Master!';
        break;
      default:
        return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'streak_milestones',
        'Streak Milestones',
        channelDescription: 'Celebrate your streak achievements',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        _milestoneBaseId + streakDays,
        title,
        body,
        details,
      );

      // Mark as shown today
      await settings.put(shownKey, today);
    } catch (e) {
      debugPrint('Milestone notification error: $e');
    }
  }

  /// Show commit milestone notification
  Future<void> showCommitMilestone(int totalCommits) async {
    if (kIsWeb || !_initialized) return;

    int? milestone;
    for (final m in commitMilestones) {
      if (totalCommits >= m) milestone = m;
    }
    if (milestone == null) return;

    // Check if we already showed this milestone
    final settings = Hive.box('settings');
    final shownKey = 'commit_milestone_shown_$milestone';
    if (settings.get(shownKey, defaultValue: false) as bool) return;

    String title;
    String body;

    switch (milestone) {
      case 100:
        title = '🎯 100 Commits!';
        body = 'You\'ve made 100 contributions. Great progress!';
        break;
      case 500:
        title = '🚀 500 Commits!';
        body = '500 contributions and counting. Keep building!';
        break;
      case 1000:
        title = '⚡ 1K Commits!';
        body = '1000 contributions! You\'re a coding machine!';
        break;
      case 5000:
        title = '💎 5K Commits!';
        body = '5000 contributions. Legendary developer status!';
        break;
      case 10000:
        title = '👑 10K Commits!';
        body = '10000 contributions. You\'re in the hall of fame!';
        break;
      default:
        return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'commit_milestones',
        'Commit Milestones',
        channelDescription: 'Celebrate your commit achievements',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        _milestoneBaseId + 1000 + milestone,
        title,
        body,
        details,
      );

      // Mark as shown
      await settings.put(shownKey, true);
    } catch (e) {
      debugPrint('Commit milestone notification error: $e');
    }
  }

  /// Schedule smart reminder based on user's coding pattern
  ///
  /// Analyzes the last 7 days of contributions to find the best reminder time.
  /// If user typically codes in the evening, remind them before that time.
  Future<void> scheduleSmartReminder({
    required List<int> hourlyCommits,
  }) async {
    if (kIsWeb || !_initialized) return;

    // Find the peak hour (most commits)
    int peakHour = 20; // Default to 8 PM
    int maxCommits = 0;
    for (int i = 0; i < hourlyCommits.length && i < 24; i++) {
      if (hourlyCommits[i] > maxCommits) {
        maxCommits = hourlyCommits[i];
        peakHour = i;
      }
    }

    // Remind 1 hour before peak time
    int reminderHour = peakHour > 0 ? peakHour - 1 : 23;

    // Don't remind too early or too late
    if (reminderHour < 9) reminderHour = 9;
    if (reminderHour > 22) reminderHour = 22;

    final settings = Hive.box('settings');
    final reminderEnabled =
        settings.get('reminder_enabled', defaultValue: false) as bool;

    if (reminderEnabled) {
      await scheduleDaily(
        hour: reminderHour,
        minute: 0,
        customTitle: '💡 Time to code!',
        customBody:
            'Based on your pattern, this is usually your coding time.',
      );
    }
  }

  /// Show weekly digest notification
  Future<void> showWeeklyDigest({
    required int weeklyCommits,
    required int currentStreak,
    required int goalProgress,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'weekly_digest',
        'Weekly Digest',
        channelDescription: 'Your weekly coding summary',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      String emoji;
      if (weeklyCommits >= 14) {
        emoji = '🔥';
      } else if (weeklyCommits >= 7) {
        emoji = '💪';
      } else if (weeklyCommits >= 3) {
        emoji = '👍';
      } else {
        emoji = '📝';
      }

      await _plugin.show(
        _weeklyDigestId,
        '$emoji Weekly Summary',
        '$weeklyCommits commits this week • $currentStreak day streak',
        details,
      );
    } catch (e) {
      debugPrint('Weekly digest error: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// Cancel daily reminder only
  Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(_dailyReminderId);
  }

  /// Request notification permission (Android 13+ / iOS)
  Future<void> _requestPermission() async {
    try {
      // Android 13+ requires runtime permission for notifications
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission granted: $granted');
      }

      // iOS permission request
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission: $granted');
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }
}
