# 📐 Zena Flutter Mobile - Architecture Diagrams

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  ZENA FLUTTER MOBILE APP                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Presentation Layer                       │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Screens    │  │   Widgets    │  │    Theme     │    │ │
│  │  │              │  │              │  │              │    │ │
│  │  │ - Chat       │  │ - Message    │  │ - Colors     │    │ │
│  │  │ - Auth       │  │ - Property   │  │ - Styles     │    │ │
│  │  │ - Profile    │  │ - Input      │  │ - Spacing    │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  State Management Layer                     │ │
│  │                      (Provider)                             │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐                       │ │
│  │  │ ChatProvider │  │ AuthProvider │                       │ │
│  │  │              │  │              │                       │ │
│  │  │ - Messages   │  │ - User       │                       │ │
│  │  │ - Loading    │  │ - Session    │                       │ │
│  │  │ - Error      │  │ - Auth State │                       │ │
│  │  └──────────────┘  └──────────────┘                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Service Layer                            │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │ ChatService  │  │ AuthService  │  │ ApiService   │    │ │
│  │  │              │  │              │  │              │    │ │
│  │  │ - Send Msg   │  │ - Google     │  │ - HTTP       │    │ │
│  │  │ - Stream     │  │   Sign In    │  │ - Headers    │    │ │
│  │  │ - History    │  │ - Sign Out   │  │ - Streaming  │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     Data Layer                              │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Models     │  │   Supabase   │  │    Cache     │    │ │
│  │  │              │  │    Client    │  │              │    │ │
│  │  │ - Message    │  │              │  │ - Shared     │    │ │
│  │  │ - Property   │  │ - Auth       │  │   Prefs      │    │ │
│  │  │ - User       │  │ - Session    │  │              │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           │ HTTPS / WebSocket
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXISTING ZENA BACKEND                         │
│                   (Next.js + Supabase)                           │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   /api/chat  │  │   Supabase   │  │   Google     │         │
│  │              │  │              │  │   Gemini AI  │         │
│  │ - Streaming  │  │ - Auth       │  │              │         │
│  │ - Tools      │  │ - Database   │  │ - Tools      │         │
│  │ - AI         │  │ - Storage    │  │ - Streaming  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER INTERACTION                            │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Screen     │
                    │  (UI Layer)  │
                    └──────┬───────┘
                           │
                           │ User Action
                           ▼
                    ┌──────────────┐
                    │   Provider   │
                    │ (State Mgmt) │
                    └──────┬───────┘
                           │
                           │ Business Logic
                           ▼
                    ┌──────────────┐
                    │   Service    │
                    │ (API Calls)  │
                    └──────┬───────┘
                           │
                           │ HTTP/WebSocket
                           ▼
                    ┌──────────────┐
                    │   Backend    │
                    │   API        │
                    └──────┬───────┘
                           │
                           │ Response/Stream
                           ▼
                    ┌──────────────┐
                    │   Service    │
                    │ (Parse Data) │
                    └──────┬───────┘
                           │
                           │ Update State
                           ▼
                    ┌──────────────┐
                    │   Provider   │
                    │ (Notify)     │
                    └──────┬───────┘
                           │
                           │ Rebuild UI
                           ▼
                    ┌──────────────┐
                    │   Screen     │
                    │ (Updated UI) │
                    └──────────────┘
```

---

## 💬 Chat Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CHAT FLOW                                 │
└─────────────────────────────────────────────────────────────────┘

USER TYPES MESSAGE
       │
       ▼
┌──────────────────┐
│  MessageInput    │
│  Widget          │
│  - TextField     │
│  - Send Button   │
└────────┬─────────┘
         │ onSend()
         ▼
┌──────────────────┐
│  ChatProvider    │
│  - Add user msg  │
│  - Set loading   │
└────────┬─────────┘
         │ sendMessage()
         ▼
┌──────────────────┐
│  ChatService     │
│  - Format body   │
│  - Call API      │
└────────┬─────────┘
         │ POST /api/chat
         ▼
┌──────────────────────────────┐
│  Backend API                 │
│  - Parse message             │
│  - Call Gemini AI            │
│  - Execute tools             │
│  - Stream response           │
└────────┬─────────────────────┘
         │ SSE Stream
         │
         ├─► data: {"type":"text","content":"..."}
         │
         ├─► data: {"type":"tool","toolResult":{...}}
         │
         └─► [stream ends]
         │
         ▼
┌──────────────────┐
│  ChatService     │
│  - Parse SSE     │
│  - Yield events  │
└────────┬─────────┘
         │ Stream<ChatEvent>
         ▼
┌──────────────────┐
│  ChatProvider    │
│  - Update msg    │
│  - Add tools     │
│  - Notify UI     │
└────────┬─────────┘
         │ notifyListeners()
         ▼
┌──────────────────┐
│  ChatScreen      │
│  - Rebuild       │
│  - Show message  │
│  - Render tools  │
└──────────────────┘
```

---

## 🔐 Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   GOOGLE AUTHENTICATION FLOW                     │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  WelcomeScreen   │
│                  │
│  [Google Button] │
└────────┬─────────┘
         │ User taps
         ▼
┌──────────────────┐
│  AuthProvider    │
│  signInWithGoogle│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  AuthService     │
│  signInWithOAuth │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────┐
│  Supabase Auth               │
│  - Generate OAuth URL        │
│  - Redirect to Google        │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Google OAuth Screen         │
│  - User selects account      │
│  - Grants permissions        │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  OAuth Callback              │
│  zena://auth-callback        │
│  - Receives auth code        │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Supabase Auth               │
│  - Exchange code for token   │
│  - Create session            │
│  - Store JWT                 │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────┐
│  AuthService     │
│  - onAuthStateChange
│  - Emit new state│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  AuthProvider    │
│  - Update user   │
│  - Notify UI     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  AuthWrapper     │
│  - Check auth    │
│  - Navigate      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  ChatScreen      │
│  (Authenticated) │
└──────────────────┘
```

---

## 🏠 Property Display Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROPERTY DISPLAY FLOW                         │
└─────────────────────────────────────────────────────────────────┘

USER: "Show me 2BR in Kilimani"
       │
       ▼
┌──────────────────────────────┐
│  Backend AI                  │
│  - Understand query          │
│  - Call searchProperties     │
│  - Return results            │
└────────┬─────────────────────┘
         │ Stream response
         ▼
data: {
  "type": "tool",
  "toolResult": {
    "toolName": "searchProperties",
    "result": {
      "properties": [
        {
          "id": "123",
          "title": "Modern 2BR",
          "location": "Kilimani",
          "rentAmount": 80000,
          "bedrooms": 2,
          "images": ["url1", "url2"]
        }
      ]
    }
  }
}
         │
         ▼
┌──────────────────┐
│  ChatProvider    │
│  - Parse tool    │
│  - Add to msg    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  ChatScreen      │
│  - Check tool    │
│  - Render card   │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────┐
│  PropertyCard Widget         │
│                              │
│  ┌────────────────────────┐ │
│  │  [Property Image]      │ │
│  ├────────────────────────┤ │
│  │  Modern 2BR Apartment  │ │
│  │  📍 Kilimani, Nairobi  │ │
│  │  🛏️ 2 Bed  🚿 2 Bath   │ │
│  │  💰 KSh 80,000/month   │ │
│  │  [Contact Button]      │ │
│  └────────────────────────┘ │
└──────────────────────────────┘
```

---

## 📱 Screen Navigation Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                      APP NAVIGATION                              │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────┐
                    │   App Start  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ AuthWrapper  │
                    │ (Check Auth) │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
        Not Authenticated         Authenticated
              │                         │
              ▼                         ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ WelcomeScreen    │      │  ChatScreen      │
    │                  │      │  (Main Screen)   │
    │ [Google Sign In] │      │                  │
    └──────────────────┘      └────────┬─────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
          ┌──────────────┐   ┌──────────────┐  ┌──────────────┐
          │ New Chat     │   │ View History │  │ Profile      │
          │ (Action)     │   │ (Action)     │  │ (Action)     │
          └──────────────┘   └──────────────┘  └──────────────┘
```

---

## 🎨 Widget Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                      WIDGET TREE                                 │
└─────────────────────────────────────────────────────────────────┘

MaterialApp
└── MultiProvider
    ├── AuthProvider
    └── ChatProvider
        └── AuthWrapper
            ├── WelcomeScreen (if not authenticated)
            │   ├── AppBar
            │   ├── Logo
            │   ├── Title
            │   └── GoogleSignInButton
            │
            └── ChatScreen (if authenticated)
                ├── AppBar
                │   ├── Title
                │   └── NewChatButton
                │
                ├── Column
                │   ├── Expanded
                │   │   └── ListView.builder
                │   │       └── For each message:
                │   │           ├── MessageBubble (if text)
                │   │           └── PropertyCard (if tool result)
                │   │
                │   ├── TypingIndicator (if loading)
                │   │
                │   └── MessageInput
                │       ├── Row
                │       │   ├── AttachButton
                │       │   ├── TextField
                │       │   └── SendButton
                │       └── FilePreview (if files selected)
```

---

## 🔌 API Integration Points

```
┌─────────────────────────────────────────────────────────────────┐
│                    API ENDPOINTS USED                            │
└─────────────────────────────────────────────────────────────────┘

Flutter App                          Backend API
─────────────                        ───────────

POST /api/chat              ────►    Chat endpoint
  Body: {                             - Receives message
    messages: [...],                  - Calls Gemini AI
    conversationId: "..."             - Executes tools
  }                                   - Streams response
                             ◄────    SSE Stream


GET /api/chat/conversation  ────►    Get conversation
  ?conversationId=xxx                 - Returns messages
                             ◄────    JSON Response


POST /api/chat/conversation ────►    Create conversation
  Body: {}                            - Creates new conv
                             ◄────    JSON Response


GET /api/conversations      ────►    List conversations
                             ◄────    JSON Array


POST /api/upload            ────►    Upload files
  Body: FormData                      - Stores in Supabase
                             ◄────    JSON with URLs


Supabase Auth               ────►    Authentication
  - signInWithOAuth                   - Google OAuth
  - signOut                           - Session management
  - onAuthStateChange                 - JWT tokens
```

---

## 📊 State Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   PROVIDER PATTERN                               │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  ChatProvider (ChangeNotifier)                               │
│                                                              │
│  State:                                                      │
│  ├── List<Message> _messages                                │
│  ├── String? _conversationId                                │
│  ├── bool _isLoading                                        │
│  └── String? _error                                         │
│                                                              │
│  Methods:                                                    │
│  ├── sendMessage(text, files)                               │
│  │   ├── Add user message                                   │
│  │   ├── notifyListeners() ──► UI rebuilds                  │
│  │   ├── Call ChatService                                   │
│  │   ├── Stream responses                                   │
│  │   ├── Update assistant message                           │
│  │   └── notifyListeners() ──► UI rebuilds                  │
│  │                                                           │
│  ├── loadConversation(id)                                   │
│  │   ├── Call ChatService                                   │
│  │   ├── Set messages                                       │
│  │   └── notifyListeners() ──► UI rebuilds                  │
│  │                                                           │
│  └── startNewConversation()                                 │
│      ├── Clear messages                                     │
│      └── notifyListeners() ──► UI rebuilds                  │
└──────────────────────────────────────────────────────────────┘

                           │
                           │ Consumer<ChatProvider>
                           ▼

┌──────────────────────────────────────────────────────────────┐
│  ChatScreen (Widget)                                         │
│                                                              │
│  Consumer<ChatProvider>(                                     │
│    builder: (context, chatProvider, child) {                │
│      return ListView.builder(                               │
│        itemCount: chatProvider.messages.length,             │
│        itemBuilder: (context, index) {                      │
│          return MessageBubble(                              │
│            message: chatProvider.messages[index]            │
│          );                                                 │
│        }                                                    │
│      );                                                     │
│    }                                                        │
│  )                                                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 🚀 Build & Deployment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  BUILD & DEPLOYMENT                              │
└─────────────────────────────────────────────────────────────────┘

Development
───────────
flutter run
    │
    ├─► Hot Reload (r)
    ├─► Hot Restart (R)
    └─► Debug on device


Build Android APK
─────────────────
flutter build apk --release
    │
    └─► build/app/outputs/flutter-apk/app-release.apk


Build Android App Bundle
─────────────────────────
flutter build appbundle --release
    │
    └─► build/app/outputs/bundle/release/app-release.aab
    │
    └─► Upload to Google Play Console


Build iOS
─────────
flutter build ios --release
    │
    └─► Open Xcode
    │
    └─► Archive & Upload to App Store Connect


Configuration
─────────────
android/app/build.gradle
    │
    ├─► applicationId: "com.zena.mobile"
    ├─► versionCode: 1
    └─► versionName: "1.0.0"

ios/Runner/Info.plist
    │
    ├─► CFBundleIdentifier: com.zena.mobile
    ├─► CFBundleVersion: 1
    └─► CFBundleShortVersionString: 1.0.0
```

This comprehensive Flutter architecture diagram shows exactly how your mobile app connects to the existing backend! 🎯