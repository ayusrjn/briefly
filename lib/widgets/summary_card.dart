import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SummaryCard extends StatefulWidget {
  final String markdownContent;

  const SummaryCard({super.key, required this.markdownContent});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      setState(() => isSpeaking = true);
      await flutterTts.setLanguage("en-US");
      // Remove markdown symbols so the voice doesn't say "Star Star"
      String cleanText = widget.markdownContent.replaceAll(RegExp(r'[#*✨]'), '');
      await flutterTts.speak(cleanText);
      flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.markdownContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Summary copied to clipboard", 
          style: GoogleFonts.inter(color: Colors.white)
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6366F1), // Indigo
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. The Glass Card Container
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6), // Semi-transparent dark
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Header Section
                    _buildHeader(),
                    
                    const Divider(height: 1, color: Colors.white10),

                    // 3. Scrollable Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 90), // Bottom padding for FAB
                      child: MarkdownBody(
                        data: widget.markdownContent,
                        selectable: true,
                        styleSheet: _buildMarkdownStyle(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Action Bar (Bottom)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildFloatingActionBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          // Pulsing AI Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF818CF8), size: 20),
          ),
          const SizedBox(width: 12),
          
          // Title & Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI Executive Brief",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Generated by Gemma-3 270M",
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button 1: Listen
              Expanded(
                child: _ActionButton(
                  icon: isSpeaking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  label: isSpeaking ? "Stop" : "Listen",
                  isActive: isSpeaking,
                  onTap: _toggleSpeech,
                ),
              ),
              
              _VerticalDivider(),
              
              // Button 2: Copy
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: "Copy Text",
                  onTap: _copyToClipboard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      // Headings
      h1: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
      h2: GoogleFonts.outfit(
        color: const Color(0xFFA5B4FC), // Light Indigo
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h3: GoogleFonts.outfit(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      // Body
      p: GoogleFonts.inter(
        color: const Color(0xFFCBD5E1), // Blue-ish Grey
        fontSize: 15,
        height: 1.6,
      ),
      // Lists
      listBullet: const TextStyle(color: Color(0xFF818CF8), fontSize: 16),
      // Blockquotes (The vertical bar effect)
      blockquote: const TextStyle(
        color: Colors.white60,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        border: const Border(left: BorderSide(color: Color(0xFF6366F1), width: 3)),
        borderRadius: BorderRadius.circular(4),
      ),
      blockquotePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF818CF8) : Colors.white70,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isActive ? const Color(0xFF818CF8) : Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.1),
    );
  }
}