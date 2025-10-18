import 'package:flutter_test/flutter_test.dart';
import 'package:zena_mobile/models/message.dart';

void main() {
  group('Message Model with Persistence Fields', () {
    test('should create message with default persistence fields', () {
      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Hello',
        createdAt: DateTime.now(),
      );

      expect(message.synced, false);
      expect(message.localOnly, false);
      expect(message.updatedAt, isNull);
    });

    test('should create message with custom persistence fields', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final message = Message(
        id: 'msg-1',
        role: 'assistant',
        content: 'Hi there',
        createdAt: now,
        synced: true,
        localOnly: true,
        updatedAt: updatedAt,
      );

      expect(message.synced, true);
      expect(message.localOnly, true);
      expect(message.updatedAt, updatedAt);
    });

    test('should serialize message with persistence fields to JSON', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Test message',
        createdAt: now,
        synced: true,
        localOnly: false,
        updatedAt: updatedAt,
      );

      final json = message.toJson();

      expect(json['id'], 'msg-1');
      expect(json['role'], 'user');
      expect(json['content'], 'Test message');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['synced'], true);
      expect(json['localOnly'], false);
      expect(json['updatedAt'], updatedAt.toIso8601String());
    });

    test('should deserialize message with persistence fields from JSON', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final json = {
        'id': 'msg-1',
        'role': 'assistant',
        'content': 'Test response',
        'createdAt': now.toIso8601String(),
        'synced': true,
        'localOnly': false,
        'updatedAt': updatedAt.toIso8601String(),
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg-1');
      expect(message.role, 'assistant');
      expect(message.content, 'Test response');
      expect(message.createdAt.toIso8601String(), now.toIso8601String());
      expect(message.synced, true);
      expect(message.localOnly, false);
      expect(message.updatedAt?.toIso8601String(), updatedAt.toIso8601String());
    });

    test('should deserialize message with missing persistence fields', () {
      final now = DateTime.now();

      final json = {
        'id': 'msg-1',
        'role': 'user',
        'content': 'Test',
        'createdAt': now.toIso8601String(),
      };

      final message = Message.fromJson(json);

      expect(message.synced, false);
      expect(message.localOnly, false);
      expect(message.updatedAt, isNull);
    });

    test('should serialize message with null updatedAt', () {
      final now = DateTime.now();

      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Test',
        createdAt: now,
        synced: false,
        localOnly: false,
      );

      final json = message.toJson();

      expect(json['updatedAt'], isNull);
    });

    test('should copy message with updated persistence fields', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final original = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Original',
        createdAt: now,
        synced: false,
        localOnly: false,
      );

      final updated = original.copyWith(
        synced: true,
        localOnly: true,
        updatedAt: updatedAt,
      );

      expect(updated.id, original.id);
      expect(updated.role, original.role);
      expect(updated.content, original.content);
      expect(updated.createdAt, original.createdAt);
      expect(updated.synced, true);
      expect(updated.localOnly, true);
      expect(updated.updatedAt, updatedAt);
    });

    test('should copy message without changing persistence fields', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final original = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Original',
        createdAt: now,
        synced: true,
        localOnly: true,
        updatedAt: updatedAt,
      );

      final copied = original.copyWith(content: 'Updated content');

      expect(copied.content, 'Updated content');
      expect(copied.synced, true);
      expect(copied.localOnly, true);
      expect(copied.updatedAt, updatedAt);
    });

    test('should serialize and deserialize message with tool results and persistence fields', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final toolResult = ToolResult(
        toolName: 'search',
        result: {'query': 'test', 'results': []},
      );

      final message = Message(
        id: 'msg-1',
        role: 'assistant',
        content: 'Here are the results',
        createdAt: now,
        toolResults: [toolResult],
        synced: true,
        localOnly: false,
        updatedAt: updatedAt,
      );

      final json = message.toJson();
      final deserialized = Message.fromJson(json);

      expect(deserialized.id, message.id);
      expect(deserialized.role, message.role);
      expect(deserialized.content, message.content);
      expect(deserialized.toolResults?.length, 1);
      expect(deserialized.toolResults?[0].toolName, 'search');
      expect(deserialized.synced, true);
      expect(deserialized.localOnly, false);
      expect(deserialized.updatedAt?.toIso8601String(), updatedAt.toIso8601String());
    });

    test('should serialize and deserialize message with metadata and persistence fields', () {
      final now = DateTime.now();
      final updatedAt = now.add(Duration(minutes: 5));

      final message = Message(
        id: 'msg-1',
        role: 'user',
        content: 'Submit property',
        createdAt: now,
        metadata: {
          'submissionId': 'sub-123',
          'workflowStage': 'property_submission',
        },
        synced: false,
        localOnly: true,
        updatedAt: updatedAt,
      );

      final json = message.toJson();
      final deserialized = Message.fromJson(json);

      expect(deserialized.metadata?['submissionId'], 'sub-123');
      expect(deserialized.metadata?['workflowStage'], 'property_submission');
      expect(deserialized.synced, false);
      expect(deserialized.localOnly, true);
      expect(deserialized.updatedAt?.toIso8601String(), updatedAt.toIso8601String());
    });
  });
}
