import 'package:flutter/material.dart';
import '../models/github_repo.dart';
import '../utils/constants.dart';

class RepoCard extends StatelessWidget {
  final GitHubRepo repo;
  final VoidCallback onTap;

  const RepoCard({super.key, required this.repo, required this.onTap});

  Color _languageColor(String lang) {
    const map = {
      'Dart': Color(0xFF00B4AB),
      'JavaScript': Color(0xFFF1E05A),
      'TypeScript': Color(0xFF3178C6),
      'Python': Color(0xFF3572A5),
      'Java': Color(0xFFB07219),
      'Kotlin': Color(0xFFA97BFF),
      'Swift': Color(0xFFFF5733),
      'C++': Color(0xFFF34B7D),
      'C#': Color(0xFF178600),
      'Go': Color(0xFF00ADD8),
      'Rust': Color(0xFFDEA584),
      'HTML': Color(0xFFE44B23),
      'CSS': Color(0xFF563D7C),
    };
    return map[lang] ?? AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_outlined,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (repo.isPrivate)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Private',
                      style:
                          TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
            if (repo.description.isNotEmpty &&
                repo.description != 'No description') ...[
              const SizedBox(height: 6),
              Text(
                repo.description,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (repo.language != 'Unknown') ...[
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: _languageColor(repo.language),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repo.language,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(width: 14),
                ],
                const Icon(Icons.star_outline,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 2),
                Text('${repo.stars}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 14),
                const Icon(Icons.call_split,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 2),
                Text('${repo.forks}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 14),
                if (repo.openIssues > 0) ...[
                  const Icon(Icons.circle_outlined,
                      color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 2),
                  Text('${repo.openIssues}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
