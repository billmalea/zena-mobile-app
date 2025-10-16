import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';

/// Authentication Service for handling user authentication
/// Singleton pattern for consistent auth state across the app
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Google Sign In instance configured with web client ID
  /// Android: Works automatically with package name + SHA-1
  /// iOS: Needs clientId (add when testing on iOS)
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleWebClientId, // For Supabase verification
    // clientId is only needed for iOS, leave it out for Android
  );

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get access token for API requests
  Future<String?> getAccessToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  /// Sign in with Google using native Google Sign-In
  /// This provides a better UX than web-based OAuth
  Future<void> signInWithGoogle() async {
    try {
      print('🔐 [AuthService] Initializing Google Sign-In...');
      print(
          '📋 [AuthService] Server Client ID: ${AppConfig.googleWebClientId}');
      print('📦 [AuthService] Expected Package Name: com.zena.mobile');
      print(
          '⚠️ [AuthService] Make sure you created Android OAuth Client in Google Cloud Console!');
      print('⚠️ [AuthService] Package name must be: com.zena.mobile');
      print('⚠️ [AuthService] SHA-1 must be added to the Android client');

      // Trigger the Google Sign-In flow
      print('👤 [AuthService] Launching Google Sign-In UI...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        print('⚠️ [AuthService] User cancelled Google Sign-In');
        throw AuthException('Google sign-in was cancelled');
      }

      print('✅ [AuthService] Google user selected: ${googleUser.email}');

      // Obtain the auth details from the request
      print('🔑 [AuthService] Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the ID token
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      print('🎫 [AuthService] ID Token present: ${idToken != null}');
      print('🎫 [AuthService] Access Token present: ${accessToken != null}');

      if (idToken == null) {
        print('❌ [AuthService] ID token is null!');
        throw AuthException('Failed to get ID token from Google');
      }

      // Sign in to Supabase using the ID token
      print('📤 [AuthService] Sending ID token to Supabase...');
      print('🔗 [AuthService] Supabase URL: ${AppConfig.supabaseUrl}');

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print('✅ [AuthService] Supabase sign-in response received');
      print('👤 [AuthService] User ID: ${response.user?.id}');
      print('📧 [AuthService] User Email: ${response.user?.email}');
      print('🎟️ [AuthService] Session present: ${response.session != null}');
    } catch (e, stackTrace) {
      print('❌ [AuthService] Error during sign-in: $e');
      print('📍 [AuthService] Error type: ${e.runtimeType}');
      print('📍 [AuthService] Stack trace: $stackTrace');

      // Clean up Google sign-in state on error
      print('🧹 [AuthService] Cleaning up Google Sign-In state...');
      await _googleSignIn.signOut();

      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Supabase
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
