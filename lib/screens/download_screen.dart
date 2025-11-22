import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/summary_provider.dart';
import 'home_screen.dart'; // <--- FIXED IMPORT

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  @override
  void initState() {
    super.initState();
    // Check status immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    final provider = context.read<SummaryProvider>();
    await provider.checkModelStatus();
    
    if (provider.isModelReady && mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SummaryProvider>();
    final progress = provider.downloadProgress;

    // Auto-navigate if ready (double check)
    if (provider.isModelReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToHome());
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100, left: -100,
            child: _GlowBlob(color: const Color(0xFF6366F1).withOpacity(0.2)),
          ),
          Positioned(
            bottom: -100, right: -100,
            child: _GlowBlob(color: const Color(0xFFA855F7).withOpacity(0.2)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.download_rounded, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    "Setting up AI Brain",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We need to download the Gemma3-270M model (~172MB) once. This allows Briefly to work 100% offline and privately.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Progress Bar or Start Button
                  if (progress > 0 && progress < 1.0) ...[
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      color: const Color(0xFF6366F1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: GoogleFonts.outfit(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => provider.downloadModel(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          "Download Model",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  // Error Message
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "Error: ${provider.errorMessage}",
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  const _GlowBlob({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 50)],
      ),
    );
  }
}