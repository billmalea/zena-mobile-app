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
    print('🚀 [AuthProvider] Initializing...');
    
    // Set initial user state
    _user = _authService.currentUser;
    _isLoading = false;
    print('👤 [AuthProvider] Initial user: ${_user?.email ?? "None"}');
    notifyListeners();

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      (AuthState authState) {
        print('🔄 [AuthProvider] Auth state changed');
        print('📧 [AuthProvider] User: ${authState.session?.user.email ?? "None"}');
        print('🎟️ [AuthProvider] Session: ${authState.session != null}');
        print('📅 [AuthProvider] Event: ${authState.event}');
        
        _user = authState.session?.user;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        print('❌ [AuthProvider] Auth state error: $error');
        print('📍 [AuthProvider] Stack trace: $stackTrace');
        _error = 'Authentication error: ${error.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      print('🔐 [AuthProvider] Starting sign-in process...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('📞 [AuthProvider] Calling AuthService.signInWithGoogle()...');
      await _authService.signInWithGoogle();
      print('✅ [AuthProvider] AuthService.signInWithGoogle() completed');

      // State will be updated by authStateChanges listener
    } catch (e, stackTrace) {
      print('❌ [AuthProvider] Sign-in error: $e');
      print('📍 [AuthProvider] Stack trace: $stackTrace');
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
