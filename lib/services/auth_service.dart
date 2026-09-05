import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/oauth_config.dart';

class TokenExchangeResult {
  final String? token;
  final String? errorMessage;
  final bool isNetworkError;

  TokenExchangeResult({this.token, this.errorMessage, this.isNetworkError = false});

  bool get success => token != null && token!.isNotEmpty;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'github_access_token';
  static const String _usernameKey = 'github_username';
  static const String _avatarKey = 'github_avatar_url';
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Start the GitHub OAuth flow
  Future<void> login() async {
    final authUrl = Uri.parse(
      '${OAuthConfig.authorizeUrl}'
      '?client_id=${OAuthConfig.clientId}'
      '&scope=${Uri.encodeComponent(OAuthConfig.scopes)}'
      '&redirect_uri=${OAuthConfig.redirectScheme}://${OAuthConfig.redirectHost}'
    );

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Handle the OAuth callback with authorization code.
  /// Includes retry logic with exponential backoff for cold-start backends.
  Future<TokenExchangeResult> handleCallback(String code) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        debugPrint('Token exchange attempt ${attempt + 1}/$_maxRetries');

        final response = await http.post(
          Uri.parse(OAuthConfig.tokenExchangeUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'code': code}),
        ).timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'] as String?;

          if (accessToken != null && accessToken.isNotEmpty) {
            await _storage.write(key: _tokenKey, value: accessToken);
            debugPrint('Token exchange successful');
            return TokenExchangeResult(token: accessToken);
          }

          // HTTP 200 but no access_token — backend returned an error in the body
          final error = data['error'] as String? ?? 'Unknown error';
          debugPrint('Token exchange: backend returned error: $error');
          return TokenExchangeResult(
            errorMessage: 'GitHub denied access: $error',
          );
        }

        // Non-200 status — try to parse error message from backend
        String serverError;
        try {
          final data = jsonDecode(response.body);
          serverError = data['error'] as String? ?? 'Server error ${response.statusCode}';
        } catch (_) {
          serverError = 'Server error ${response.statusCode}';
        }

        debugPrint('Token exchange failed (${response.statusCode}): $serverError');

        // Don't retry on client errors (4xx except 429)
        if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 429) {
          return TokenExchangeResult(errorMessage: serverError);
        }

        // Retry on 429 (rate limit) or 5xx (server error)
        if (attempt < _maxRetries - 1) {
          final delay = _initialRetryDelay * (1 << attempt);
          debugPrint('Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }

        return TokenExchangeResult(errorMessage: serverError);
      } on TimeoutException {
        debugPrint('Token exchange timeout on attempt ${attempt + 1}');
        if (attempt < _maxRetries - 1) {
          final delay = _initialRetryDelay * (1 << attempt);
          debugPrint('Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }
        return TokenExchangeResult(
          errorMessage: 'Connection timed out. The server may be starting up, please try again in a moment.',
          isNetworkError: true,
        );
      } on http.ClientException {
        debugPrint('Token exchange network error on attempt ${attempt + 1}');
        if (attempt < _maxRetries - 1) {
          final delay = _initialRetryDelay * (1 << attempt);
          debugPrint('Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }
        return TokenExchangeResult(
          errorMessage: 'No internet connection. Please check your network and try again.',
          isNetworkError: true,
        );
      } on FormatException {
        debugPrint('Token exchange: invalid response format');
        return TokenExchangeResult(
          errorMessage: 'Received an invalid response from the server.',
        );
      } catch (e) {
        debugPrint('Token exchange unexpected error: $e');
        if (attempt < _maxRetries - 1) {
          final delay = _initialRetryDelay * (1 << attempt);
          await Future.delayed(delay);
          continue;
        }
        return TokenExchangeResult(
          errorMessage: 'Authentication failed: $e',
        );
      }
    }

    return TokenExchangeResult(
      errorMessage: 'Authentication failed after $_maxRetries attempts. Please try again.',
    );
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user info after fetching from GitHub
  Future<void> saveUserInfo(String username, String avatarUrl) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _avatarKey, value: avatarUrl);
  }

  /// Get stored username
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Get stored avatar URL
  Future<String?> getAvatarUrl() async {
    return await _storage.read(key: _avatarKey);
  }

  /// Clear all stored data (logout)
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _avatarKey);
  }

  /// Get auth headers for GitHub API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Accept': 'application/vnd.github+json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}
