import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VersesService {
  static const String _versesKey = 'saved_verses';
  
  // Get all saved verses
  static Future<List<String>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versesJson = prefs.getString(_versesKey);
      if (versesJson != null) {
        final List<dynamic> versesList = json.decode(versesJson);
        return versesList.cast<String>();
      }
    } catch (e) {
      print('Error loading verses: $e');
    }
    return [];
  }
  
  // Add a new verse
  static Future<bool> add(String verse) async {
    try {
      final verses = await getAll();
      if (!verses.contains(verse)) {
        verses.insert(0, verse); // Add to beginning
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_versesKey, json.encode(verses));
        return true;
      }
    } catch (e) {
      print('Error adding verse: $e');
    }
    return false;
  }
  
  // Remove a verse
  static Future<bool> remove(String verse) async {
    try {
      final verses = await getAll();
      if (verses.remove(verse)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_versesKey, json.encode(verses));
        return true;
      }
    } catch (e) {
      print('Error removing verse: $e');
    }
    return false;
  }
  
  // Check if a verse exists
  static Future<bool> contains(String verse) async {
    final verses = await getAll();
    return verses.contains(verse);
  }
}
