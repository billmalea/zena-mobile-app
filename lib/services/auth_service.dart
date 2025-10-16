import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Authentication Service for handling user authentication
/// Singleton pattern for consistent auth state across the app
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get access token for API requests
  Future<String?> getAccessToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.authCallbackUrl,
      );
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
