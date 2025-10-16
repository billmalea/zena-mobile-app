# 📱 Zena Flutter Mobile App - Implementation Guide

## 🎯 Overview

This is a **simplified Flutter mobile app** that connects to your **existing Zena backend**. The app focuses on the chat interface as the main interaction point, just like your web app.

**Key Points:**
- ✅ Use existing backend (no changes needed)
- ✅ Chat-first interface (main interaction)
- ✅ Connect to `/api/chat` endpoint
- ✅ Handle AI streaming responses
- ✅ Render tool results (properties, payments, etc.)
- ✅ Simple, clean UI matching web design

---

## 🚀 Quick Start

```bash
# Navigate to zena-mobile folder
cd zena-mobile

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

---

## 📦 Dependencies (pubspec.yaml)

```yaml
name: zena_mobile
description: Zena rental platform mobile app
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # UI & Design
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & API
  http: ^1.1.2
  dio: ^5.4.0
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Image Handling
  image_picker: ^1.0.5
  file_picker: ^6.1.1
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.2
  url_launcher: ^6.2.2
  
  # UI Components
  flutter_markdown: ^0.6.18
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 🏗️ Project Structure

```
zena-mobile/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── app_config.dart          # API URLs, constants
│   │   └── theme.dart                # App theme (colors, text styles)
│   ├── models/
│   │   ├── message.dart              # Chat message model
│   │   ├── property.dart             # Property model
│   │   ├── conversation.dart         # Conversation model
│   │   └── user.dart                 # User model
│   ├── services/
│   │   ├── api_service.dart          # HTTP client wrapper
│   │   ├── chat_service.dart         # Chat API calls
│   │   ├── auth_service.dart         # Supabase auth
│   │   └── storage_service.dart      # Local storage
│   ├── providers/
│   │   ├── auth_provider.dart        # Auth state
│   │   ├── chat_provider.dart        # Chat state
│   │   └── theme_provider.dart       # Theme state
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart
│   │   │   └── phone_auth_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_screen.dart      # Main chat interface
│   │   │   └── conversations_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── widgets/
│   │   ├── chat/
│   │   │   ├── message_bubble.dart
│   │   │   ├── property_card.dart
│   │   │   ├── payment_card.dart
│   │   │   ├── typing_indicator.dart
│   │   │   └── message_input.dart
│   │   └── common/
│   │       ├── custom_button.dart
│   │       └── loading_indicator.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml
└── README.md
```

---

## 🔧 Core Configuration

### config/app_config.dart
```dart
class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://zena.live'; // Your production URL
  static const String apiUrl = '$baseUrl/api';
  
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // API Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationsEndpoint = '/conversations';
  static const String uploadEndpoint = '/upload';
  
  // App Configuration
  static const String appName = 'Zena';
  static const String appVersion = '1.0.0';
}
```

### config/theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors matching web app
  static const Color primaryColor = Color(0xFF10B981); // Emerald
  static const Color secondaryColor = Color(0xFF14B8A6); // Teal
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  
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
      ),
    ),
  );
}
```

---

## 📡 API Service Implementation

### services/api_service.dart
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
        throw Exception('API Error: ${response.statusCode}');
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

  // Stream for chat responses
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


### services/chat_service.dart
```dart
import 'dart:async';
import 'dart:convert';
import '../models/message.dart';
import '../models/conversation.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class ChatService {
  final ApiService _api = ApiService();

  // Send message and stream AI response
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
        // Parse SSE format
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

  // Get conversation history
  Future<Conversation> getConversation(String? conversationId) async {
    final endpoint = conversationId != null
        ? '${AppConfig.chatEndpoint}/conversation?conversationId=$conversationId'
        : '${AppConfig.chatEndpoint}/conversation';
    
    final data = await _api.get(endpoint);
    return Conversation.fromJson(data);
  }

  // Get all conversations
  Future<List<Conversation>> getConversations() async {
    final data = await _api.get(AppConfig.conversationsEndpoint);
    return (data as List).map((e) => Conversation.fromJson(e)).toList();
  }

  // Create new conversation
  Future<Conversation> createConversation() async {
    final data = await _api.post('${AppConfig.chatEndpoint}/conversation', {});
    return Conversation.fromJson(data);
  }
}

// Chat event model for streaming
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


### services/auth_service.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

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

  // Google Sign In - Primary authentication method
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      Provider.google,
      redirectTo: 'zena://auth-callback',
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
```

---

## 📱 Models

### models/message.dart
```dart
class Message {
  final String id;
  final String role; // 'user' or 'assistant'
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
      id: json['id'],
      role: json['role'],
      content: json['content'] ?? '',
      toolResults: json['metadata']?['toolResults'] != null
          ? (json['metadata']['toolResults'] as List)
              .map((e) => ToolResult.fromJson(e))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
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
      toolName: json['toolName'],
      result: json['result'],
    );
  }
}
```

### models/property.dart
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      rentAmount: json['rentAmount'] ?? json['rent_amount'],
      commissionAmount: json['commissionAmount'] ?? json['commission_amount'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      propertyType: json['propertyType'] ?? json['property_type'],
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
    );
  }

  String get formattedRent => 'KSh ${rentAmount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';
}
```

### models/conversation.dart
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
      id: json['conversationId'] ?? json['id'],
      userId: json['userId'] ?? json['user_id'],
      messages: (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages';
    return messages.last.content.length > 50
        ? '${messages.last.content.substring(0, 50)}...'
        : messages.last.content;
  }
}
```


---

## 🎨 Main Chat Screen

### screens/chat/chat_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/property_card.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({Key? key, this.conversationId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (widget.conversationId != null) {
        chatProvider.loadConversation(widget.conversationId!);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zena Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<ChatProvider>().startNewConversation();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Scroll to bottom when messages change
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              // Messages List
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          
                          if (message.isUser) {
                            return MessageBubble(message: message);
                          } else {
                            // Assistant message with potential tool results
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Render tool results
                                if (message.hasToolResults)
                                  ...message.toolResults!.map((tool) {
                                    if (tool.toolName == 'searchProperties') {
                                      return _buildPropertyResults(tool.result);
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                // Render text message
                                if (message.content.isNotEmpty)
                                  MessageBubble(message: message),
                              ],
                            );
                          }
                        },
                      ),
              ),

              // Typing Indicator
              if (chatProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: TypingIndicator(),
                ),

              // Message Input
              MessageInput(
                onSend: (text, files) {
                  chatProvider.sendMessage(text, files);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about rental properties in Kenya',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyResults(Map<String, dynamic> result) {
    final properties = result['properties'] as List?;
    if (properties == null || properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Found ${properties.length} properties',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        ...properties.map((prop) => PropertyCard(property: prop)),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```


---

## 🔄 Chat Provider (State Management)

### providers/chat_provider.dart
```dart
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/conversation.dart';
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

  // Load existing conversation
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

  // Start new conversation
  Future<void> startNewConversation() async {
    _messages = [];
    _conversationId = null;
    _error = null;
    notifyListeners();
  }

  // Send message and stream response
  Future<void> sendMessage(String text, List<String>? fileUrls) async {
    if (text.trim().isEmpty && (fileUrls == null || fileUrls.isEmpty)) {
      return;
    }

    try {
      // Add user message immediately
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

      // Create assistant message placeholder
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

      // Stream AI response
      await for (var event in _chatService.sendMessage(
        message: text,
        conversationId: _conversationId,
        fileUrls: fileUrls,
      )) {
        if (event.type == 'text') {
          // Update assistant message content
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
          // Add tool result
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

---

## 🎨 UI Widgets

### widgets/chat/message_bubble.dart
```dart
import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../config/theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
```

### widgets/chat/property_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../config/theme.dart';

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prop = Property.fromJson(property);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to property details or request contact
          _showContactDialog(context, prop);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: prop.images.isNotEmpty 
                    ? prop.images.first 
                    : 'https://via.placeholder.com/400x200',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prop.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          prop.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeature(Icons.bed, '${prop.bedrooms} Bed'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.bathtub, '${prop.bathrooms} Bath'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.home, prop.propertyType),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prop.formattedRent,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showContactDialog(context, prop),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Contact'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Contact Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property: ${property.title}'),
            const SizedBox(height: 8),
            Text('Commission: KSh ${property.commissionAmount}'),
            const SizedBox(height: 16),
            const Text(
              'To get the owner\'s contact information, you need to pay the commission fee via M-Pesa.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Send message to request contact
              // This will trigger the requestContactInfo tool
            },
            child: const Text('Pay & Get Contact'),
          ),
        ],
      ),
    );
  }
}
```


### widgets/chat/message_input.dart
```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String text, List<String>? fileUrls) onSend;

  const MessageInput({Key? key, required this.onSend}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];

  void _handleSend() {
    if (_controller.text.trim().isEmpty && _selectedFiles.isEmpty) return;

    widget.onSend(_controller.text, null); // File upload to be implemented
    _controller.clear();
    _selectedFiles.clear();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final images = await _picker.pickMultiImage();
    setState(() {
      _selectedFiles.addAll(images);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickImage,
              color: AppTheme.textSecondary,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### widgets/chat/typing_indicator.dart
```dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value - (index * 0.2)) % 1.0;
        final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 🚀 Main App Entry

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ZenaApp());
}

class ZenaApp extends StatelessWidget {
  const ZenaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Zena',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const ChatScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
```

---

## ✅ Implementation Checklist

### Phase 1: Setup (Day 1)
- [ ] Create Flutter project
- [ ] Add dependencies to pubspec.yaml
- [ ] Configure Supabase
- [ ] Set up app config with API URLs
- [ ] Create theme configuration

### Phase 2: Core Services (Day 2)
- [ ] Implement ApiService
- [ ] Implement ChatService with streaming
- [ ] Implement AuthService
- [ ] Create data models (Message, Property, Conversation)

### Phase 3: State Management (Day 3)
- [ ] Create ChatProvider
- [ ] Create AuthProvider
- [ ] Test state management

### Phase 4: UI Components (Day 4-5)
- [ ] Build MessageBubble widget
- [ ] Build PropertyCard widget
- [ ] Build MessageInput widget
- [ ] Build TypingIndicator widget
- [ ] Build ChatScreen

### Phase 5: Authentication (Day 6)
- [ ] Build WelcomeScreen
- [ ] Implement Google Sign In
- [ ] Configure OAuth redirect
- [ ] Test authentication flow

### Phase 6: Testing & Polish (Day 7)
- [ ] Test chat streaming
- [ ] Test property display
- [ ] Test error handling
- [ ] UI polish and refinements
- [ ] Performance optimization

---

## 🔍 Key Integration Points

### 1. Chat API Streaming
Your backend streams responses via Server-Sent Events (SSE). The Flutter app needs to:
- Parse `data: ` prefixed lines
- Handle JSON chunks
- Update UI in real-time

### 2. Tool Results Rendering
When AI calls tools (searchProperties, requestContactInfo, etc.), results come in the stream:
```dart
{
  "type": "tool",
  "toolResult": {
    "toolName": "searchProperties",
    "result": {
      "properties": [...]
    }
  }
}
```

### 3. Authentication
Use Supabase client for auth, which provides JWT tokens automatically for API calls.

### 4. File Upload
For property submissions with images/videos:
1. Pick files using image_picker
2. Upload to `/api/upload`
3. Get URLs back
4. Include URLs in chat message

---

## 🎯 Next Steps

1. **Copy this file to zena-mobile folder**
2. **Run `flutter pub get`**
3. **Update AppConfig with your URLs**
4. **Start with main.dart and services**
5. **Build UI components**
6. **Test with your backend**

The beauty of this approach is that your backend is already complete - you just need to build the Flutter UI and connect it! 🚀


---

## 🎨 Welcome Screen (Google Auth Only)

### screens/auth/welcome_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // App Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.home,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'Zena',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'AI-Powered Rental Search for Kenya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Google Sign In Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign in failed: $e')),
                    );
                  }
                },
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Terms & Privacy
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📝 Additional Notes

### Google Sign In Setup

#### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<activity
    android:name="com.supabase.gotrue.GoTrueActivity"
    android:exported="true"
    android:launchMode="singleTask">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="zena" android:host="auth-callback" />
    </intent-filter>
</activity>
```

#### iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>zena</string>
        </array>
    </dict>
</array>
```

### Supabase Dashboard Setup
1. Go to Authentication > Providers
2. Enable Google provider
3. Add your OAuth credentials
4. Add redirect URL: `zena://auth-callback`

---

## 🎯 Summary

Your Flutter app is now configured with:
- ✅ **Google Sign In only** (simplified auth)
- ✅ **Chat-first interface** (main interaction)
- ✅ **Streaming AI responses** (real-time updates)
- ✅ **Property cards** (auto-rendered from tools)
- ✅ **Clean architecture** (Provider pattern)
- ✅ **Existing backend** (no changes needed)

The app connects directly to your production backend at `https://zena.co.ke/api` and uses Supabase for authentication. All AI logic, tool calling, and business rules stay on your backend! 🚀
