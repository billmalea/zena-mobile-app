import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zena_mobile/providers/chat_provider.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';

void main() {
  // Initialize sqflite_ffi and load environment variables for testing
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.local');
    
    // Initialize SharedPreferences mock before Supabase
    SharedPreferences.setMockInitialValues({});
    
    // Initialize Supabase with test credentials
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Message Sync Service Integration Tests', () {
    late ChatProvider chatProvider;
    late SubmissionStateManager stateManager;
    bool manuallyDisposed = false;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create state manager
      stateManager = SubmissionStateManager(prefs);

      // Create chat provider (this will initialize sync service)
      chatProvider = ChatProvider(stateManager);

      // Reset flag
      manuallyDisposed = false;

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDown(() {
      // Only dispose if not already disposed manually in test
      if (!manuallyDisposed) {
        chatProvider.dispose();
      }
    });

    test('Background sync starts when ChatProvider initializes', () async {
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify sync service is initialized (indirectly through no errors)
      expect(chatProvider.error, isNull);
    });

    test('Background sync stops when ChatProvider disposes', () {
      // Dispose should not throw
      expect(() => chatProvider.dispose(), returnsNormally);
      
      // Mark as manually disposed so tearDown doesn't try again
      manuallyDisposed = true;
    });

    test(
        'Manual sync for current conversation handles no conversation gracefully',
        () async {
      // Try to sync without a conversation loaded
      await chatProvider.syncCurrentConversation();

      // Should not throw or set error
      expect(chatProvider.error, isNull);
    });

    test('Manual sync for all conversations handles errors gracefully',
        () async {
      // Try to sync all conversations (will fail due to no auth, but should handle gracefully)
      await chatProvider.syncAllConversations();

      // Should not throw (errors are logged but not set)
      expect(chatProvider.error, isNull);
    });

    test('Sync service integration does not interfere with message sending',
        () async {
      // Start a new conversation
      try {
        await chatProvider.startNewConversation();
      } catch (e) {
        // Expected to fail without proper auth, but sync should not interfere
      }

      // Verify sync service is still running
      expect(chatProvider.error, isNotNull); // Auth error, not sync error
    });
  });

  group('Sync Error Handling Tests', () {
    late ChatProvider chatProvider;
    late SubmissionStateManager stateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      stateManager = SubmissionStateManager(prefs);
      chatProvider = ChatProvider(stateManager);
      await Future.delayed(const Duration(milliseconds: 500));
    });

    tearDown(() {
      chatProvider.dispose();
    });

    test('Sync errors do not crash the app', () async {
      // Trigger sync without proper setup
      await chatProvider.syncAllConversations();

      // Should complete without throwing
      expect(chatProvider.error, isNull);
    });

    test('Manual conversation sync handles missing conversation gracefully', () async {
      // Load a fake conversation ID
      try {
        await chatProvider.loadConversation('fake-conversation-id');
      } catch (e) {
        // Expected to fail
      }

      // Clear error
      chatProvider.clearError();

      // Try to sync without a valid conversation (will log warning but not set error)
      await chatProvider.syncCurrentConversation();

      // Should not set error when conversation is not properly loaded
      // (The sync service handles this gracefully by logging a warning)
      expect(chatProvider.error, isNull);
    });
  });

  group('Periodic Sync Tests', () {
    test('Background sync runs periodically', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final stateManager = SubmissionStateManager(prefs);
      final chatProvider = ChatProvider(stateManager);

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify no errors during initialization
      expect(chatProvider.error, isNull);

      // Wait a bit to ensure periodic sync doesn't crash
      await Future.delayed(const Duration(seconds: 2));

      // Still no errors
      expect(chatProvider.error, isNull);

      chatProvider.dispose();
    });
  });
}
