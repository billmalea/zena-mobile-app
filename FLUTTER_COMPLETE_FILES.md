# 📁 Zena Flutter - Complete File Implementation

This document contains ALL the code files you need, ready to copy-paste into your Flutter project.

---

## 📋 File Checklist

Copy these files in order:

1. ✅ lib/config/app_config.dart
2. ✅ lib/config/theme.dart
3. ✅ lib/models/message.dart
4. ✅ lib/models/property.dart
5. ✅ lib/models/conversation.dart
6. ✅ lib/services/api_service.dart
7. ✅ lib/services/chat_service.dart
8. ✅ lib/services/auth_service.dart
9. ✅ lib/providers/auth_provider.dart
10. ✅ lib/providers/chat_provider.dart
11. ✅ lib/widgets/chat/message_bubble.dart
12. ✅ lib/widgets/chat/property_card.dart
13. ✅ lib/widgets/chat/message_input.dart
14. ✅ lib/widgets/chat/typing_indicator.dart
15. ✅ lib/screens/auth/welcome_screen.dart
16. ✅ lib/screens/chat/chat_screen.dart
17. ✅ lib/main.dart

---

## 🔧 Configuration Files

### lib/config/app_config.dart
```dart
class AppConfig {
  // IMPORTANT: Update these with your actual values
  static const String baseUrl = 'https://zena.co.ke';
  static const String apiUrl = '$baseUrl/api';
  
  // Get these from your Supabase dashboard
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // API Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationsEndpoint = '/conversations';
  static const String uploadEndpoint = '/upload';
  
  // App Info
  static const String appName = 'Zena';
  static const String appVersion = '1.0.0';
}
```

### lib/config/theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors matching your web app
  static const Color primaryColor = Color(0xFF10B981);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: cardColor,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
}
```

---

## 📦 Model Files

### lib/models/message.dart
```dart
class Message {
  final String id;
  final String role;
  final String content;
  final List<ToolResult>? toolResults;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.role,
    required this.content,
    this.toolResults,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      toolResults: json['metadata']?['toolResults'] != null
          ? (json['metadata']['toolResults'] as List)
              .map((e) => ToolResult.fromJson(e))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  bool get isUser => role == 'user';
  bool get hasToolResults => toolResults != null && toolResults!.isNotEmpty;
}

class ToolResult {
  final String toolName;
  final Map<String, dynamic> result;

  ToolResult({
    required this.toolName,
    required this.result,
  });

  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolName: json['toolName'] ?? '',
      result: json['result'] ?? {},
    );
  }
}
```

### lib/models/property.dart
```dart
class Property {
  final String id;
  final String title;
  final String description;
  final String location;
  final int rentAmount;
  final int commissionAmount;
  final int bedrooms;
  final int bathrooms;
  final String propertyType;
  final List<String> amenities;
  final List<String> images;
  final List<String> videos;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.rentAmount,
    required this.commissionAmount,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyType,
    required this.amenities,
    required this.images,
    required this.videos,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      rentAmount: json['rentAmount'] ?? json['rent_amount'] ?? 0,
      commissionAmount: json['commissionAmount'] ?? json['commission_amount'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      propertyType: json['propertyType'] ?? json['property_type'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
    );
  }

  String get formattedRent {
    return 'KSh ${rentAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String get formattedCommission {
    return 'KSh ${commissionAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}
```

### lib/models/conversation.dart
```dart
import 'message.dart';

class Conversation {
  final String id;
  final String userId;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['conversationId'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages';
    final lastMessage = messages.last.content;
    return lastMessage.length > 50
        ? '${lastMessage.substring(0, 50)}...'
        : lastMessage;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
```


---

## 🌐 Service Files

### lib/services/api_service.dart
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('${AppConfig.apiUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('${AppConfig.apiUrl}$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Stream for SSE responses
  Stream<String> streamPost(String endpoint, Map<String, dynamic> body) async* {
    try {
      final headers = await _getHeaders();
      final request = http.Request(
        'POST',
        Uri.parse('${AppConfig.apiUrl}$endpoint'),
      );
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      final streamedResponse = await _client.send(request);
      
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      print('Stream Error: $e');
      rethrow;
    }
  }
}
```

### lib/services/chat_service.dart
```dart
import 'dart:async';
import 'dart:convert';
import '../models/message.dart';
import '../models/conversation.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class ChatService {
  final ApiService _api = ApiService();

  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
    List<String>? fileUrls,
  }) async* {
    try {
      final body = {
        'messages': [
          {
            'role': 'user',
            'parts': [
              {'type': 'text', 'text': message}
            ]
          }
        ],
        if (conversationId != null) 'conversationId': conversationId,
        if (fileUrls != null && fileUrls.isNotEmpty) 'fileUrls': fileUrls,
      };

      await for (var chunk in _api.streamPost(AppConfig.chatEndpoint, body)) {
        final lines = chunk.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            try {
              final data = jsonDecode(line.substring(6));
              yield ChatEvent.fromJson(data);
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      yield ChatEvent(type: 'error', content: e.toString());
    }
  }

  Future<Conversation> getConversation(String? conversationId) async {
    final endpoint = conversationId != null
        ? '${AppConfig.chatEndpoint}/conversation?conversationId=$conversationId'
        : '${AppConfig.chatEndpoint}/conversation';
    
    final data = await _api.get(endpoint);
    return Conversation.fromJson(data);
  }

  Future<List<Conversation>> getConversations() async {
    final data = await _api.get(AppConfig.conversationsEndpoint);
    return (data as List).map((e) => Conversation.fromJson(e)).toList();
  }

  Future<Conversation> createConversation() async {
    final data = await _api.post('${AppConfig.chatEndpoint}/conversation', {});
    return Conversation.fromJson(data);
  }
}

class ChatEvent {
  final String type;
  final String? content;
  final Map<String, dynamic>? toolResult;

  ChatEvent({
    required this.type,
    this.content,
    this.toolResult,
  });

  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    return ChatEvent(
      type: json['type'] ?? 'text',
      content: json['content'],
      toolResult: json['toolResult'],
    );
  }
}
```

### lib/services/auth_service.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<String?> getAccessToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      Provider.google,
      redirectTo: 'zena://auth-callback',
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
```

---

## 🔄 Provider Files

### lib/providers/auth_provider.dart
```dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  void _init() {
    _user = _authService.currentUser;
    _isLoading = false;
    notifyListeners();

    _authService.authStateChanges.listen((event) {
      _user = event.session?.user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
```

### lib/providers/chat_provider.dart
```dart
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  String? get conversationId => _conversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversation(String conversationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final conversation = await _chatService.getConversation(conversationId);
      _conversationId = conversation.id;
      _messages = conversation.messages;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startNewConversation() async {
    _messages = [];
    _conversationId = null;
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text, List<String>? fileUrls) async {
    if (text.trim().isEmpty && (fileUrls == null || fileUrls.isEmpty)) {
      return;
    }

    try {
      final userMessage = Message(
        id: const Uuid().v4(),
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      );
      _messages.add(userMessage);
      _isLoading = true;
      _error = null;
      notifyListeners();

      final assistantMessageId = const Uuid().v4();
      final assistantMessage = Message(
        id: assistantMessageId,
        role: 'assistant',
        content: '',
        toolResults: [],
        createdAt: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();

      await for (var event in _chatService.sendMessage(
        message: text,
        conversationId: _conversationId,
        fileUrls: fileUrls,
      )) {
        if (event.type == 'text') {
          final index = _messages.indexWhere((m) => m.id == assistantMessageId);
          if (index != -1) {
            _messages[index] = Message(
              id: assistantMessageId,
              role: 'assistant',
              content: _messages[index].content + (event.content ?? ''),
              toolResults: _messages[index].toolResults,
              createdAt: _messages[index].createdAt,
            );
            notifyListeners();
          }
        } else if (event.type == 'tool' && event.toolResult != null) {
          final index = _messages.indexWhere((m) => m.id == assistantMessageId);
          if (index != -1) {
            final currentToolResults = _messages[index].toolResults ?? [];
            _messages[index] = Message(
              id: assistantMessageId,
              role: 'assistant',
              content: _messages[index].content,
              toolResults: [
                ...currentToolResults,
                ToolResult(
                  toolName: event.toolResult!['toolName'],
                  result: event.toolResult!['result'],
                ),
              ],
              createdAt: _messages[index].createdAt,
            );
            notifyListeners();
          }
        } else if (event.type == 'error') {
          _error = event.content;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

This document continues in the next section with all the widget and screen files...
