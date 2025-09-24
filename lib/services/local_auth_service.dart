import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Simple local authentication service for testing
class LocalAuthService {
  static const String _userKey = 'bible_app_user';
  static const String _authKey = 'bible_app_auth';

  /// Sign in with email and password
  static Future<Map<String, dynamic>?> signInWithEmailPassword(
    String email, 
    String password
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        final users = List<Map<String, dynamic>>.from(
          jsonDecode(userData).map((user) => Map<String, dynamic>.from(user))
        );
        
        final user = users.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
          orElse: () => {},
        );
        
        if (user.isNotEmpty) {
          await prefs.setBool(_authKey, true);
          debugPrint('✅ Local sign-in successful');
          return user;
        }
      }
      
      debugPrint('❌ Invalid credentials');
      return null;
    } catch (e) {
      debugPrint('❌ Local sign-in error: $e');
      return null;
    }
  }

  /// Sign up with email and password
  static Future<Map<String, dynamic>?> signUpWithEmailPassword(
    String email, 
    String password, 
    String username
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      List<Map<String, dynamic>> users = [];
      if (userData != null) {
        users = List<Map<String, dynamic>>.from(
          jsonDecode(userData).map((user) => Map<String, dynamic>.from(user))
        );
      }
      
      // Check if email already exists
      if (users.any((user) => user['email'] == email)) {
        debugPrint('❌ Email already exists');
        return null;
      }
      
      // Create new user
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': password, // In production, hash this!
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      users.add(newUser);
      await prefs.setString(_userKey, jsonEncode(users));
      await prefs.setBool(_authKey, true);
      
      debugPrint('✅ Local sign-up successful');
      return newUser;
    } catch (e) {
      debugPrint('❌ Local sign-up error: $e');
      return null;
    }
  }

  /// Check if user is signed in
  static Future<bool> isSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_authKey) ?? false;
    } catch (e) {
      debugPrint('❌ Check auth error: $e');
      return false;
    }
  }

  /// Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        final users = List<Map<String, dynamic>>.from(
          jsonDecode(userData).map((user) => Map<String, dynamic>.from(user))
        );
        
        // Return the first user (simple implementation)
        return users.isNotEmpty ? users.first : null;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      return null;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, false);
      debugPrint('✅ Local sign-out successful');
    } catch (e) {
      debugPrint('❌ Local sign-out error: $e');
    }
  }

  /// Reset password (simple implementation)
  static Future<bool> resetPassword(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        final users = List<Map<String, dynamic>>.from(
          jsonDecode(userData).map((user) => Map<String, dynamic>.from(user))
        );
        
        final userIndex = users.indexWhere((user) => user['email'] == email);
        if (userIndex != -1) {
          // Simple reset - set password to "newpassword123"
          users[userIndex]['password'] = 'newpassword123';
          await prefs.setString(_userKey, jsonEncode(users));
          debugPrint('✅ Password reset successful. New password: newpassword123');
          return true;
        }
      }
      
      debugPrint('❌ Email not found');
      return false;
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      return false;
    }
  }
}
