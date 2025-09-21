import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class BibleApi {
  static const String _baseUrl = 'https://bible-api.com';
  static const String _esvApiUrl = 'https://api.esv.org/v3/passage/text';
  static const String _esvApiKey = 'TEST'; // You'll need to get a real API key from ESV.org
  
  // Popular Bible verses for different moods
  static final Map<String, List<Map<String, String>>> _moodVerses = {
    'sad': [
      {'reference': 'Psalm 34:18', 'text': 'The Lord is close to the brokenhearted and saves those who are crushed in spirit.'},
      {'reference': 'Matthew 11:28', 'text': 'Come to me, all you who are weary and burdened, and I will give you rest.'},
      {'reference': 'Psalm 147:3', 'text': 'He heals the brokenhearted and binds up their wounds.'},
      {'reference': '1 Peter 5:7', 'text': 'Cast all your anxiety on him because he cares for you.'},
      {'reference': 'Zephaniah 3:17', 'text': 'The Lord your God is with you, the Mighty Warrior who saves.'},
      {'reference': 'Isaiah 41:10', 'text': 'So do not fear, for I am with you; do not be dismayed, for I am your God.'},
    ],
    'happy': [
      {'reference': 'Psalm 118:24', 'text': 'This is the day the Lord has made; let us rejoice and be glad in it.'},
      {'reference': 'Philippians 4:4', 'text': 'Rejoice in the Lord always. I will say it again: Rejoice!'},
      {'reference': 'Nehemiah 8:10', 'text': 'The joy of the Lord is your strength.'},
      {'reference': 'Romans 8:28', 'text': 'And we know that in all things God works for the good of those who love him.'},
      {'reference': 'Psalm 100:1', 'text': 'Shout for joy to the Lord, all the earth!'},
      {'reference': 'Proverbs 17:22', 'text': 'A cheerful heart is good medicine, but a crushed spirit dries up the bones.'},
    ],
    'angry': [
      {'reference': 'Psalm 37:7', 'text': 'Be still before the Lord and wait patiently for him; do not fret when people succeed in their ways.'},
      {'reference': 'Proverbs 15:1', 'text': 'A gentle answer turns away wrath, but a harsh word stirs up anger.'},
      {'reference': 'Ephesians 4:26', 'text': 'In your anger do not sin. Do not let the sun go down while you are still angry.'},
      {'reference': '1 Corinthians 13:4', 'text': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.'},
      {'reference': 'Ephesians 4:31', 'text': 'Get rid of all bitterness, rage and anger, brawling and slander.'},
      {'reference': 'Ecclesiastes 7:9', 'text': 'Do not be quickly provoked in your spirit, for anger resides in the lap of fools.'},
    ],
    'anxious': [
      {'reference': 'Philippians 4:6', 'text': 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.'},
      {'reference': '1 Peter 5:7', 'text': 'Cast all your anxiety on him because he cares for you.'},
      {'reference': 'John 14:27', 'text': 'Peace I leave with you; my peace I give you. I do not give to you as the world gives.'},
      {'reference': 'Psalm 94:19', 'text': 'When anxiety was great within me, your consolation brought me joy.'},
      {'reference': 'Psalm 27:1', 'text': 'The Lord is my light and my salvation—whom shall I fear?'},
      {'reference': 'Isaiah 26:3', 'text': 'You will keep in perfect peace those whose minds are steadfast, because they trust in you.'},
    ],
    'grateful': [
      {'reference': 'Psalm 107:1', 'text': 'Give thanks to the Lord, for he is good; his love endures forever.'},
      {'reference': '1 Thessalonians 5:18', 'text': 'Give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.'},
      {'reference': 'Psalm 9:1', 'text': 'I will give thanks to you, Lord, with all my heart; I will tell of all your wonderful deeds.'},
      {'reference': 'Psalm 95:2', 'text': 'Let us come before him with thanksgiving and extol him with music and song.'},
      {'reference': 'James 1:17', 'text': 'Every good and perfect gift is from above, coming down from the Father of the heavenly lights.'},
      {'reference': 'Colossians 3:17', 'text': 'And whatever you do, whether in word or deed, do it all in the name of the Lord Jesus, giving thanks to God the Father through him.'},
    ],
    'peaceful': [
      {'reference': 'John 14:27', 'text': 'Peace I leave with you; my peace I give you. I do not give to you as the world gives.'},
      {'reference': 'Psalm 29:11', 'text': 'The Lord gives strength to his people; the Lord blesses his people with peace.'},
      {'reference': 'Isaiah 26:3', 'text': 'You will keep in perfect peace those whose minds are steadfast, because they trust in you.'},
      {'reference': 'Philippians 4:7', 'text': 'And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.'},
      {'reference': 'Psalm 23:1', 'text': 'The Lord is my shepherd, I lack nothing.'},
      {'reference': 'Matthew 5:9', 'text': 'Blessed are the peacemakers, for they will be called children of God.'},
    ],
  };

  // Get a random verse from the Bible API
  static Future<String> getRandomVerse() async {
    try {
      // List of popular verses to choose from
      final popularVerses = [
        'john+3:16',
        'psalm+23:1',
        'jeremiah+29:11',
        'romans+8:28',
        'philippians+4:13',
        'proverbs+3:5-6',
        'isaiah+40:31',
        'matthew+11:28',
        'psalm+46:10',
        'john+14:27',
      ];
      
      final randomVerse = popularVerses[Random().nextInt(popularVerses.length)];
      final response = await http.get(
        Uri.parse('$_baseUrl/$randomVerse'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['text']?.toString().trim();
        final reference = data['reference']?.toString();
        
        if (text != null && text.isNotEmpty) {
          return '$text - $reference';
        }
      }
    } catch (e) {
      print('Error fetching random verse: $e');
    }
    
    // Fallback verse
    return 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16';
  }

  // Get verses by mood with enhanced functionality
  static Future<List<String>> getVersesByMood(String mood) async {
    final verses = _moodVerses[mood.toLowerCase()] ?? _moodVerses['peaceful']!;
    return verses.map((verse) => '${verse['text']} - ${verse['reference']}').toList();
  }

  // Get a specific verse by reference
  static Future<String> getVerseByReference(String reference) async {
    try {
      final cleanReference = reference.replaceAll(' ', '+');
      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanReference'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['text']?.toString().trim();
        final ref = data['reference']?.toString();
        
        if (text != null && text.isNotEmpty) {
          return '$text - $ref';
        }
      }
    } catch (e) {
      print('Error fetching verse by reference: $e');
    }
    
    return 'Unable to fetch verse. Please check your internet connection.';
  }

  // Search for verses containing specific keywords
  static Future<List<String>> searchVerses(String query) async {
    try {
      // This is a simplified search - in a real app you'd use a proper Bible search API
      final allVerses = <String>[];
      
      for (final mood in _moodVerses.values) {
        for (final verse in mood) {
          if (verse['text']!.toLowerCase().contains(query.toLowerCase()) ||
              verse['reference']!.toLowerCase().contains(query.toLowerCase())) {
            allVerses.add('${verse['text']} - ${verse['reference']}');
          }
        }
      }
      
      return allVerses.take(10).toList(); // Limit to 10 results
    } catch (e) {
      print('Error searching verses: $e');
      return [];
    }
  }

  // Get daily verse (could be enhanced with a real daily verse API)
  static Future<String> getDailyVerse() async {
    try {
      // Use current date to get a consistent daily verse
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      
      final dailyVerses = [
        'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16',
        'Trust in the Lord with all your heart and lean not on your own understanding. - Proverbs 3:5',
        'I can do all this through him who gives me strength. - Philippians 4:13',
        'The Lord is my shepherd, I lack nothing. - Psalm 23:1',
        'And we know that in all things God works for the good of those who love him. - Romans 8:28',
      ];
      
      return dailyVerses[dayOfYear % dailyVerses.length];
    } catch (e) {
      return 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. - John 3:16';
    }
  }

  // Get verse of the day with enhanced formatting
  static Future<Map<String, String>> getVerseOfTheDay() async {
    final verse = await getDailyVerse();
    final parts = verse.split(' - ');
    
    return {
      'text': parts.length > 1 ? parts[0] : verse,
      'reference': parts.length > 1 ? parts[1] : 'Unknown',
      'date': DateTime.now().toIso8601String().split('T')[0],
    };
  }
}
