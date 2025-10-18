import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
/// Contains API URLs, Supabase credentials, and other app-wide settings
class AppConfig {
  // Base URLs
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://www.zena.live';
  static String get apiUrl => '$baseUrl/api';

  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? _throwMissingEnvError('SUPABASE_URL');
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      _throwMissingEnvError('SUPABASE_ANON_KEY');

  // Google OAuth Configuration
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
      _throwMissingEnvError('GOOGLE_WEB_CLIENT_ID');

  // iOS Client ID is optional - only needed for iOS builds
  // Android works without it
  static String? get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'];

  /// Throw error for missing environment variables
  static String _throwMissingEnvError(String key) {
    throw Exception(
      'Missing required environment variable: $key\n'
      'Please ensure .env.local file exists and contains $key',
    );
  }

  // API Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationEndpoint = '/chat/conversation';
  static const String conversationsEndpoint = '/conversations';
  static const String uploadEndpoint = '/upload';

  // OAuth Configuration
  static const String authCallbackUrl = 'zena://auth-callback';

  // App Settings
  static const int requestTimeout = 30; // seconds
  static const int maxFileSize =
      50 * 1024 * 1024; // 50MB (matches Supabase bucket limit)
  static const int maxMemoryUsage = 200 * 1024 * 1024; // 200MB
}
