import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Grid Skeleton for Marketplace
  static Widget grid({int itemCount = 6}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const _GridItemSkeleton();
      },
    );
  }

  /// List Skeleton for Orders/Transactions
  static Widget list({int itemCount = 5}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const _ListItemSkeleton();
      },
    );
  }

  /// Card Skeleton for Dashboard stats
  static Widget card() {
    return const _CardSkeleton();
  }
}

class _GridItemSkeleton extends StatelessWidget {
  const _GridItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          const Expanded(
            flex: 3,
            child: SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
          ),
          // Info Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoader(width: 60, height: 12),
                      const SizedBox(height: 8),
                      const SkeletonLoader(width: double.infinity, height: 16),
                      const SizedBox(height: 8),
                      const SkeletonLoader(width: 100, height: 12),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          SkeletonLoader(width: 40, height: 16),
                          SizedBox(width: 6),
                          SkeletonLoader(width: 30, height: 12),
                        ],
                      ),
                    ],
                  ),
                  const SkeletonLoader(width: double.infinity, height: 36, borderRadius: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const SkeletonLoader(width: 50, height: 50, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 120, height: 16),
                SizedBox(height: 8),
                SkeletonLoader(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonLoader(width: 60, height: 16),
              SizedBox(height: 8),
              SkeletonLoader(width: 40, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(width: 40, height: 40, borderRadius: 12),
              SkeletonLoader(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 32),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 120, height: 16),
        ],
      ),
    );
  }
}
