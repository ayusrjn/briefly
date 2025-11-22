import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../services/ai_service.dart';

enum AppState { idle, scraping, summarizing, success, error }

class SummaryProvider extends ChangeNotifier {
  // The service that downloads the HTML
  final ScraperService _scraper = ScraperService();
  
  // The service that runs the local Gemma-3 model (Cactus)
  // We swapped this from MockAIService to CactusAIService
  final AIService _aiService = CactusAIService(); 

  AppState _state = AppState.idle;
  String? _summary;
  String? _errorMessage;
  String? _currentUrl;

  AppState get state => _state;
  String? get summary => _summary;
  String? get errorMessage => _errorMessage;

  /// Main entry point: Takes a URL, scrapes it, and summarizes it.
  Future<void> processUrl(String url) async {
    // Prevent processing empty URLs or reprocessing the exact same result
    if (url.isEmpty || (url == _currentUrl && _state == AppState.success)) return;
    
    _currentUrl = url;
    _state = AppState.scraping;
    _errorMessage = null; // Clear any previous errors
    notifyListeners();

    try {
      // Step 1: Fetch and clean the webpage text
      final cleanText = await _scraper.fetchAndClean(url);
      
      // Update state to show the "Thinking..." animation
      _state = AppState.summarizing;
      notifyListeners();

      // Step 2: Pass text to the local AI engine
      final result = await _aiService.summarize(cleanText);
      
      _summary = result;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      
      // CRITICAL: Reset the current URL.
      // This allows the user to hit "Try Again" or paste the same link 
      // without the app thinking "I'm already showing this URL".
      _currentUrl = null; 
    }
    
    notifyListeners();
  }

  /// Resets the app to the initial "Home" state
  void reset() {
    _state = AppState.idle;
    _summary = null;
    _currentUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Best practice: If your AIService has a dispose method (to unload models),
    // you can cast and call it here.
    if (_aiService is CactusAIService) {
      (_aiService as CactusAIService).dispose();
    }
    super.dispose();
  }
}