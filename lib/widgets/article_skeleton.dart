import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake Title
            Container(width: double.infinity, height: 32, color: Colors.white),
            const SizedBox(height: 16),
            // Fake Body Lines
            for (int i = 0; i < 6; i++) ...[
              Container(width: double.infinity, height: 16, color: Colors.white),
              const SizedBox(height: 8),
            ],
            Container(width: 200, height: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}