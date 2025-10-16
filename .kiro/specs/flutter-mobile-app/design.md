# Design Document - Zena Flutter Mobile App

## Overview

The Zena Flutter Mobile App is a cross-platform mobile application that provides a native mobile experience for the Zena rental platform. The app uses a clean architecture with clear separation of concerns, connecting to the existing backend API without requiring any backend modifications.

**Architecture Philosophy:** Mobile UI layer + Existing Backend = Complete Solution

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (Screens + Widgets + Theme)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    State Management Layer           │
│      (Provider Pattern)             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Service Layer                 │
│  (API + Chat + Auth Services)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Data Layer                   │
│  (Models + Supabase + Cache)        │
└──────────────┬──────────────────────┘
               │
               │ HTTPS/WebSocket
               ▼
┌─────────────────────────────────────┐
│    Existing Zena Backend            │
│  (Next.js + Supabase + Gemini AI)   │
└─────────────────────────────────────┘
```

### Layer Responsibilities

**Presentation Layer:**
- Renders UI components
- Handles user interactions
- Displays data from providers
- No business logic

**State Management Layer:**
- Manages application state
- Notifies UI of changes
- Coordinates between services and UI
- Handles loading and error states

**Service Layer:**
- Makes API calls
- Handles authentication
- Parses responses
- Manages streaming connections

**Data Layer:**
- Defines data models
- Handles data transformation
- Manages local caching
- Interfaces with Supabase

---

## Components and Interfaces

### 1. Configuration Layer

#### AppConfig
```dart
class AppConfig {
  static const String baseUrl = 'https://zena.live';
  static const String apiUrl = '$baseUrl/api';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
  
  // Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationsEndpoint = '/conversations';
  static const String uploadEndpoint = '/upload';
}
```

#### AppTheme
```dart
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF10B981);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  
  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(...),
    textTheme: GoogleFonts.interTextTheme(),
    // ... additional theme configuration
  );
}
```

---

### 2. Data Models

#### Message Model
```dart
class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ToolResult>? toolResults;
  final DateTime createdAt;
  
  bool get isUser => role == 'user';
  bool get hasToolResults => toolResults != null && toolResults!.isNotEmpty;
}

class ToolResult {
  final String toolName;
  final Map<String, dynamic> result;
}
```

#### Property Model
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
  
  String get formattedRent; // KSh 80,000
  String get formattedCommission; // KSh 5,000
}
```

#### Conversation Model
```dart
class Conversation {
  final String id;
  final String userId;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  String get lastMessagePreview;
  String get timeAgo;
}
```

---

### 3. Service Layer

#### ApiService
**Responsibility:** HTTP client wrapper with authentication

```dart
class ApiService {
  Future<Map<String, String>> _getHeaders();
  Future<dynamic> post(String endpoint, Map<String, dynamic> body);
  Future<dynamic> get(String endpoint);
  Stream<String> streamPost(String endpoint, Map<String, dynamic> body);
}
```

**Key Features:**
- Singleton pattern
- Automatic auth header injection
- SSE streaming support
- Error handling

#### ChatService
**Responsibility:** Chat-specific API operations

```dart
class ChatService {
  Stream<ChatEvent> sendMessage({
    required String message,
    String? conversationId,
    List<String>? fileUrls,
  });
  
  Future<Conversation> getConversation(String? conversationId);
  Future<List<Conversation>> getConversations();
  Future<Conversation> createConversation();
}

class ChatEvent {
  final String type; // 'text', 'tool', 'error'
  final String? content;
  final Map<String, dynamic>? toolResult;
}
```

**Key Features:**
- SSE parsing
- Event streaming
- Conversation management

#### AuthService
**Responsibility:** Authentication operations

```dart
class AuthService {
  User? get currentUser;
  bool get isAuthenticated;
  
  Future<String?> getAccessToken();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  
  Stream<AuthState> get authStateChanges;
}
```

**Key Features:**
- Supabase integration
- Google OAuth
- Session management
- State change notifications

---

### 4. State Management Layer

#### ChatProvider
**Responsibility:** Manage chat state

```dart
class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadConversation(String conversationId);
  Future<void> startNewConversation();
  Future<void> sendMessage(String text, List<String>? fileUrls);
  void clearError();
}
```

**State Flow:**
1. User action triggers method
2. Method updates state
3. notifyListeners() called
4. UI rebuilds automatically

#### AuthProvider
**Responsibility:** Manage authentication state

```dart
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  
  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  
  // Methods
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
```

---

### 5. Presentation Layer

#### Screen Structure

**WelcomeScreen:**
- Purpose: Authentication entry point
- Components: Logo, Title, Google Sign In button
- Navigation: → ChatScreen (on auth success)

**ChatScreen:**
- Purpose: Main interaction interface
- Components: AppBar, MessageList, MessageInput, TypingIndicator
- State: Consumes ChatProvider
- Features: Scrolling, streaming, tool result rendering

#### Widget Components

**MessageBubble:**
```dart
class MessageBubble extends StatelessWidget {
  final Message message;
  
  // Renders user/assistant message with appropriate styling
  // User: right-aligned, emerald background
  // Assistant: left-aligned, white background
}
```

**PropertyCard:**
```dart
class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  
  // Renders property information:
  // - Image (cached)
  // - Title, location
  // - Bedrooms, bathrooms, type
  // - Rent amount (formatted)
  // - Contact button
}
```

**MessageInput:**
```dart
class MessageInput extends StatefulWidget {
  final Function(String text, List<String>? fileUrls) onSend;
  
  // Components:
  // - TextField (multi-line)
  // - Attach button
  // - Send button
  // - File preview
}
```

**TypingIndicator:**
```dart
class TypingIndicator extends StatefulWidget {
  // Animated dots showing AI is typing
  // Uses AnimationController for smooth animation
}
```

---

## Data Models

### Message Flow

```
User Input
    ↓
ChatProvider.sendMessage()
    ↓
Add user message to _messages
    ↓
notifyListeners() → UI updates
    ↓
ChatService.sendMessage()
    ↓
POST /api/chat
    ↓
Stream<ChatEvent>
    ↓
Parse SSE chunks
    ↓
Yield ChatEvent(type: 'text', content: '...')
    ↓
ChatProvider receives event
    ↓
Update assistant message
    ↓
notifyListeners() → UI updates
    ↓
Repeat until stream ends
```

### Authentication Flow

```
User taps Google Sign In
    ↓
AuthProvider.signInWithGoogle()
    ↓
AuthService.signInWithOAuth()
    ↓
Supabase redirects to Google
    ↓
User authenticates
    ↓
OAuth callback: zena://auth-callback
    ↓
Supabase exchanges code for token
    ↓
AuthService.authStateChanges emits
    ↓
AuthProvider updates _user
    ↓
notifyListeners() → UI updates
    ↓
AuthWrapper navigates to ChatScreen
```

---

## Error Handling

### Error Categories

**Network Errors:**
- Connection timeout
- No internet
- Server unreachable
- Response: Show error message, provide retry button

**Authentication Errors:**
- OAuth failure
- Session expired
- Invalid token
- Response: Show error, redirect to login

**API Errors:**
- 400 Bad Request
- 401 Unauthorized
- 500 Server Error
- Response: Show user-friendly message, log for debugging

**Streaming Errors:**
- Connection lost mid-stream
- Invalid SSE format
- Timeout
- Response: Show partial content, error message, retry option

### Error Handling Strategy

```dart
try {
  // Operation
} catch (e) {
  if (e is NetworkException) {
    _error = 'Cannot connect to server';
  } else if (e is AuthException) {
    _error = 'Authentication failed';
    // Trigger re-auth
  } else {
    _error = 'An error occurred';
  }
  notifyListeners();
}
```

---

## Testing Strategy

### Unit Tests
- Test models (Message, Property, Conversation)
- Test service methods (mocked HTTP)
- Test provider state changes
- Test utility functions

### Widget Tests
- Test MessageBubble rendering
- Test PropertyCard rendering
- Test MessageInput behavior
- Test TypingIndicator animation

### Integration Tests
- Test authentication flow
- Test chat message flow
- Test property display flow
- Test error handling

### Manual Testing
- Test on real Android device
- Test on real iOS device
- Test various network conditions
- Test different screen sizes
- Test with production backend

---

## Performance Considerations

### Optimization Strategies

**Image Loading:**
- Use cached_network_image for caching
- Load thumbnails first, full images on demand
- Lazy load images in lists

**List Performance:**
- Use ListView.builder for virtualization
- Implement pagination for long conversations
- Optimize rebuild scope with Consumer

**Network:**
- Implement request debouncing
- Cache API responses
- Use connection pooling
- Set appropriate timeouts

**Memory:**
- Dispose controllers and streams
- Clear large data when not needed
- Monitor memory usage in profiler

**Build Size:**
- Remove unused dependencies
- Enable code shrinking
- Use ProGuard/R8 for Android

---

## Security Considerations

### Data Protection
- Store tokens securely (Supabase handles this)
- Never log sensitive data in production
- Validate all user inputs
- Sanitize data before display

### Network Security
- Use HTTPS only
- Validate SSL certificates
- Implement certificate pinning (optional)
- Handle token refresh securely

### Authentication Security
- Use OAuth 2.0 best practices
- Implement proper session management
- Handle token expiration
- Secure deep link handling

---

## Deployment Strategy

### Build Configuration

**Android:**
```gradle
android {
    defaultConfig {
        applicationId "com.zena.mobile"
        minSdkVersion 23
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

**iOS:**
```xml
<key>CFBundleIdentifier</key>
<string>com.zena.mobile</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### Release Process

1. Update version numbers
2. Build release artifacts
3. Test release builds
4. Sign applications
5. Submit to stores
6. Monitor crash reports
7. Respond to user feedback

---

## Monitoring and Analytics

### Metrics to Track
- App crashes
- API response times
- Authentication success rate
- Message send success rate
- Property card render time
- User engagement metrics

### Tools
- Firebase Crashlytics (crash reporting)
- Firebase Analytics (user analytics)
- Sentry (error tracking)
- Custom logging (development)

---

## Future Enhancements

### Phase 2 Features
- Push notifications
- Offline mode with local database
- Property map view
- Advanced filters UI
- User profile screen
- Settings screen
- Dark mode support

### Phase 3 Features
- In-app payments
- Property comparison
- Saved searches
- Property alerts
- Multi-language support
- Tablet layouts

---

## Technical Decisions

### Why Flutter?
- Cross-platform (iOS + Android)
- Fast development
- Hot reload
- Native performance
- Large ecosystem

### Why Provider?
- Simple and lightweight
- Official Flutter recommendation
- Easy to understand
- Sufficient for app complexity
- Good performance

### Why Supabase?
- Already used in backend
- Easy authentication
- Real-time capabilities
- Good Flutter support

### Why Google Sign In Only?
- Simplifies authentication
- Most users have Google accounts
- Reduces complexity
- Faster implementation

---

## Dependencies Justification

**provider:** State management - lightweight and official
**http:** API calls - standard HTTP client
**supabase_flutter:** Authentication - backend integration
**google_fonts:** Typography - matches web design
**cached_network_image:** Image caching - performance
**image_picker:** File selection - native integration
**uuid:** Unique IDs - message identification
**intl:** Formatting - currency and dates
**shared_preferences:** Local storage - simple key-value

---

## Conclusion

This design provides a clean, maintainable architecture that connects seamlessly to the existing Zena backend. The separation of concerns ensures testability, the Provider pattern keeps state management simple, and the service layer abstracts API complexity.

The app connects to the production backend at https://zena.live and is designed to be implemented in 3-5 hours by following the provided code examples. It can be extended with additional features in future phases.

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Status:** Ready for Implementation
