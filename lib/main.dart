import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your local files
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Modern Indigo
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

    // 1. Listen for intent while app is running
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _handleSharedFiles(value, provider);
    }, onError: (err) {
      debugPrint("Intent Error: $err");
    });

    // 2. Handle intent if app was closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _handleSharedFiles(value, provider);
    });
  }

  void _handleSharedFiles(List<SharedMediaFile> files, SummaryProvider provider) {
    if (files.isNotEmpty) {
      String sharedText = files.first.path;
      if (sharedText.startsWith('http')) {
        _urlController.text = sharedText; // Update UI text field
        provider.processUrl(sharedText);
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _urlController.text = data!.text!;
      });
    }
  }

  void _handleManualSubmit() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty && text.startsWith('http')) {
      FocusScope.of(context).unfocus(); // Hide keyboard
      context.read<SummaryProvider>().processUrl(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid URL starting with http"),
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
      // Only show AppBar if we have a result to allow "Refresh/Back"
      appBar: state == AppState.success 
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: provider.reset,
              ),
              title: Text("Briefly", style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildBody(context, state, provider),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppState state, SummaryProvider provider) {
    switch (state) {
      case AppState.idle:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Hero Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, size: 64, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 32),
              
              Text(
                "What are we reading?",
                style: GoogleFonts.merriweather(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Paste a URL below or share from your browser.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16, 
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Input Section
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleManualSubmit(),
                style: GoogleFonts.inter(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "https://example.com/article...",
                  prefixIcon: const Icon(Icons.link_rounded, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste_rounded, color: Colors.indigo),
                    onPressed: _pasteFromClipboard,
                    tooltip: "Paste from Clipboard",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _handleManualSubmit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Summarize",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );

      case AppState.scraping:
      case AppState.summarizing:
        return const Center(
          child: Card(
            elevation: 0,
            color: Colors.white,
            child: ArticleSkeleton(),
          ),
        );

      case AppState.success:
        return Center(
          child: Card(
            elevation: 8,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SummaryCard(markdownContent: provider.summary!),
          ),
        );

      case AppState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
            const SizedBox(height: 24),
            Text(
              "Unable to summarize",
              style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: provider.reset,
              child: const Text("Try Again"),
            )
          ],
        );
    }
  }
}