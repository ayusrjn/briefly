import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import TTS

class SummaryCard extends StatefulWidget {
  final String markdownContent;

  const SummaryCard({super.key, required this.markdownContent});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void dispose() {
    flutterTts.stop(); // Stop talking if user leaves screen
    super.dispose();
  }

  Future<void> _toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      setState(() => isSpeaking = true);
      // Configure voice settings
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5); // Slightly slower is better for news
      
      // Clean markdown symbols for better reading (optional but recommended)
      String cleanText = widget.markdownContent
          .replaceAll('#', '')
          .replaceAll('*', '')
          .replaceAll('✨', ''); // Remove emojis

      await flutterTts.speak(cleanText);
      
      flutterTts.setCompletionHandler(() {
        setState(() => isSpeaking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 80), // Extra bottom padding for button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "✨ AI Summary",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  // Optional: Add a copy button here
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 20, color: Colors.grey[400]),
                    onPressed: () {
                      // Implementation for copying text
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              MarkdownBody(
                data: widget.markdownContent,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  h1: GoogleFonts.merriweather(
                      fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
                  h2: GoogleFonts.merriweather(
                      fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
                  p: GoogleFonts.lato(
                      fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  listBullet: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
        
        // Floating Play Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: _toggleSpeech,
            backgroundColor: isSpeaking ? Colors.redAccent : Colors.black87,
            icon: Icon(isSpeaking ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white),
            label: Text(
              isSpeaking ? "Stop Listening" : "Listen",
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}