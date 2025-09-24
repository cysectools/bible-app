import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../widgets/simple_language_selector.dart';
import '../providers/app_state_provider.dart';
import '../providers/local_auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A4C93),
              Color(0xFF9B59B6),
              Color(0xFF8E44AD),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Consumer<AppStateProvider>(
                          builder: (context, appState, child) {
                            return Text(
                              appState.translate(AppTranslations.welcome),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Consumer<AppStateProvider>(
                          builder: (context, appState, child) {
                            return Text(
                              appState.translate(AppTranslations.loginSubtitle),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Language Selector
                  const SimpleLanguageSelector(),

                  const SizedBox(height: 40),

                  // Authentication Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Toggle between Sign In and Sign Up
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<AppStateProvider>(
                                  builder: (context, appState, child) {
                                    return ElevatedButton(
                                      onPressed: () => setState(() => _isSignUp = false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isSignUp 
                                            ? Colors.transparent 
                                            : Colors.white.withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                      child: Text(appState.translate('sign_in')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Consumer<AppStateProvider>(
                                  builder: (context, appState, child) {
                                    return ElevatedButton(
                                      onPressed: () => setState(() => _isSignUp = true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isSignUp 
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : Colors.transparent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                      child: Text(appState.translate('sign_up')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Username field (only for sign up)
                          if (_isSignUp) ...[
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white70),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                              ),
                              validator: (value) {
                                if (_isSignUp && (value == null || value.isEmpty)) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.email, color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Submit button
                          Consumer2<LocalAuthProvider, AppStateProvider>(
                            builder: (context, authState, appState, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: authState.isLoading ? null : _handleSubmit,
                                  icon: authState.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Icon(
                                          _isSignUp ? Icons.person_add : Icons.login,
                                          color: Colors.black87,
                                        ),
                                  label: Text(
                                    authState.isLoading
                                        ? appState.translate(AppTranslations.signingIn)
                                        : _isSignUp 
                                            ? appState.translate('sign_up')
                                            : appState.translate('sign_in'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    elevation: 8,
                                    shadowColor: Colors.black.withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Forgot password button
                          if (!_isSignUp)
                            TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                          // Google Sign In Button
                          Consumer2<LocalAuthProvider, AppStateProvider>(
                            builder: (context, authState, appState, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                          icon: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.login, color: Colors.black87);
                                  },
                                ),
                          label: Text(
                            authState.isLoading
                                ? appState.translate(AppTranslations.signingIn)
                                : appState.translate(AppTranslations.signInWithGoogle),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Terms and Privacy
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return Text(
                        appState.translate(AppTranslations.loginTerms),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<LocalAuthProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    try {
      bool success;
      if (_isSignUp) {
        success = await authState.signUpWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _usernameController.text.trim(),
        );
      } else {
        success = await authState.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.translate(AppTranslations.signInFailed)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appState.translate(AppTranslations.signInError)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // For now, disable Google Sign-In and show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In temporarily disabled. Please use email/password.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authState = Provider.of<LocalAuthProvider>(context, listen: false);
    final success = await authState.resetPassword(email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Password reset! New password: newpassword123'
                : 'Failed to reset password',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}