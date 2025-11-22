import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../services/ai_service.dart';

enum AppState { idle, scraping, summarizing, success, error }

class SummaryProvider extends ChangeNotifier {
  final ScraperService _scraper = ScraperService();
  final AIService _aiService = MockAIService(); // Swap this later

  AppState _state = AppState.idle;
  String? _summary;
  String? _errorMessage;
  String? _currentUrl;

  AppState get state => _state;
  String? get summary => _summary;
  String? get errorMessage => _errorMessage;

  Future<void> processUrl(String url) async {
    // Avoid re-processing same URL or empty strings
    if (url.isEmpty || url == _currentUrl) return;
    
    _currentUrl = url;
    _state = AppState.scraping;
    notifyListeners();

    try {
      // Step 1: Scrape
      final cleanText = await _scraper.fetchAndClean(url);
      
      _state = AppState.summarizing;
      notifyListeners();

      // Step 2: AI Summary
      final result = await _aiService.summarize(cleanText);
      
      _summary = result;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    }
    
    notifyListeners();
  }

  void reset() {
    _state = AppState.idle;
    _summary = null;
    _currentUrl = null;
    notifyListeners();
  }
}