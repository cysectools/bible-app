import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

/// Authentication service for Google Sign-In with Supabase
class AuthService {
  static SupabaseClient get client => Supabase.instance.client;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Sign in to Supabase with Google credentials
      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        debugPrint('✅ Google Sign-In successful');
        
        // Initialize user profile in database
        await _initializeUserProfile(response.user!);
        
        return response;
      } else {
        debugPrint('❌ Google Sign-In failed - no user returned');
        return null;
      }
    } catch (error) {
      debugPrint('❌ Google Sign-In error: $error');
      return null;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse?> signInWithEmailPassword(String email, String password) async {
    try {
      debugPrint('🔄 Starting Email/Password Sign-In...');
      
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ Email/password sign-in successful');
        return response;
      } else {
        debugPrint('❌ Email/password sign-in failed: No user returned');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Email/password sign-in error: $e');
      return null;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse?> signUpWithEmailPassword(String email, String password, String username) async {
    try {
      debugPrint('🔄 Starting Email/Password Sign-Up...');
      
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile with username
        await DatabaseService.createUserProfile(
          userId: response.user!.id,
          email: email,
          username: username,
        );
        
        debugPrint('✅ Email/password sign-up successful');
        return response;
      } else {
        debugPrint('❌ Email/password sign-up failed: No user returned');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Email/password sign-up error: $e');
      return null;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      debugPrint('🔄 Sending password reset email...');
      await client.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent');
      return true;
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🔄 Signing out...');
      
      await Future.wait([
        client.auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      debugPrint('✅ Sign out successful');
    } catch (error) {
      debugPrint('❌ Sign out error: $error');
    }
  }

  /// Initialize user profile in database
  Future<void> _initializeUserProfile(User user) async {
    try {
      // Check if profile already exists
      final existingProfile = await DatabaseService.getUserProfile(user.id);
      
      if (existingProfile == null) {
        // Create new profile
        final profile = {
          'name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User',
          'email': user.email,
          'avatar_url': user.userMetadata?['avatar_url'],
        };
        
        await DatabaseService.saveUserProfile(user.id, profile);
        
        // Initialize user stats
        await DatabaseService.updateUserStats(user.id, {
          'total_practices': 0,
          'drag_drop_completed': 0,
          'writing_completed': 0,
          'drag_drop_streak': 0,
          'writing_streak': 0,
          'perfect_scores': 0,
          'total_score': 0,
        });
        
        debugPrint('✅ User profile initialized');
      } else {
        debugPrint('ℹ️ User profile already exists');
      }
    } catch (error) {
      debugPrint('❌ Error initializing user profile: $error');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isSignedIn) return null;
    
    try {
      return await DatabaseService.getUserProfile(userId!);
    } catch (error) {
      debugPrint('❌ Error getting user profile: $error');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isSignedIn) return false;
    
    try {
      return await DatabaseService.saveUserProfile(userId!, updates);
    } catch (error) {
      debugPrint('❌ Error updating user profile: $error');
      return false;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Auth state provider for managing authentication state
class AuthStateProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get userId => _user?.id;

  /// Initialize auth state
  void initialize() {
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((AuthState data) {
      _user = data.session?.user;
      notifyListeners();
      
      if (_user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    
    try {
      final response = await _authService.signInWithGoogle();
      if (response?.user != null) {
        _user = response!.user;
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('❌ Sign in error: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    
    try {
      final response = await _authService.signInWithEmailPassword(email, password);
      if (response?.user != null) {
        _user = response!.user;
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('❌ Email/password sign in error: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailPassword(String email, String password, String username) async {
    _setLoading(true);
    
    try {
      final response = await _authService.signUpWithEmailPassword(email, password, username);
      if (response?.user != null) {
        _user = response!.user;
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('❌ Email/password sign up error: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (error) {
      debugPrint('❌ Password reset error: $error');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      notifyListeners();
    } catch (error) {
      debugPrint('❌ Sign out error: $error');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      _userProfile = await _authService.getUserProfile();
      notifyListeners();
    } catch (error) {
      debugPrint('❌ Error loading user profile: $error');
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;
    
    try {
      final success = await _authService.updateUserProfile(updates);
      if (success) {
        await _loadUserProfile();
      }
      return success;
    } catch (error) {
      debugPrint('❌ Error updating user profile: $error');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
