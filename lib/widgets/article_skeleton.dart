import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleSkeleton extends StatefulWidget {
  const ArticleSkeleton({super.key});

  @override
  State<ArticleSkeleton> createState() => _ArticleSkeletonState();
}

class _ArticleSkeletonState extends State<ArticleSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slower animation (4 seconds) reduces GPU redraw frequency
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), 
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. The Optimized "AI Core"
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // We use a static container inside the builder but animate its parent
              // This is lighter than re-calculating complex shadows every frame
              return Transform.scale(
                scale: 1.0 + (_controller.value * 0.1), // Subtle breathing (1.0 -> 1.1)
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E293B), // Solid dark core background
                    
                    // LOW COST SHADOW: Fixed radius, no dynamic blur calculation
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3), 
                        blurRadius: 20, // Reduced from 120. Much cheaper for GPU.
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome, 
                    color: Colors.white, 
                    size: 32
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // 2. Text Feedback
          Text(
            "Analyzing...",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Gemma-3 is summarizing locally",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}