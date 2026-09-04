class GitHubRepo {
  final String name;
  final String description;
  final String htmlUrl;
  final int stars;
  final int forks;
  final int openIssues;
  final String language;
  final String? defaultBranch;
  final DateTime? pushedAt;
  final bool isPrivate;

  GitHubRepo({
    required this.name,
    required this.description,
    required this.htmlUrl,
    required this.stars,
    required this.forks,
    required this.openIssues,
    required this.language,
    this.defaultBranch,
    this.pushedAt,
    this.isPrivate = false,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json['name'] ?? '',
      description: json['description'] ?? 'No description',
      htmlUrl: json['html_url'] ?? '',
      stars: json['stargazers_count'] ?? 0,
      forks: json['forks_count'] ?? 0,
      openIssues: json['open_issues_count'] ?? 0,
      language: json['language'] ?? 'Unknown',
      defaultBranch: json['default_branch'],
      pushedAt: json['pushed_at'] != null
          ? DateTime.tryParse(json['pushed_at'])
          : null,
      isPrivate: json['private'] ?? false,
    );
  }
}
