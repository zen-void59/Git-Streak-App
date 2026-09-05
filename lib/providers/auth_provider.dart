import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/github_user.dart';
import '../services/auth_service.dart';
import '../services/github_service.dart';
import '../services/cache_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GitHubService _githubService = GitHubService();
  final CacheService _cache = CacheService();

  AuthStatus _status = AuthStatus.initial;
  String? _username;
  GitHubUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get username => _username;
  GitHubUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _status = AuthStatus.loading;
      notifyListeners();

      try {
        final token = await _authService.getAccessToken();
        if (token != null) {
          _githubService.setToken(token);
          await _cache.init();

          // Try to get cached user first
          _user = _cache.getCachedUser();

          // If no cached user, fetch from API
          if (_user == null) {
            _user = await _fetchCurrentUser();
          }

          if (_user != null) {
            _username = _user!.login;
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.error;
            _errorMessage = 'Failed to load user data';
          }
        } else {
          _status = AuthStatus.initial;
        }
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Failed to initialize: $e';
      }

      notifyListeners();
    }
  }

  /// Start OAuth login flow
  Future<void> login() async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login();
      // User goes to browser now. Loading state is set when deep link arrives.
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to start login: $e';
      notifyListeners();
    }
  }

  /// Complete the OAuth flow with the authorization code
  Future<void> completeLogin(String code) async {
    debugPrint('completeLogin called with code: ${code.substring(0, 5)}...');
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.handleCallback(code);

      if (!result.success) {
        _status = AuthStatus.error;
        _errorMessage = result.errorMessage ?? 'Authentication failed. Please try again.';
        debugPrint('Token exchange failed: $_errorMessage');
        notifyListeners();
        return;
      }

      // Set token for API calls
      _githubService.setToken(result.token);

      // Fetch current user from GitHub
      debugPrint('Fetching current user...');
      _user = await _fetchCurrentUser();
      debugPrint('User fetched: ${_user?.login}');

      if (_user != null) {
        _username = _user!.login;

        // Save user info to secure storage
        await _authService.saveUserInfo(_user!.login, _user!.avatarUrl);

        // Save to cache
        await _cache.init();
        await _cache.saveUser(_user!);

        // Save username to Hive for other providers
        final settings = Hive.box('settings');
        await settings.put('github_username', _user!.login);

        _status = AuthStatus.authenticated;
        debugPrint('Login complete - authenticated');
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Authenticated but failed to load your GitHub profile. Please try again.';
        debugPrint('Login failed - user is null');
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('Login exception: $e');
    }

    notifyListeners();
  }

  /// Fetch the currently authenticated user from GitHub API
  Future<GitHubUser?> _fetchCurrentUser() async {
    try {
      // Use the /user endpoint (authenticated) instead of /users/{username}
      return await _githubService.fetchCurrentUser();
    } catch (e) {
      debugPrint('Failed to fetch current user: $e');
      return null;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    _user = await _fetchCurrentUser();
    if (_user != null) {
      _username = _user!.login;
      await _authService.saveUserInfo(_user!.login, _user!.avatarUrl);
    }
    notifyListeners();
  }

  /// Logout and clear all data
  Future<void> logout() async {
    await _authService.logout();

    final settings = Hive.box('settings');
    await settings.clear();

    final habitBox = Hive.box('habits');
    await habitBox.clear();

    _cache.clearAll();

    _status = AuthStatus.initial;
    _username = null;
    _user = null;
    _errorMessage = null;

    notifyListeners();
  }

  /// Set token manually (for backward compatibility)
  void setToken(String token) {
    _githubService.setToken(token);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }
}
