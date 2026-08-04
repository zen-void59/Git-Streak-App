import "package:flutter/material.dart";
import 'package:gitstreak_app/services/github_service.dart';
import 'package:gitstreak_app/models/github_user.dart';
import 'package:gitstreak_app/models/github_repo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';

//import "package:gitstreak_app/navigation_bar.dart" as app_nav;
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? selectedCard;
  GitHubUser? githubUser;
  bool isLoading = true;
  List<GitHubRepo> repositories = [];
  GitHubUser? user;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();

    loadUser();
  }


  Future<void> openRepository(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception("Could not launch $url");
    }
  }

  Future<void> loadUser() async {
  final settingsBox = Hive.box('settings');

  final username = settingsBox.get(
    'github_username',
    defaultValue: 'zen-void59',
  );

  final service = GitHubService();

  final user = await service.fetchUser(username);

  final repos = await service.fetchRepositories(username);

  print("Total repos fetched: ${repos.length}");

  for (final repo in repos) {
    print(repo.name);
  }

  setState(() {
    githubUser = user;
    repositories = repos;
    isLoading = false;
  });
}
  @override

  Widget build(BuildContext context) {
     if (isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: githubUser != null
                ? NetworkImage(githubUser!.avatarUrl)
                : null,
            child: githubUser == null ? const Icon(Icons.person) : null,
          ),
        ),
        title: const Text(
          'Git Streak',
          style: TextStyle(
            color: Color.fromARGB(255, 88, 233, 93),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Card(
  color: const Color(0xFF1B1F24),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [

        CircleAvatar(
          radius: 40,
          backgroundImage: githubUser != null ? NetworkImage(githubUser!.avatarUrl) : null,
          child: githubUser == null ? const Icon(Icons.person) : null,
        ),

        const SizedBox(height: 12),

        Text(
          githubUser?.login ?? 'User',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          "@${githubUser?.login ?? ''}",
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Column(
              children: [
                Text(
                  "${githubUser?.publicRepos ?? 0}",
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Text("Repositories"),
              ],
            ),

            Column(
              children: [
                Text(
                  "${githubUser?.followers ?? 0}",
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Text("Followers"),
              ],
            ),

            Column(
              children: [
                Text(
                  "${githubUser?.following ?? 0}",
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Text("Following"),
              ],
            ),
          ],
        )
      ],
    ),
  ),
),

                Text(
                  isLoading
                      ? "Loading..."
                      : "Welcome ${githubUser?.login ?? "User"},",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  isLoading
                      ? "Loading profile..."
                      : "Public Repositories: ${githubUser?.publicRepos ?? 0}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  ' Activity',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 78, 101, 78),
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    'Your last 365 days of activity will be analyzed to build your unique developer momentum profile.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      //Current Streak Card
                      SizedBox(
                        width: 130,
                        height: 120,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 78, 101, 78),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 30,
                              ),
                              Text(
                                "Current",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "0 Days",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      //Longest Streak Card
                      SizedBox(
                        width: 130,
                        height: 120,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 78, 101, 78),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Longest",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 0),
                              Text(
                                "0 Days",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      //Total Contributions Card
                      SizedBox(
                        width: 130,
                        height: 120,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 78, 101, 78),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.lightBlue,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "This Week",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "0 Commits",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Active Repositories',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 70),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: repositories.length,
                    itemBuilder: (context, index) {
                      final repo = repositories[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.folder,
                            color: Colors.green,
                          ),

                          title: Text(repo.name),

                          subtitle: Text(
                            repo.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              Text("${repo.stars}"),
                            ],
                          ),
                          onTap: () {
                            openRepository(repo.htmlUrl);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
