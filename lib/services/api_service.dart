import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleApi {
  static Future<String> getVerse() async {
    // Try primary API first
    try {
      return await _getVerseFromOurManna(orderRandom: false);
    } catch (e) {
      print("❌ Primary API failed: $e");
      print("🔄 Trying fallback API...");
      return await _getVerseFromFallback();
    }
  }

  // Fetch a random verse on-demand (for the New Verse button)
  static Future<String> getRandomVerse() async {
    try {
      return await _getVerseFromOurManna(orderRandom: true);
    } catch (e) {
      print("❌ Random API failed: $e");
      return await _getVerseFromFallback();
    }
  }

  static Future<String> _getVerseFromOurManna({required bool orderRandom}) async {
    // Add a timestamp query param to bust caches when fetching random
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      orderRandom
          ? "https://beta.ourmanna.com/api/v1/get/?format=json&order=random&ts=$timestamp"
          : "https://beta.ourmanna.com/api/v1/get/?format=json",
    );
    print("🌐 Making request to: $url");
    
    final response = await http.get(
      url,
      headers: {
        // Best effort to avoid cached responses
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
    print("📡 Response status: ${response.statusCode}");
    print("📄 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("📊 Parsed data: $data");
      
      // Check if the expected structure exists
      if (data["verse"] != null && 
          data["verse"]["details"] != null && 
          data["verse"]["details"]["text"] != null) {
        return data["verse"]["details"]["text"] +
            " - " +
            data["verse"]["details"]["reference"];
      } else {
        print("❌ Unexpected JSON structure");
        throw Exception("Unexpected API response structure");
      }
    } else {
      throw Exception("Failed to load verse: HTTP ${response.statusCode}");
    }
  }

  static Future<String> _getVerseFromFallback() async {
    // Fallback to a simple verse
    final fallbackVerses = [
      "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16",
      "I can do all this through him who gives me strength. - Philippians 4:13",
      "Trust in the Lord with all your heart and lean not on your own understanding. - Proverbs 3:5",
      "The Lord is my shepherd, I lack nothing. - Psalm 23:1",
      "And we know that in all things God works for the good of those who love him. - Romans 8:28"
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % fallbackVerses.length;
    return fallbackVerses[random];
  }
}
