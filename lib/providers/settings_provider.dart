import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _settingsBox;
  final CacheService _cache = CacheService();
  final NotificationService _notificationService = NotificationService();

  String _username = '';
  bool _isReminderOn = false;
  TimeOfDay? _selectedTime;

  String get username => _username;
  bool get isReminderOn => _isReminderOn;
  TimeOfDay? get selectedTime => _selectedTime;
  bool get hasUsername => _username.isNotEmpty;

  String get displayUsername =>
      _username.isNotEmpty ? _username : 'Not set';

  SettingsProvider() {
    _settingsBox = Hive.box('settings');
    _loadSettings();
  }

  void _loadSettings() {
    _username =
        _settingsBox.get('github_username', defaultValue: '') as String;
    _isReminderOn =
        _settingsBox.get('reminder_enabled', defaultValue: false) as bool;

    final savedHour = _settingsBox.get('reminder_hour') as int?;
    final savedMin = _settingsBox.get('reminder_minute') as int?;
    if (savedHour != null && savedMin != null) {
      _selectedTime = TimeOfDay(hour: savedHour, minute: savedMin);
    }
  }

  Future<void> saveUsername(String username) async {
    if (username.trim().isEmpty) return;

    _username = username.trim();
    await _settingsBox.put('github_username', _username);

    // Clear cache so next visit fetches fresh data
    _cache.clearAll();

    notifyListeners();
  }

  Future<void> clearCache() async {
    _cache.clearAll();
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _settingsBox.clear();
    final habitBox = Hive.box('habits');
    await habitBox.clear();
    _cache.clearAll();
    await _notificationService.cancelAll();

    _loadSettings();
    notifyListeners();
  }

  Future<void> toggleReminder(bool enabled) async {
    _isReminderOn = enabled;
    await _settingsBox.put('reminder_enabled', enabled);

    if (enabled) {
      await _notificationService.scheduleDaily(
        hour: _selectedTime?.hour ?? 20,
        minute: _selectedTime?.minute ?? 0,
      );
    } else {
      await _notificationService.cancelAll();
    }

    notifyListeners();
  }

  Future<void> selectTime(TimeOfDay time) async {
    _selectedTime = time;
    await _settingsBox.put('reminder_hour', time.hour);
    await _settingsBox.put('reminder_minute', time.minute);

    // Reschedule if reminder is on
    if (_isReminderOn) {
      await _notificationService.scheduleDaily(
        hour: time.hour,
        minute: time.minute,
      );
    }

    notifyListeners();
  }
}
