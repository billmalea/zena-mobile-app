# 📱 Zena Mobile - Flutter Implementation

> **Copy this file to your zena-mobile folder as README.md**

## 🚀 Quick Start

```bash
# 1. Get dependencies
flutter pub get

# 2. Update configuration
# Edit lib/config/app_config.dart with your URLs

# 3. Run the app
flutter run
```

## 📚 Documentation

All implementation documentation is in the `zena` folder:

1. **START HERE:** `FLUTTER_QUICKSTART.md` - Get running in 5 minutes
2. **IMPLEMENTATION:** `FLUTTER_MOBILE_IMPLEMENTATION.md` - Complete guide
3. **DIAGRAMS:** `FLUTTER_ARCHITECTURE_DIAGRAMS.md` - Visual architecture
4. **CODE FILES:** `FLUTTER_COMPLETE_FILES.md` - Copy-paste ready code
5. **SUMMARY:** `FLUTTER_IMPLEMENTATION_SUMMARY.md` - Overview

## 🎯 What This App Does

- ✅ **Chat Interface** - Main interaction with AI
- ✅ **Google Sign In** - Simple authentication
- ✅ **Property Search** - AI-powered rental search
- ✅ **Real-time Streaming** - Live AI responses
- ✅ **Property Cards** - Auto-rendered from backend
- ✅ **M-Pesa Payments** - Contact info access

## 🏗️ Architecture

```
Flutter App (UI)
      │
      │ HTTPS
      ▼
Backend API (zena.co.ke)
      │
      ├─► /api/chat (AI)
      ├─► /api/conversations
      └─► Supabase Auth
```

## 📦 Project Structure

```
lib/
├── config/
│   ├── app_config.dart      # API URLs
│   └── theme.dart            # App theme
├── models/
│   ├── message.dart
│   ├── property.dart
│   └── conversation.dart
├── services/
│   ├── api_service.dart      # HTTP client
│   ├── chat_service.dart     # Chat API
│   └── auth_service.dart     # Supabase auth
├── providers/
│   ├── chat_provider.dart    # Chat state
│   └── auth_provider.dart    # Auth state
├── screens/
│   ├── auth/
│   │   └── welcome_screen.dart
│   └── chat/
│       └── chat_screen.dart
├── widgets/
│   └── chat/
│       ├── message_bubble.dart
│       ├── property_card.dart
│       ├── message_input.dart
│       └── typing_indicator.dart
└── main.dart
```

## 🔧 Configuration

### 1. Update lib/config/app_config.dart

```dart
class AppConfig {
  static const String baseUrl = 'https://zena.co.ke';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
}
```

### 2. Configure OAuth Redirect

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="zena" android:host="auth-callback" />
</intent-filter>
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>zena</string>
</array>
```

## 🧪 Testing

```bash
# Run on device
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📱 Features

### Authentication
- Google Sign In via Supabase
- Session management
- Auto-login

### Chat
- Real-time AI streaming
- Message history
- File attachments
- Typing indicators

### Properties
- Auto-rendered cards
- Image galleries
- Contact requests
- M-Pesa payments

## 🎨 UI/UX

- **Theme:** Emerald/Teal (matching web)
- **Font:** Inter (Google Fonts)
- **Design:** Material 3
- **Responsive:** Works on all screen sizes

## 🔄 Development Workflow

1. **Make changes** to code
2. **Hot reload** - Press `r` in terminal
3. **Hot restart** - Press `R` in terminal
4. **Test** on device/emulator

## 📊 State Management

Using **Provider** pattern:
- `ChatProvider` - Manages chat state
- `AuthProvider` - Manages auth state
- Simple and lightweight

## 🌐 API Integration

Connects to existing backend:
- `POST /api/chat` - Send messages
- `GET /api/chat/conversation` - Get history
- `POST /api/upload` - Upload files
- Supabase Auth - Google OAuth

## 🐛 Common Issues

### Can't connect to backend
- Check `app_config.dart` URL
- Ensure backend is running
- Check network connection

### Google Sign In fails
- Check Supabase OAuth config
- Verify redirect URL
- Check OAuth credentials

### Streaming not working
- Check SSE parsing
- Verify API endpoint
- Check network logs

## 📚 Resources

- [Flutter Docs](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

## 🎯 Next Steps

1. ✅ Copy documentation files
2. ✅ Follow FLUTTER_QUICKSTART.md
3. ✅ Implement code files
4. ✅ Test with backend
5. ✅ Deploy to stores

## 💡 Tips

- Start with minimal version
- Test frequently
- Use hot reload
- Check logs for errors
- Test on real devices

## 🤝 Support

For implementation help, refer to:
- `FLUTTER_QUICKSTART.md` - Quick setup
- `FLUTTER_MOBILE_IMPLEMENTATION.md` - Detailed guide
- `FLUTTER_ARCHITECTURE_DIAGRAMS.md` - Visual diagrams

---

**Built with Flutter 💙 | Powered by Zena Backend 🏠**
