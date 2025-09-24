import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Database service for managing user data, progress, and badges
class DatabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Initialize Supabase (you'll need to add your project URL and anon key)
  static Future<void> initialize() async {
    // TODO: Replace with your actual Supabase project credentials
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL', // Replace with your Supabase project URL
      anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
    );
  }

  /// Clean up all data and start fresh (use with caution!)
  static Future<bool> cleanupAllData() async {
    try {
      debugPrint('🧹 Starting database cleanup...');
      
      // Delete all user profiles
      await client.from('user_profiles').delete().neq('id', 'never_exists');
      
      // Delete all practice progress
      await client.from('practice_progress').delete().neq('id', 'never_exists');
      
      // Delete all badges
      await client.from('user_badges').delete().neq('id', 'never_exists');
      
      debugPrint('✅ Database cleanup completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Database cleanup failed: $e');
      return false;
    }
  }

  /// User profile operations
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Create user profile
  static Future<bool> createUserProfile({
    required String userId,
    required String email,
    required String username,
  }) async {
    try {
      await client.from('user_profiles').insert({
        'user_id': userId,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ User profile created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      return false;
    }
  }

  static Future<bool> saveUserProfile(String userId, Map<String, dynamic> profile) async {
    try {
      await client
          .from('user_profiles')
          .upsert({
            'user_id': userId,
            ...profile,
            'updated_at': DateTime.now().toIso8601String(),
          });
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  /// Practice progress operations
  static Future<Map<String, dynamic>?> getPracticeProgress(String userId, String practiceType) async {
    try {
      final response = await client
          .from('practice_progress')
          .select()
          .eq('user_id', userId)
          .eq('practice_type', practiceType)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error getting practice progress: $e');
      return null;
    }
  }

  static Future<bool> savePracticeProgress(
    String userId, 
    String practiceType, 
    Map<String, dynamic> progress
  ) async {
    try {
      await client
          .from('practice_progress')
          .upsert({
            'user_id': userId,
            'practice_type': practiceType,
            ...progress,
            'updated_at': DateTime.now().toIso8601String(),
          });
      return true;
    } catch (e) {
      debugPrint('Error saving practice progress: $e');
      return false;
    }
  }

  /// Badge operations
  static Future<List<Map<String, dynamic>>> getUserBadges(String userId) async {
    try {
      final response = await client
          .from('user_badges')
          .select('*, badges(*)')
          .eq('user_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user badges: $e');
      return [];
    }
  }

  static Future<bool> awardBadge(String userId, String badgeId) async {
    try {
      await client
          .from('user_badges')
          .insert({
            'user_id': userId,
            'badge_id': badgeId,
            'earned_at': DateTime.now().toIso8601String(),
          });
      return true;
    } catch (e) {
      debugPrint('Error awarding badge: $e');
      return false;
    }
  }

  /// Stats operations
  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final response = await client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }

  static Future<bool> updateUserStats(String userId, Map<String, dynamic> stats) async {
    try {
      await client
          .from('user_stats')
          .upsert({
            'user_id': userId,
            ...stats,
            'updated_at': DateTime.now().toIso8601String(),
          });
      return true;
    } catch (e) {
      debugPrint('Error updating user stats: $e');
      return false;
    }
  }

  /// Get all available badges
  static Future<List<Map<String, dynamic>>> getAllBadges() async {
    try {
      final response = await client
          .from('badges')
          .select()
          .order('id');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting badges: $e');
      return [];
    }
  }
}

/// Badge definitions
class BadgeDefinitions {
  static const List<Map<String, dynamic>> defaultBadges = [
    {
      'id': 'first_drag_drop_complete',
      'name': 'Drag Master',
      'description': 'Complete your first drag and drop practice',
      'icon': '🎯',
      'color': '#4CAF50',
    },
    {
      'id': 'first_writing_complete',
      'name': 'Scribe',
      'description': 'Complete your first writing practice',
      'icon': '✍️',
      'color': '#2196F3',
    },
    {
      'id': 'drag_drop_streak_3',
      'name': 'Drag Champion',
      'description': 'Complete 3 drag and drop practices in a row',
      'icon': '🏆',
      'color': '#FF9800',
    },
    {
      'id': 'writing_streak_3',
      'name': 'Writing Wizard',
      'description': 'Complete 3 writing practices in a row',
      'icon': '📝',
      'color': '#9C27B0',
    },
    {
      'id': 'perfect_score_5',
      'name': 'Perfectionist',
      'description': 'Get perfect scores on 5 practices',
      'icon': '⭐',
      'color': '#FFD700',
    },
    {
      'id': 'total_practices_10',
      'name': 'Dedicated Learner',
      'description': 'Complete 10 total practices',
      'icon': '🎓',
      'color': '#607D8B',
    },
    {
      'id': 'total_practices_25',
      'name': 'Bible Scholar',
      'description': 'Complete 25 total practices',
      'icon': '📚',
      'color': '#795548',
    },
    {
      'id': 'total_practices_50',
      'name': 'Bible Master',
      'description': 'Complete 50 total practices',
      'icon': '👑',
      'color': '#E91E63',
    },
  ];

  /// Check if user should earn a badge
  static Future<List<String>> checkBadges(String userId, Map<String, dynamic> stats) async {
    final earnedBadges = <String>[];
    
    // Get existing badges
    final existingBadges = await DatabaseService.getUserBadges(userId);
    final existingBadgeIds = existingBadges.map((b) => b['badge_id'] as String).toSet();
    
    // Check each badge condition
    for (final badge in defaultBadges) {
      if (existingBadgeIds.contains(badge['id'])) continue;
      
      bool shouldEarn = false;
      
      switch (badge['id']) {
        case 'first_drag_drop_complete':
          shouldEarn = (stats['drag_drop_completed'] ?? 0) >= 1;
          break;
        case 'first_writing_complete':
          shouldEarn = (stats['writing_completed'] ?? 0) >= 1;
          break;
        case 'drag_drop_streak_3':
          shouldEarn = (stats['drag_drop_streak'] ?? 0) >= 3;
          break;
        case 'writing_streak_3':
          shouldEarn = (stats['writing_streak'] ?? 0) >= 3;
          break;
        case 'perfect_score_5':
          shouldEarn = (stats['perfect_scores'] ?? 0) >= 5;
          break;
        case 'total_practices_10':
          shouldEarn = (stats['total_practices'] ?? 0) >= 10;
          break;
        case 'total_practices_25':
          shouldEarn = (stats['total_practices'] ?? 0) >= 25;
          break;
        case 'total_practices_50':
          shouldEarn = (stats['total_practices'] ?? 0) >= 50;
          break;
      }
      
      if (shouldEarn) {
        await DatabaseService.awardBadge(userId, badge['id']);
        earnedBadges.add(badge['id']);
      }
    }
    
    return earnedBadges;
  }
}
