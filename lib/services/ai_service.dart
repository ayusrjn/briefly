import 'package:cactus/cactus.dart';

abstract class AIService {
  Future<String> summarize(String articleText);
}

class CactusAIService implements AIService {
  final CactusLM _lm = CactusLM(enableToolFiltering: false); // Disable tools for pure text tasks
  bool _isModelReady = false;
  
  // Using the Gemma 3 1 Billion Parameter model as it is efficient for mobile testing
  static const String _modelSlug = "gemma3-1b-it-q4_k_m"; 

  @override
  Future<String> summarize(String articleText) async {
    try {
      await _ensureModelLoaded();

      final result = await _lm.generateCompletion(
        messages: [
          ChatMessage(
            role: "user", 
            content: "Summarize the following news article in a clear, professional executive brief. Use bullet points for key takeaways:\n\n$articleText"
          ),
        ],
        params: CactusCompletionParams(
          maxTokens: 512,
          temperature: 0.7,
          stopSequences: ["<end_of_turn>", "<|im_end|>"],
        ),
      );

      if (!result.success) {
        throw Exception("Generation failed: ${result.response}");
      }

      return result.response;
    } catch (e) {
      throw Exception("AI Error: $e");
    }
  }

  Future<void> _ensureModelLoaded() async {
    if (_isModelReady) return;

    // 1. Check/Download Model
    // In a real app, you would expose this progress to the UI. 
    // For now, we await it.
    await _lm.downloadModel(
      model: _modelSlug,
      downloadProcessCallback: (progress, status, isError) {
        print("Cactus: $status ${(progress != null ? (progress * 100).toStringAsFixed(1) : '')}%");
      },
    );

    // 2. Initialize
    await _lm.initializeModel(
      params: CactusInitParams(
        model: _modelSlug,
        contextSize: 2048, // Sufficient for summaries
      ),
    );

    _isModelReady = true;
  }
  
  // Call this when app closes to free RAM
  void dispose() {
    _lm.unload();
  }
}