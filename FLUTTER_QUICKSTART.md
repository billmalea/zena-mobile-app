# 🚀 Zena Flutter Mobile - Quick Start Guide

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Android Studio / Xcode
- Your Zena backend running (https://zena.co.ke)

---

## ⚡ 5-Minute Setup

### 1. Create Flutter Project (if not exists)

```bash
# In parent directory (outside zena folder)
flutter create zena_mobile
cd zena_mobile
```

### 2. Update pubspec.yaml

Replace the dependencies section with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  provider: ^6.1.1
  http: ^1.1.2
  supabase_flutter: ^2.0.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.5
  intl: ^0.18.1
  uuid: ^4.2.2
  cached_network_image: ^3.3.0
```

Then run:
```bash
flutter pub get
```

### 3. Create Folder Structure

```bash
mkdir -p lib/config lib/models lib/services lib/providers lib/screens/chat lib/screens/auth lib/widgets/chat lib/widgets/common lib/utils
```

### 4. Add Configuration

Create `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'https://zena.co.ke';
  static const String apiUrl = '$baseUrl/api';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
}
```

### 5. Copy Implementation Files

Copy these files from the FLUTTER_MOBILE_IMPLEMENTATION.md to your project:

**Priority Order:**
1. `config/theme.dart` - Theme configuration
2. `services/api_service.dart` - API client
3. `services/chat_service.dart` - Chat streaming
4. `services/auth_service.dart` - Authentication
5. `models/message.dart` - Message model
6. `models/property.dart` - Property model
7. `models/conversation.dart` - Conversation model
8. `providers/chat_provider.dart` - Chat state
9. `providers/auth_provider.dart` - Auth state
10. `widgets/chat/message_bubble.dart` - Message UI
11. `widgets/chat/property_card.dart` - Property UI
12. `widgets/chat/message_input.dart` - Input UI
13. `widgets/chat/typing_indicator.dart` - Loading UI
14. `screens/chat/chat_screen.dart` - Main screen
15. `screens/auth/welcome_screen.dart` - Auth screen
16. `main.dart` - App entry

### 6. Run the App

```bash
flutter run
```

---

## 🎯 Minimal Working Version (30 minutes)

If you want to get something working FAST, here's the absolute minimum:

### Step 1: Create `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const ZenaApp());

class ZenaApp extends StatelessWidget {
  const ZenaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zena',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://zena.co.ke/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'parts': [{'type': 'text', 'text': userMessage}]}
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Parse response (simplified - you'll need proper SSE parsing)
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Response received (implement SSE parsing)'
          });
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zena Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 2: Run It

```bash
flutter run
```

This gives you a basic chat interface. Then gradually add:
1. Proper SSE parsing
2. Property card rendering
3. Authentication
4. Better UI

---

## 🔧 Testing Backend Connection

### Test API Endpoint

```dart
// Add this to test your backend
Future<void> testBackend() async {
  try {
    final response = await http.get(
      Uri.parse('https://zena.co.ke/api/conversations'),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 📱 Platform-Specific Setup

### Android (android/app/src/main/AndroidManifest.xml)

Add permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (ios/Runner/Info.plist)

Add permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for property photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access</string>
```

---

## 🐛 Common Issues & Fixes

### Issue: "Certificate verification failed"
**Fix:** Add this to your API service (development only):
```dart
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// In main():
HttpOverrides.global = MyHttpOverrides();
```

### Issue: "CORS error"
**Fix:** Your backend already handles CORS. Make sure you're using the correct URL.

### Issue: "Supabase not initialized"
**Fix:** Make sure you call `await Supabase.initialize()` in main() before runApp().

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- Your Backend API: https://zena.co.ke/api

---

## 🎯 Development Workflow

1. **Start backend** (if running locally)
2. **Run Flutter app**: `flutter run`
3. **Hot reload**: Press `r` in terminal
4. **Full restart**: Press `R` in terminal
5. **Test on device**: `flutter run -d <device-id>`

---

## ✅ Checklist

- [ ] Flutter installed and working
- [ ] Project created
- [ ] Dependencies added
- [ ] Config file updated with URLs
- [ ] Basic chat screen working
- [ ] Can send messages to backend
- [ ] Can receive responses
- [ ] Property cards rendering
- [ ] Authentication working

---

**You're ready to build! Start with the minimal version and gradually add features.** 🚀
