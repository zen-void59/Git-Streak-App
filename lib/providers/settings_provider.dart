import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _settingsBox;
  final CacheService _cache = CacheService();
  final NotificationService _notificationService = NotificationService();

  String _username = '';
  String _token = '';
  bool _isReminderOn = false;
  TimeOfDay? _selectedTime;
  bool _obscureToken = true;

  String get username => _username;
  String get token => _token;
  bool get isReminderOn => _isReminderOn;
  TimeOfDay? get selectedTime => _selectedTime;
  bool get obscureToken => _obscureToken;
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
    _token = _settingsBox.get('github_token', defaultValue: '') as String;
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
    await _cache.init();
    _cache.clearAll();

    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token.trim();
    await _settingsBox.put('github_token', _token);
    notifyListeners();
  }

  void toggleObscureToken() {
    _obscureToken = !_obscureToken;
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

  Future<void> clearCache() async {
    await _cache.init();
    _cache.clearAll();
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _settingsBox.clear();
    final habitBox = Hive.box('habits');
    await habitBox.clear();
    await _cache.init();
    _cache.clearAll();
    await _notificationService.cancelAll();

    _loadSettings();
    notifyListeners();
  }
}
