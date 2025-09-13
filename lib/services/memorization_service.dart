import 'package:shared_preferences/shared_preferences.dart';

class MemorizationService {
  static const String _key = 'memorized_verses';

  static Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  static Future<bool> add(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    if (current.contains(verse)) return false;
    current.add(verse);
    await prefs.setStringList(_key, current);
    return true;
  }

  static Future<bool> remove(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final removed = current.remove(verse);
    await prefs.setStringList(_key, current);
    return removed;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}


