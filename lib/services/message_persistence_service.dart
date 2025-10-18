import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

/// Service for persisting messages to local SQLite database
/// Handles CRUD operations for messages with conversation association
class MessagePersistenceService {
  final Database _db;

  MessagePersistenceService._(this._db);

  /// Initialize database and create service instance
  static Future<MessagePersistenceService> create() async {
    final db = await _initDatabase();
    return MessagePersistenceService._(db);
  }

  /// Create service with existing database (for testing)
  @visibleForTesting
  static MessagePersistenceService createWithDatabase(Database db) {
    return MessagePersistenceService._(db);
  }

  /// Initialize SQLite database with messages table and indexes
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zena_messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create messages table
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            tool_results TEXT,
            metadata TEXT,
            synced INTEGER DEFAULT 0,
            local_only INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Create index on conversation_id for efficient queries
        await db.execute('''
          CREATE INDEX idx_messages_conversation 
          ON messages(conversation_id)
        ''');

        // Create index on created_at for chronological ordering
        await db.execute('''
          CREATE INDEX idx_messages_created 
          ON messages(created_at)
        ''');
      },
    );
  }

  /// Save message to database (insert or replace if exists)
  Future<void> saveMessage(Message message, String conversationId) async {
    await _db.insert(
      'messages',
      {
        'id': message.id,
        'conversation_id': conversationId,
        'role': message.role,
        'content': message.content,
        'tool_results': message.toolResults != null
            ? jsonEncode(message.toolResults!.map((tr) => tr.toJson()).toList())
            : null,
        'metadata': message.metadata != null ? jsonEncode(message.metadata) : null,
        'synced': message.synced ? 1 : 0,
        'local_only': message.localOnly ? 1 : 0,
        'created_at': message.createdAt.millisecondsSinceEpoch,
        'updated_at': (message.updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update existing message in database
  Future<void> updateMessage(String messageId, Message message) async {
    await _db.update(
      'messages',
      {
        'content': message.content,
        'tool_results': message.toolResults != null
            ? jsonEncode(message.toolResults!.map((tr) => tr.toJson()).toList())
            : null,
        'metadata': message.metadata != null ? jsonEncode(message.metadata) : null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Load all messages for a conversation, ordered by creation time
  Future<List<Message>> loadMessages(String conversationId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => _messageFromMap(map)).toList();
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    await _db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Clear all messages for a conversation
  Future<void> clearConversationMessages(String conversationId) async {
    await _db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Mark message as synced with backend
  Future<void> markAsSynced(String messageId) async {
    await _db.update(
      'messages',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Get all unsynced messages across all conversations
  Future<List<Message>> getUnsyncedMessages() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'messages',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => _messageFromMap(map)).toList();
  }

  /// Convert database row to Message object
  Message _messageFromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      toolResults: map['tool_results'] != null
          ? (jsonDecode(map['tool_results'] as String) as List)
              .map((tr) => ToolResult.fromJson(tr as Map<String, dynamic>))
              .toList()
          : null,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      synced: (map['synced'] as int) == 1,
      localOnly: (map['local_only'] as int) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// Close database connection
  Future<void> close() async {
    await _db.close();
  }
}
