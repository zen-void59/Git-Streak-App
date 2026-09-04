import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/oauth_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'github_access_token';
  static const String _usernameKey = 'github_username';
  static const String _avatarKey = 'github_avatar_url';

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

  /// Handle the OAuth callback with authorization code
  Future<String?> handleCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse(OAuthConfig.tokenExchangeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String?;

        if (accessToken != null) {
          await _storage.write(key: _tokenKey, value: accessToken);
          return accessToken;
        }
      }

      debugPrint('Token exchange failed: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Token exchange error: $e');
      return null;
    }
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
