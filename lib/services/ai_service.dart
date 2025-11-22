abstract class AIService {
  Future<String> summarize(String articleText);
}

class MockAIService implements AIService {
  @override
  Future<String> summarize(String articleText) async {
    // Simulate network/processing delay
    await Future.delayed(const Duration(seconds: 2));

    return """
## Brief Summary

This is a **simulated summary** of the content you shared. 

* **Point 1**: The article discusses significant events extracted from the HTML.
* **Point 2**: It was successfully truncated to under 2000 characters.
* **Point 3**: The AI model (currently a mock) processed the input.

**Conclusion:**
The scraping logic worked, and the UI is ready for the real Cactus LLM integration.
    """;
  }
}