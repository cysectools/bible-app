import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String username;
  final String hexCode;
  final DateTime createdAt;
  final int copyCount;
  final DateTime? lastCopiedAt;

  UserProfile({
    required this.username,
    required this.hexCode,
    required this.createdAt,
    this.copyCount = 0,
    this.lastCopiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'hexCode': hexCode,
      'createdAt': createdAt.toIso8601String(),
      'copyCount': copyCount,
      'lastCopiedAt': lastCopiedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      hexCode: json['hexCode'],
      createdAt: DateTime.parse(json['createdAt']),
      copyCount: json['copyCount'] ?? 0,
      lastCopiedAt: json['lastCopiedAt'] != null 
          ? DateTime.parse(json['lastCopiedAt']) 
          : null,
    );
  }

  UserProfile copyWith({
    String? username,
    int? copyCount,
    DateTime? lastCopiedAt,
  }) {
    return UserProfile(
      username: username ?? this.username,
      hexCode: hexCode,
      createdAt: createdAt,
      copyCount: copyCount ?? this.copyCount,
      lastCopiedAt: lastCopiedAt ?? this.lastCopiedAt,
    );
  }

  bool get canCopy => copyCount < 2;
}

class UserService {
  static const String _userKey = 'user_profile';
  static const String _usersKey = 'all_users';

  static Future<UserProfile?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) return null;
      
      return UserProfile.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error loading current user: $e');
      return null;
    }
  }

  static Future<String> generateHexCode() async {
    final random = Random.secure();
    final bytes = List<int>.generate(5, (i) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return hex.toUpperCase();
  }

  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final userJson in usersJson) {
        final user = UserProfile.fromJson(jsonDecode(userJson));
        if (user.username.toLowerCase() == username.toLowerCase()) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  static Future<UserProfile?> createUser(String username) async {
    try {
      // Check if username is available
      if (!await isUsernameAvailable(username)) {
        throw Exception('Username already taken');
      }

      // Generate unique hex code
      String hexCode;
      bool isUnique = false;
      int attempts = 0;
      
      do {
        hexCode = await generateHexCode();
        isUnique = await isHexCodeAvailable(hexCode);
        attempts++;
        
        if (attempts > 100) {
          throw Exception('Unable to generate unique hex code');
        }
      } while (!isUnique);

      final user = UserProfile(
        username: username,
        hexCode: hexCode,
        createdAt: DateTime.now(),
      );

      // Save current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      // Add to all users list
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      usersJson.add(jsonEncode(user.toJson()));
      await prefs.setStringList(_usersKey, usersJson);

      return user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  static Future<bool> isHexCodeAvailable(String hexCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final userJson in usersJson) {
        final user = UserProfile.fromJson(jsonDecode(userJson));
        if (user.hexCode == hexCode) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking hex code availability: $e');
      return false;
    }
  }

  static Future<UserProfile?> getUserByHexCode(String hexCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final userJson in usersJson) {
        final user = UserProfile.fromJson(jsonDecode(userJson));
        if (user.hexCode == hexCode) {
          return user;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user by hex code: $e');
      return null;
    }
  }

  static Future<bool> updateUser(UserProfile user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update current user
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      // Update in all users list
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      final updatedUsers = usersJson.map((userJson) {
        final existingUser = UserProfile.fromJson(jsonDecode(userJson));
        if (existingUser.hexCode == user.hexCode) {
          return jsonEncode(user.toJson());
        }
        return userJson;
      }).toList();
      
      await prefs.setStringList(_usersKey, updatedUsers);
      
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> incrementCopyCount() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final updatedUser = user.copyWith(
        copyCount: user.copyCount + 1,
        lastCopiedAt: DateTime.now(),
      );

      return await updateUser(updatedUser);
    } catch (e) {
      print('Error incrementing copy count: $e');
      return false;
    }
  }

  static Future<bool> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove current user
      await prefs.remove(_userKey);
      
      // Remove from all users list
      final user = await getCurrentUser();
      if (user != null) {
        final usersJson = prefs.getStringList(_usersKey) ?? [];
        final updatedUsers = usersJson.where((userJson) {
          final existingUser = UserProfile.fromJson(jsonDecode(userJson));
          return existingUser.hexCode != user.hexCode;
        }).toList();
        
        await prefs.setStringList(_usersKey, updatedUsers);
      }
      
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
