import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'dart:async';

/// Authentication Provider for managing user authentication state
/// Uses ChangeNotifier to notify UI of authentication changes
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider() {
    _initialize();
  }

  /// Get current user
  User? get user => _user;

  /// Check if user is authenticated
  bool get isAuthenticated => _user != null;

  /// Check if authentication is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get error => _error;

  /// Initialize provider and listen to auth state changes
  void _initialize() {
    // Set initial user state
    _user = _authService.currentUser;
    _isLoading = false;
    notifyListeners();

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      (AuthState authState) {
        _user = authState.session?.user;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Authentication error: ${error.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithGoogle();

      // State will be updated by authStateChanges listener
    } catch (e) {
      _error = 'Failed to sign in: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();

      // State will be updated by authStateChanges listener
    } catch (e) {
      _error = 'Failed to sign out: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
