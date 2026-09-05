import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../models/contribution_day.dart';
import 'api_client.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _graphqlUrl = 'https://api.github.com/graphql';

  static final GitHubService _instance = GitHubService._internal();
  factory GitHubService() => _instance;
  GitHubService._internal();

  final ApiClient _client = ApiClient();

  void setToken(String? token) {
    _client.setHeaders({
      'Accept': 'application/vnd.github+json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });
  }

  /// Fetch the currently authenticated user (requires token)
  Future<GitHubUser?> fetchCurrentUser() async {
    try {
      final url = Uri.parse('$_baseUrl/user');
      final response = await _client.get(url);
      return GitHubUser.fromJson(jsonDecode(response.body));
    } on ApiException catch (e) {
      debugPrint('Failed to fetch current user: ${e.message}');
      return null;
    }
  }

  Future<GitHubUser?> fetchUser(String username) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$username');
      final response = await _client.get(url);
      return GitHubUser.fromJson(jsonDecode(response.body));
    } on ApiException catch (e) {
      debugPrint('Failed to fetch user: ${e.message}');
      return null;
    }
  }

  /// Fetch repositories including private repos (requires token)
  Future<List<GitHubRepo>> fetchRepositories(
    String username, {
    int perPage = 30,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/users/$username/repos?sort=updated&per_page=$perPage&page=$page',
      );
      final response = await _client.get(url);
      final List data = jsonDecode(response.body);
      return data.map((repo) => GitHubRepo.fromJson(repo)).toList();
    } on ApiException catch (e) {
      debugPrint('Failed to fetch repos: ${e.message}');
      return [];
    }
  }

  /// Fetch repositories for the authenticated user (includes private repos)
  Future<List<GitHubRepo>> fetchCurrentUserRepos({
    int perPage = 30,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/user/repos?sort=updated&per_page=$perPage&page=$page&type=all',
      );
      final response = await _client.get(url);
      final List data = jsonDecode(response.body);
      return data.map((repo) => GitHubRepo.fromJson(repo)).toList();
    } on ApiException catch (e) {
      debugPrint('Failed to fetch current user repos: ${e.message}');
      return [];
    }
  }

  /// Fetch contributions using GitHub GraphQL API (includes private contributions)
  Future<List<ContributionDay>> fetchContributions(String username) async {
    try {
      // Date range for last year
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365));

      final query = '''
        query(\$login: String!, \$from: DateTime!, \$to: DateTime!) {
          user(login: \$login) {
            contributionsCollection(from: \$from, to: \$to) {
              contributionCalendar {
                weeks {
                  contributionDays {
                    date
                    contributionCount
                  }
                }
              }
            }
          }
        }
      ''';

      final response = await _client.post(
        Uri.parse(_graphqlUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'variables': {
            'login': username,
            'from': from.toUtc().toIso8601String(),
            'to': now.toUtc().toIso8601String(),
          },
        }),
      );

      final json = jsonDecode(response.body);

      // Check for GraphQL errors
      if (json['errors'] != null) {
        debugPrint('GraphQL errors: ${json['errors']}');
        return _fetchContributionsFallback(username);
      }

      final user = json['data']?['user'];
      if (user == null) return _fetchContributionsFallback(username);

      final weeks = user['contributionsCollection']?['contributionCalendar']?['weeks'] as List?;
      if (weeks == null) return [];

      final contributions = <ContributionDay>[];
      for (final week in weeks) {
        final days = week['contributionDays'] as List?;
        if (days != null) {
          for (final day in days) {
            contributions.add(ContributionDay(
              date: DateTime.parse(day['date']),
              count: day['contributionCount'] ?? 0,
            ));
          }
        }
      }

      return contributions;
    } catch (e) {
      debugPrint('Failed to fetch contributions via GraphQL: $e');
      // Fallback to third-party API (public contributions only)
      return _fetchContributionsFallback(username);
    }
  }

  /// Fallback: Fetch contributions using third-party proxy (public only)
  Future<List<ContributionDay>> _fetchContributionsFallback(String username) async {
    try {
      final url = Uri.parse(
        'https://github-contributions-api.jogruber.de/v4/$username?y=last',
      );
      final response = await _client.get(url);

      final json = jsonDecode(response.body);
      final contributions = json['contributions'] as List<dynamic>?;
      if (contributions != null) {
        return contributions
            .map((e) => ContributionDay.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on ApiException catch (e) {
      debugPrint('Failed to fetch contributions (fallback): ${e.message}');
    }
    return [];
  }

  Future<Map<String, int>> fetchLanguageStats(
    String username,
    List<GitHubRepo> repos,
  ) async {
    final langCount = <String, int>{};
    for (final repo in repos.take(20)) {
      final lang = repo.language;
      if (lang.isNotEmpty && lang != 'Unknown') {
        langCount[lang] = (langCount[lang] ?? 0) + 1;
      }
    }
    return langCount;
  }
}
