class GitHubRepo {
  final String name;
  final String description;
  final String htmlUrl;
  final int stars;
  final String language;

  GitHubRepo({
    required this.name,
    required this.description,
    required this.htmlUrl,
    required this.stars,
    required this.language,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json["name"],
      description: json["description"] ?? "No description",
      htmlUrl: json["html_url"],
      stars: json["stargazers_count"],
      language: json["language"] ?? "Unknown",
    );
  }
}