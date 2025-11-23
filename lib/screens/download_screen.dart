import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/summary_provider.dart';
import 'home_screen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SummaryProvider>().checkModelStatus();
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SummaryProvider>();

    // Prevent button flicker: Keep loading state if checking OR if ready (waiting to nav)
    final bool isStartupLoading = provider.isChecking || provider.isModelReady;

    if (provider.isModelReady && !provider.isChecking) {
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

          // Main Content - Centered & Scrollable
          // Using Positioned.fill ensures the touch area and centering works across the whole screen
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        isStartupLoading ? "Briefly AI" : "Setting up AI Brain",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        isStartupLoading 
                          ? "Verifying neural engine..."
                          : "We need to download the Gemma-3-270m INT8 Quantized model (~178MB) once. This allows Briefly to work 100% offline and privately.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // UI STATE LOGIC
                      if (isStartupLoading) ...[
                        // State 1: Splash Mode
                        const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                        ),
                      ] else if (provider.isDownloading) ...[
                        // State 2: Downloading
                        LinearProgressIndicator(
                          value: provider.downloadProgress,
                          backgroundColor: Colors.white10,
                          color: const Color(0xFF6366F1),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${(provider.downloadProgress * 100).toInt()}%",
                          style: GoogleFonts.outfit(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ] else ...[
                        // State 3: Download Button
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