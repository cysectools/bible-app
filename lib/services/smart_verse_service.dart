import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmartVerseService {
  // Updated to use a more reliable Bible API
  static const String _baseUrl = 'https://bible-api.com';
  static const String _cacheKey = 'cached_verses_by_mood';
  static const String _lastFetchKey = 'last_verse_fetch';
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  // Mood keywords for AI-like categorization
  static final Map<String, List<String>> _moodKeywords = {
    'sad': [
      'brokenhearted', 'weary', 'burdened', 'crushed', 'wounds', 'heal', 'comfort',
      'sorrow', 'grief', 'tears', 'pain', 'suffering', 'trouble', 'distress'
    ],
    'happy': [
      'rejoice', 'joy', 'glad', 'celebration', 'blessed', 'praise', 'thanksgiving',
      'cheerful', 'merry', 'delight', 'happiness', 'celebration', 'festival'
    ],
    'angry': [
      'anger', 'wrath', 'fury', 'rage', 'bitterness', 'gentle', 'patient', 'forgive',
      'peace', 'calm', 'restraint', 'self-control', 'love', 'kindness'
    ],
    'anxious': [
      'anxiety', 'worry', 'fear', 'afraid', 'peace', 'calm', 'trust', 'faith',
      'rest', 'quiet', 'still', 'comfort', 'strength', 'courage'
    ],
    'grateful': [
      'thanks', 'grateful', 'thankful', 'praise', 'blessing', 'gift', 'goodness',
      'love', 'endures', 'forever', 'wonderful', 'deeds', 'extol'
    ],
    'peaceful': [
      'peace', 'calm', 'quiet', 'rest', 'still', 'serene', 'tranquil', 'gentle',
      'shepherd', 'green pastures', 'still waters', 'comfort', 'strength'
    ],
  };

  // Enhanced fallback verses with better variety
  static final Map<String, List<Map<String, String>>> _enhancedFallbackVerses = {
    'sad': [
      {'reference': 'Psalm 34:18', 'text': 'The Lord is close to the brokenhearted and saves those who are crushed in spirit.'},
      {'reference': 'Matthew 11:28', 'text': 'Come to me, all you who are weary and burdened, and I will give you rest.'},
      {'reference': 'Psalm 147:3', 'text': 'He heals the brokenhearted and binds up their wounds.'},
      {'reference': '1 Peter 5:7', 'text': 'Cast all your anxiety on him because he cares for you.'},
      {'reference': 'Zephaniah 3:17', 'text': 'The Lord your God is with you, the Mighty Warrior who saves.'},
      {'reference': 'Isaiah 41:10', 'text': 'So do not fear, for I am with you; do not be dismayed, for I am your God.'},
      {'reference': 'Psalm 23:4', 'text': 'Even though I walk through the darkest valley, I will fear no evil, for you are with me.'},
      {'reference': '2 Corinthians 1:3-4', 'text': 'Praise be to the God and Father of our Lord Jesus Christ, the Father of compassion and the God of all comfort.'},
    ],
    'happy': [
      {'reference': 'Psalm 118:24', 'text': 'This is the day the Lord has made; let us rejoice and be glad in it.'},
      {'reference': 'Philippians 4:4', 'text': 'Rejoice in the Lord always. I will say it again: Rejoice!'},
      {'reference': 'Nehemiah 8:10', 'text': 'The joy of the Lord is your strength.'},
      {'reference': 'Romans 8:28', 'text': 'And we know that in all things God works for the good of those who love him.'},
      {'reference': 'Psalm 100:1', 'text': 'Shout for joy to the Lord, all the earth!'},
      {'reference': 'Proverbs 17:22', 'text': 'A cheerful heart is good medicine, but a crushed spirit dries up the bones.'},
      {'reference': 'Psalm 16:11', 'text': 'You make known to me the path of life; you will fill me with joy in your presence.'},
      {'reference': 'Galatians 5:22', 'text': 'But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness.'},
    ],
    'angry': [
      {'reference': 'Psalm 37:7', 'text': 'Be still before the Lord and wait patiently for him; do not fret when people succeed in their ways.'},
      {'reference': 'Proverbs 15:1', 'text': 'A gentle answer turns away wrath, but a harsh word stirs up anger.'},
      {'reference': 'Ephesians 4:26', 'text': 'In your anger do not sin. Do not let the sun go down while you are still angry.'},
      {'reference': '1 Corinthians 13:4', 'text': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.'},
      {'reference': 'Ephesians 4:31', 'text': 'Get rid of all bitterness, rage and anger, brawling and slander.'},
      {'reference': 'Ecclesiastes 7:9', 'text': 'Do not be quickly provoked in your spirit, for anger resides in the lap of fools.'},
      {'reference': 'James 1:19', 'text': 'My dear brothers and sisters, take note of this: Everyone should be quick to listen, slow to speak and slow to become angry.'},
      {'reference': 'Proverbs 16:32', 'text': 'Better a patient person than a warrior, one with self-control than one who takes a city.'},
    ],
    'anxious': [
      {'reference': 'Philippians 4:6', 'text': 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.'},
      {'reference': '1 Peter 5:7', 'text': 'Cast all your anxiety on him because he cares for you.'},
      {'reference': 'John 14:27', 'text': 'Peace I leave with you; my peace I give you. I do not give to you as the world gives.'},
      {'reference': 'Psalm 94:19', 'text': 'When anxiety was great within me, your consolation brought me joy.'},
      {'reference': 'Psalm 27:1', 'text': 'The Lord is my light and my salvation—whom shall I fear?'},
      {'reference': 'Isaiah 26:3', 'text': 'You will keep in perfect peace those whose minds are steadfast, because they trust in you.'},
      {'reference': 'Matthew 6:34', 'text': 'Therefore do not worry about tomorrow, for tomorrow will worry about itself.'},
      {'reference': 'Psalm 55:22', 'text': 'Cast your cares on the Lord and he will sustain you; he will never let the righteous be shaken.'},
    ],
    'grateful': [
      {'reference': 'Psalm 107:1', 'text': 'Give thanks to the Lord, for he is good; his love endures forever.'},
      {'reference': '1 Thessalonians 5:18', 'text': 'Give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.'},
      {'reference': 'Psalm 9:1', 'text': 'I will give thanks to you, Lord, with all my heart; I will tell of all your wonderful deeds.'},
      {'reference': 'Psalm 95:2', 'text': 'Let us come before him with thanksgiving and extol him with music and song.'},
      {'reference': 'James 1:17', 'text': 'Every good and perfect gift is from above, coming down from the Father of the heavenly lights.'},
      {'reference': 'Colossians 3:17', 'text': 'And whatever you do, whether in word or deed, do it all in the name of the Lord Jesus, giving thanks to God the Father through him.'},
      {'reference': 'Psalm 136:1', 'text': 'Give thanks to the Lord, for he is good. His love endures forever.'},
      {'reference': 'Ephesians 5:20', 'text': 'Always giving thanks to God the Father for everything, in the name of our Lord Jesus Christ.'},
    ],
    'peaceful': [
      {'reference': 'John 14:27', 'text': 'Peace I leave with you; my peace I give you. I do not give to you as the world gives.'},
      {'reference': 'Psalm 29:11', 'text': 'The Lord gives strength to his people; the Lord blesses his people with peace.'},
      {'reference': 'Isaiah 26:3', 'text': 'You will keep in perfect peace those whose minds are steadfast, because they trust in you.'},
      {'reference': 'Philippians 4:7', 'text': 'And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.'},
      {'reference': 'Psalm 23:1', 'text': 'The Lord is my shepherd, I lack nothing.'},
      {'reference': 'Matthew 5:9', 'text': 'Blessed are the peacemakers, for they will be called children of God.'},
      {'reference': 'Psalm 4:8', 'text': 'In peace I will lie down and sleep, for you alone, Lord, make me dwell in safety.'},
      {'reference': 'Romans 5:1', 'text': 'Therefore, since we have been justified through faith, we have peace with God through our Lord Jesus Christ.'},
    ],
  };

  // Initialize the service and pre-fetch verses
  static Future<void> initialize() async {
    await _ensureVersesAreCached();
  }

  // Get a verse for a specific mood
  static Future<String> getVerseForMood(String mood) async {
    await _ensureVersesAreCached();
    
    final cachedVerses = await _getCachedVerses();
    final moodVerses = cachedVerses[mood.toLowerCase()] ?? [];
    
    if (moodVerses.isNotEmpty) {
      final random = Random().nextInt(moodVerses.length);
      final verse = moodVerses[random];
      return '${verse['text']} - ${verse['reference']}';
    }
    
    // Fallback to enhanced local verses
    final fallbackVerses = _enhancedFallbackVerses[mood.toLowerCase()] ?? _enhancedFallbackVerses['peaceful']!;
    final random = Random().nextInt(fallbackVerses.length);
    final verse = fallbackVerses[random];
    return '${verse['text']} - ${verse['reference']}';
  }

  // Ensure verses are cached and up to date
  static Future<void> _ensureVersesAreCached() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getString(_lastFetchKey);
    final now = DateTime.now();
    
    // Check if cache is expired or doesn't exist
    bool needsRefresh = true;
    if (lastFetch != null) {
      final lastFetchTime = DateTime.parse(lastFetch);
      needsRefresh = now.difference(lastFetchTime) > _cacheExpiry;
    }
    
    if (needsRefresh) {
      await _fetchAndCacheVerses();
    }
  }

  // Fetch verses from API and categorize them
  static Future<void> _fetchAndCacheVerses() async {
    try {
      print('🔄 Fetching fresh verses from API...');
      
      // Fetch multiple random verses from the API
      final List<Map<String, String>> allVerses = [];
      
      // Try a small number of API calls first to test connectivity
      int successfulCalls = 0;
      int maxAttempts = 5; // Reduced from 50 to be more efficient
      
      for (int i = 0; i < maxAttempts; i++) {
        try {
          final verse = await _fetchRandomVerseFromApi();
          if (verse != null) {
            allVerses.add(verse);
            successfulCalls++;
            print('✅ Successfully fetched verse ${i + 1}: ${verse['reference']}');
          }
        } catch (e) {
          print('❌ Error fetching verse ${i + 1}: $e');
          // If we get multiple failures, stop trying
          if (i >= 2 && successfulCalls == 0) {
            print('🛑 API appears to be down, stopping attempts');
            break;
          }
        }
        
        // Small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      print('📥 Fetched ${allVerses.length} verses from API ($successfulCalls/$maxAttempts successful)');
      
      if (allVerses.isEmpty || successfulCalls == 0) {
        print('⚠️ No verses fetched from API, using fallback verses');
        await _cacheVerses(_enhancedFallbackVerses);
        return;
      }
      
      // Categorize verses by mood
      final categorizedVerses = _categorizeVersesByMood(allVerses);
      
      // Merge with fallback verses for better coverage
      final finalVerses = _mergeWithFallbackVerses(categorizedVerses);
      
      // Cache the results
      await _cacheVerses(finalVerses);
      
      print('✅ Successfully cached verses for all moods');
      
    } catch (e) {
      print('❌ Error fetching verses from API: $e');
      // Use fallback verses if API fails completely
      await _cacheVerses(_enhancedFallbackVerses);
    }
  }

  // Fetch a single random verse from the API
  static Future<Map<String, String>?> _fetchRandomVerseFromApi() async {
    try {
      // Use a popular Bible verse reference for the API
      final popularReferences = [
        'John+3:16', 'Psalm+23', 'Philippians+4:13', 'Romans+8:28', 
        'Jeremiah+29:11', 'Proverbs+3:5-6', 'Matthew+11:28', 'Isaiah+40:31',
        '1+Corinthians+13:4-7', 'Ephesians+2:8-9', 'Galatians+5:22-23', 'Psalm+91:1-2'
      ];
      
      final randomRef = popularReferences[Random().nextInt(popularReferences.length)];
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$randomRef'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        // Check if response is JSON or HTML
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          print('⚠️ API returned non-JSON content: $contentType');
          print('Response preview: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
          return null;
        }
        
        final data = json.decode(response.body);
        final text = data['text']?.toString().trim();
        final reference = data['reference']?.toString();
        
        if (text != null && text.isNotEmpty && reference != null) {
          return {
            'text': text,
            'reference': reference,
          };
        }
      } else {
        print('⚠️ API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching random verse: $e');
    }
    
    return null;
  }

  // Categorize verses by mood using keyword matching
  static Map<String, List<Map<String, String>>> _categorizeVersesByMood(List<Map<String, String>> verses) {
    final categorized = <String, List<Map<String, String>>>{
      'sad': [],
      'happy': [],
      'angry': [],
      'anxious': [],
      'grateful': [],
      'peaceful': [],
    };
    
    for (final verse in verses) {
      final text = verse['text']?.toLowerCase() ?? '';
      final reference = verse['reference']?.toLowerCase() ?? '';
      final fullText = '$text $reference';
      
      // Score each mood based on keyword matches
      final moodScores = <String, int>{};
      
      for (final mood in _moodKeywords.keys) {
        int score = 0;
        for (final keyword in _moodKeywords[mood]!) {
          if (fullText.contains(keyword.toLowerCase())) {
            score++;
          }
        }
        moodScores[mood] = score;
      }
      
      // Find the mood with the highest score
      String bestMood = 'peaceful'; // Default fallback
      int highestScore = 0;
      
      for (final entry in moodScores.entries) {
        if (entry.value > highestScore) {
          highestScore = entry.value;
          bestMood = entry.key;
        }
      }
      
      // Only add if there's a meaningful match (score > 0)
      if (highestScore > 0) {
        categorized[bestMood]!.add(verse);
      } else {
        // If no clear match, add to peaceful as a neutral category
        categorized['peaceful']!.add(verse);
      }
    }
    
    return categorized;
  }

  // Merge API verses with fallback verses for better coverage
  static Map<String, List<Map<String, String>>> _mergeWithFallbackVerses(Map<String, List<Map<String, String>>> apiVerses) {
    final merged = <String, List<Map<String, String>>>{};
    
    for (final mood in _enhancedFallbackVerses.keys) {
      final apiVersesForMood = apiVerses[mood] ?? [];
      final fallbackVersesForMood = _enhancedFallbackVerses[mood] ?? [];
      
      // Combine API verses with fallback verses, removing duplicates
      final combined = <Map<String, String>>[];
      final seen = <String>{};
      
      // Add API verses first
      for (final verse in apiVersesForMood) {
        final key = '${verse['text']}-${verse['reference']}';
        if (!seen.contains(key)) {
          combined.add(verse);
          seen.add(key);
        }
      }
      
      // Add fallback verses if not already present
      for (final verse in fallbackVersesForMood) {
        final key = '${verse['text']}-${verse['reference']}';
        if (!seen.contains(key)) {
          combined.add(verse);
          seen.add(key);
        }
      }
      
      merged[mood] = combined;
    }
    
    return merged;
  }

  // Cache verses to SharedPreferences
  static Future<void> _cacheVerses(Map<String, List<Map<String, String>>> verses) async {
    final prefs = await SharedPreferences.getInstance();
    final versesJson = json.encode(verses);
    await prefs.setString(_cacheKey, versesJson);
    await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
  }

  // Get cached verses from SharedPreferences
  static Future<Map<String, List<Map<String, String>>>> _getCachedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final versesJson = prefs.getString(_cacheKey);
    
    if (versesJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(versesJson);
        return decoded.map((key, value) => MapEntry(
          key,
          List<Map<String, String>>.from(
            (value as List).map((v) => Map<String, String>.from(v))
          ),
        ));
      } catch (e) {
        print('Error decoding cached verses: $e');
      }
    }
    
    return _enhancedFallbackVerses;
  }

  // Force refresh the verse cache
  static Future<void> forceRefresh() async {
    await _fetchAndCacheVerses();
  }

  // Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    final cachedVerses = await _getCachedVerses();
    final stats = <String, int>{};
    
    for (final entry in cachedVerses.entries) {
      stats[entry.key] = entry.value.length;
    }
    
    return stats;
  }
}
