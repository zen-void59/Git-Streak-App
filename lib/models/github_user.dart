class GitHubUser {
  final String login;
  final String name;
  final String avatarUrl;
  final String? bio;
  final String? company;
  final String? blog;
  final String? location;
  final String htmlUrl;
  final int publicRepos;
  final int followers;
  final int following;

  GitHubUser({
    required this.login,
    required this.name,
    required this.avatarUrl,
    this.bio,
    this.company,
    this.blog,
    this.location,
    required this.htmlUrl,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] ?? '',
      name: json['name'] ?? json['login'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'],
      company: json['company'],
      blog: json['blog'],
      location: json['location'],
      htmlUrl: json['html_url'] ?? '',
      publicRepos: json['public_repos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}
