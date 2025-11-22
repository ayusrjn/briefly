import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/summary_provider.dart';
import 'screens/download_screen.dart';

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
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
            letterSpacing: -0.5
          ),
          bodyLarge: GoogleFonts.inter(color: Colors.white70),
        ),
      ),
      // Start at DownloadScreen to ensure model is ready
      home: const DownloadScreen(), 
    );
  }
}