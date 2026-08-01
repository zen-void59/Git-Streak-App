import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gitstreak_app/models/github_user.dart';
import 'package:gitstreak_app/models/github_repo.dart';
class GitHubService {
  Future<GitHubUser?> fetchUser(String username) async {
    final url = Uri.parse(
      "https://api.github.com/users/$username",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return GitHubUser.fromJson(
        jsonDecode(response.body),
      );
    }

    return null;
  }

  Future<List<GitHubRepo>> fetchRepositories(String username) async {
  final url = Uri.parse(
    "https://api.github.com/users/$username/repos?sort=updated",
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data
        .map((repo) => GitHubRepo.fromJson(repo))
        .toList();
  }

  return [];
}
}