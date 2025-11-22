import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/summary_provider.dart';
import 'widgets/article_skeleton.dart';
import 'widgets/summary_card.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SummaryProvider()),
      ],
      child: const BrieflyApp(),
    ),
  );
}

class BrieflyApp extends StatelessWidget {
  const BrieflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Briefly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115), // Deep Dark Background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Indigo Neon
          secondary: Color(0xFFA855F7), // Purple Neon
          surface: Color(0xFF1E293B),
        ),
        textTheme: TextTheme(
          displayMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5
          ),
          bodyLarge: GoogleFonts.inter(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

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
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) _processLink(value.first.path, provider);
    }, onError: (err) => debugPrint("Intent Error: $err"));

    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) _processLink(value.first.path, provider);
    });
  }

  void _processLink(String link, SummaryProvider provider) {
    if (link.startsWith('http')) {
      _urlController.text = link;
      provider.processUrl(link);
    }
  }

  void _handleManualSubmit() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty && text.startsWith('http')) {
      FocusScope.of(context).unfocus();
      context.read<SummaryProvider>().processUrl(text);
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
            child: _GlowBlob(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _GlowBlob(color: const Color(0xFFA855F7).withOpacity(0.3)),
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
      return const ArticleSkeleton(); // Ensure you have this widget file
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
                    if (data?.text != null) _urlController.text = data!.text!;
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
                        "Powered by Gemma-3 1BQ4 local model. No data leaves this device.",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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