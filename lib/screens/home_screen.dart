import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/summary_provider.dart';
import '../widgets/article_skeleton.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription _intentSub;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initShareListener();
  }

  @override
  void dispose() {
    _intentSub.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _initShareListener() {
    final provider = Provider.of<SummaryProvider>(context, listen: false);
    
    // Listen while app is running
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) _processLink(value.first.path, provider);
    }, onError: (err) => debugPrint("Intent Error: $err"));

    // Check if app was opened via share
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) _processLink(value.first.path, provider);
    });
  }

  void _processLink(String link, SummaryProvider provider) {
    if (link.startsWith('http')) {
      setState(() {
        _urlController.text = link;
      });
      provider.processUrl(link);
    }
  }

  void _handleManualSubmit() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty && text.startsWith('http')) {
      FocusScope.of(context).unfocus();
      context.read<SummaryProvider>().processUrl(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid http/https URL"),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SummaryProvider>().state;
    final provider = context.read<SummaryProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Background Blobs (The "Brain" Glow)
          Positioned(
            top: -100,
            right: -100,
            child: _GlowBlob(color: const Color(0xFF6366F1).withOpacity(0.2)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _GlowBlob(color: const Color(0xFFA855F7).withOpacity(0.2)),
          ),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: state == AppState.success 
                  ? _buildResultView(provider) 
                  : _buildInputView(context, state, provider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView(BuildContext context, AppState state, SummaryProvider provider) {
    if (state == AppState.scraping || state == AppState.summarizing) {
      return const ArticleSkeleton();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Icon(Icons.auto_awesome_mosaic_rounded, size: 64, color: Colors.white.withOpacity(0.9)),
        const SizedBox(height: 24),
        Text("Briefly AI", style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          "Summarize anything. Instantly.",
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[400]),
        ),
        const SizedBox(height: 40),

        // Glass Input Field
        _GlassContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: const Icon(Icons.link, color: Colors.white54),
                border: InputBorder.none,
                hintText: "Paste URL here...",
                hintStyle: const TextStyle(color: Colors.white24),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.white54),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      setState(() {
                        _urlController.text = data!.text!;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleManualSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text("Generate Brief", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        
        const SizedBox(height: 60),

        // PRIVACY BADGE / GEMMA INFO
        _GlassContainer(
          color: Colors.green.withOpacity(0.05),
          borderColor: Colors.green.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.greenAccent, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Private On-Device AI",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Powered by Gemma-3 270M Parameters local model. No data leaves this device.",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Error Display
        if (state == AppState.error && provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                TextButton(
                  onPressed: provider.reset,
                  child: const Text("Dismiss"),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResultView(SummaryProvider provider) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: provider.reset,
          ),
        ),
        const SizedBox(height: 10),
        SummaryCard(markdownContent: provider.summary!),
      ],
    );
  }
}

// --- Helper Widgets for Glassmorphism ---

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;

  const _GlassContainer({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
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
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 50)],
      ),
    );
  }
}