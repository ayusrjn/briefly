import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../services/ai_service.dart';

enum AppState { idle, scraping, summarizing, success, error }

class SummaryProvider extends ChangeNotifier {
  final ScraperService _scraper = ScraperService();
  final AIService _aiService = CactusAIService(); 

  AppState _state = AppState.idle;
  String? _summary;
  String? _errorMessage;
  String? _currentUrl;
  
  // NEW: Download State
  double _downloadProgress = 0.0;
  bool _isModelReady = false;

  AppState get state => _state;
  String? get summary => _summary;
  String? get errorMessage => _errorMessage;
  double get downloadProgress => _downloadProgress;
  bool get isModelReady => _isModelReady;

  // Check if we need to show the download screen
  Future<void> checkModelStatus() async {
    _isModelReady = await _aiService.isModelDownloaded();
    notifyListeners();
  }

  Future<void> downloadModel() async {
    try {
      await _aiService.downloadModel((progress) {
        _downloadProgress = progress;
        notifyListeners();
      });
      _isModelReady = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Download failed: $e";
      notifyListeners();
    }
  }

  Future<void> processUrl(String url) async {
    if (url.isEmpty || (url == _currentUrl && _state == AppState.success)) return;
    
    _currentUrl = url;
    _state = AppState.scraping;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanText = await _scraper.fetchAndClean(url);
      _state = AppState.summarizing;
      notifyListeners();

      final result = await _aiService.summarize(cleanText);
      
      _summary = result;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      _currentUrl = null; 
    }
    
    notifyListeners();
  }

  void reset() {
    _state = AppState.idle;
    _summary = null;
    _currentUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    if (_aiService is CactusAIService) {
      (_aiService as CactusAIService).dispose();
    }
    super.dispose();
  }
}