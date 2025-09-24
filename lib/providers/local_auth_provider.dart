import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';

class LocalAuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isSignedIn = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  /// Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final isAuth = await LocalAuthService.isSignedIn();
      if (isAuth) {
        _user = await LocalAuthService.getCurrentUser();
        _isSignedIn = _user != null;
      }
    } catch (e) {
      debugPrint('❌ Local auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    
    try {
      final user = await LocalAuthService.signInWithEmailPassword(email, password);
      if (user != null) {
        _user = user;
        _isSignedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('❌ Local sign in error: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailPassword(String email, String password, String username) async {
    _setLoading(true);
    
    try {
      final user = await LocalAuthService.signUpWithEmailPassword(email, password, username);
      if (user != null) {
        _user = user;
        _isSignedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('❌ Local sign up error: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      return await LocalAuthService.resetPassword(email);
    } catch (error) {
      debugPrint('❌ Local password reset error: $error');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await LocalAuthService.signOut();
      _user = null;
      _isSignedIn = false;
      notifyListeners();
    } catch (error) {
      debugPrint('❌ Local sign out error: $error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
