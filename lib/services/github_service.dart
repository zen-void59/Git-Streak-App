import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../models/contribution_day.dart';
import 'api_client.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _graphqlUrl = 'https://api.github.com/graphql';

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
      // Use /user/repos for authenticated user (includes private repos)
      // Use /users/{username}/repos for other users (public only)
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
      // Use GraphQL API to get contributions including private repos
      final query = '''
        query(\$login: String!) {
          user(login: \$login) {
            contributionsCollection {
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
          'variables': {'login': username},
        }),
      );

      final json = jsonDecode(response.body);
      final user = json['data']?['user'];
      if (user == null) return [];

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
