/// Application configuration
/// Contains API URLs, Supabase credentials, and other app-wide settings
class AppConfig {
  // Base URLs
  static const String baseUrl = 'https://zena.live';
  static const String apiUrl = '$baseUrl/api';

  // Supabase Configuration
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // API Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationEndpoint = '/chat/conversation';
  static const String conversationsEndpoint = '/chat/conversations';
  static const String uploadEndpoint = '/upload';

  // OAuth Configuration
  static const String authCallbackUrl = 'zena://auth-callback';

  // App Settings
  static const int requestTimeout = 30; // seconds
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxMemoryUsage = 200 * 1024 * 1024; // 200MB
}
