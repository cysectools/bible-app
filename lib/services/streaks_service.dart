import 'package:shared_preferences/shared_preferences.dart';

class StreaksService {
  static const String _lastMoodSelectionKey = 'last_mood_selection_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';

  // Get current streak count
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  // Get longest streak count
  static Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  // Record mood selection and update streak
  static Future<int> recordMoodSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get last mood selection date
    final lastSelectionString = prefs.getString(_lastMoodSelectionKey);
    DateTime? lastSelection;
    
    if (lastSelectionString != null) {
      lastSelection = DateTime.parse(lastSelectionString);
      lastSelection = DateTime(lastSelection.year, lastSelection.month, lastSelection.day);
    }
    
    // Get current streak
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    
    // Check if this is a new day
    if (lastSelection == null || !lastSelection.isAtSameMomentAs(today)) {
      // Check if it's consecutive (yesterday)
      if (lastSelection != null) {
        final yesterday = today.subtract(const Duration(days: 1));
        if (lastSelection.isAtSameMomentAs(yesterday)) {
          // Consecutive day - increment streak
          currentStreak++;
        } else {
          // Not consecutive - reset streak
          currentStreak = 1;
        }
      } else {
        // First time - start streak
        currentStreak = 1;
      }
      
      // Update longest streak if current is higher
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        await prefs.setInt(_longestStreakKey, longestStreak);
      }
      
      // Save current streak and today's date
      await prefs.setInt(_currentStreakKey, currentStreak);
      await prefs.setString(_lastMoodSelectionKey, today.toIso8601String());
    }
    
    return currentStreak;
  }

  // Check if user has selected mood today
  static Future<bool> hasSelectedMoodToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSelectionString = prefs.getString(_lastMoodSelectionKey);
    
    if (lastSelectionString == null) return false;
    
    final lastSelection = DateTime.parse(lastSelectionString);
    final today = DateTime.now();
    
    return lastSelection.year == today.year &&
           lastSelection.month == today.month &&
           lastSelection.day == today.day;
  }

  // Reset streak (for testing or if needed)
  static Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_lastMoodSelectionKey);
  }
}
