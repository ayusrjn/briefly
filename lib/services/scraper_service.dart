import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ScraperService {
  static const int maxChars = 2000;

  Future<String> fetchAndClean(String url) async {
    try {
      // 1. Fetch the page
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      // 2. Parse HTML
      var document = parser.parse(response.body);

      // 3. Remove noise (Scripts, Styles, Nav, Footer, Ads)
      final noiseSelectors = [
        'script', 'style', 'noscript', 'nav', 'footer', 
        'header', 'aside', '.ad', '.advertisement'
      ];
      
      for (var selector in noiseSelectors) {
        document.querySelectorAll(selector).forEach((element) => element.remove());
      }

      // 4. Extract text from Body
      // We prefer the 'main' tag if it exists, otherwise fallback to body
      Element? contentRoot = document.querySelector('main') ?? document.body;
      String textContent = contentRoot?.text ?? "";

      // 5. Clean whitespace (convert multiple spaces/newlines to single space)
      String cleanText = textContent.replaceAll(RegExp(r'\s+'), ' ').trim();

      // 6. Truncate to fit context window
      if (cleanText.length > maxChars) {
        return cleanText.substring(0, maxChars) + "... [Truncated]";
      }

      return cleanText;
    } catch (e) {
      throw Exception('Could not read article: $e');
    }
  }
}