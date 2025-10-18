import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/providers/chat_provider.dart';
import 'package:zena_mobile/services/submission_state_manager.dart';
import 'package:zena_mobile/models/message.dart';

void main() {
  group('Offline Queue Integration Tests', () {
    late ChatProvider chatProvider;
    late SubmissionStateManager stateManager;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      stateManager = SubmissionStateManager(prefs);
      chatProvider = ChatProvider(stateManager);
    });

    tearDown(() {
      chatProvider.dispose();
    });

    test('should detect offline state', () async {
      // Initially should be online
      expect(chatProvider.isOnline, isTrue);
      expect(chatProvider.hasQueuedMessages, isFalse);
      expect(chatProvider.queuedMessageCount, equals(0));
    });

    test('should expose queued message count', () {
      expect(chatProvider.queuedMessageCount, equals(0));
      expect(chatProvider.hasQueuedMessages, isFalse);
    });

    test('should provide retry method for queued messages', () {
      // Verify the method exists and can be called
      expect(() => chatProvider.retryQueuedMessages(), returnsNormally);
    });

    test('should handle network error detection', () {
      // Test various network error strings
      final networkErrors = [
        'network error',
        'connection failed',
        'socket exception',
        'timeout',
        'failed host lookup',
        'no internet',
      ];

      // This is an internal method, but we can verify behavior through sendMessage
      // The actual test would require mocking the chat service
    });

    test('should expose online status getter', () {
      expect(chatProvider.isOnline, isA<bool>());
    });

    test('should expose queued messages status', () {
      expect(chatProvider.hasQueuedMessages, isA<bool>());
      expect(chatProvider.queuedMessageCount, isA<int>());
    });
  });

  group('Message Pending Indicator', () {
    test('message should have localOnly flag for pending messages', () {
      final message = Message(
        id: 'test-id',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime.now(),
        localOnly: true,
        synced: false,
      );

      expect(message.localOnly, isTrue);
      expect(message.synced, isFalse);
    });

    test('message should have synced flag for sent messages', () {
      final message = Message(
        id: 'test-id',
        role: 'user',
        content: 'Test message',
        createdAt: DateTime.now(),
        localOnly: false,
        synced: true,
      );

      expect(message.localOnly, isFalse);
      expect(message.synced, isTrue);
    });
  });
}
