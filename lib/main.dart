import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/conversation_provider.dart';
import 'services/submission_state_manager.dart';
import 'services/chat_service.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/chat/chat_screen.dart';

/// Main entry point for the Zena mobile app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.local");

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize SharedPreferences for submission state management
  final prefs = await SharedPreferences.getInstance();
  final stateManager = SubmissionStateManager(prefs);

  runApp(ZenaApp(stateManager: stateManager));
}

/// Root application widget
class ZenaApp extends StatelessWidget {
  final SubmissionStateManager stateManager;

  const ZenaApp({super.key, required this.stateManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider(stateManager)),
        ChangeNotifierProvider(create: (_) => ConversationProvider(ChatService())),
      ],
      child: MaterialApp(
        title: 'Zena',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication routing
/// Shows WelcomeScreen if not authenticated, ChatScreen if authenticated
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while checking auth state
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }

      //  Show appropriate screen based on authentication state
       if (authProvider.isAuthenticated) {
         return const ChatScreen();
       } else {
          return const WelcomeScreen();
       }
      },
    );
  }
}
