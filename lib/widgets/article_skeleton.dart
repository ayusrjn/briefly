import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. The Static "AI Core"
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B), // Solid dark core background
              
              // Fixed shadow
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3), 
                  blurRadius: 20, 
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