import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card skeleton
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppDecorations.card,
            child: Column(
              children: [
                const SkeletonBox(width: 80, height: 80, radius: 40),
                const SizedBox(height: 12),
                const SkeletonBox(width: 120, height: 18),
                const SizedBox(height: 8),
                const SkeletonBox(width: 80, height: 14),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    SkeletonBox(width: 60, height: 40),
                    SkeletonBox(width: 60, height: 40),
                    SkeletonBox(width: 60, height: 40),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats row skeleton
          Row(
            children: const [
              Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(width: double.infinity, height: 100)),
            ],
          ),
          const SizedBox(height: 20),
          // Heatmap skeleton
          const SkeletonBox(width: double.infinity, height: 100),
          const SizedBox(height: 20),
          // Repo list skeletons
          for (int i = 0; i < 3; i++) ...[
            const SkeletonBox(width: double.infinity, height: 70),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
