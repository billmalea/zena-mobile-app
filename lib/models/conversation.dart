import 'message.dart';

/// Conversation model for chat conversations
/// Represents a conversation with message history
class Conversation {
  final String id;
  final String userId;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional fields from list API response
  final String? title;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? messageCount;

  Conversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.lastMessage,
    this.lastMessageTime,
    this.messageCount,
  });

  /// Get preview of last message (first 50 characters)
  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    final lastMessage = messages.last;
    final content = lastMessage.content;
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  /// Get time ago string (e.g., "2 hours ago", "Yesterday")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if conversation has messages
  bool get hasMessages => messages.isNotEmpty;

  /// Create Conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? json['updated_at'] as String),
      title: json['title'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      messageCount: json['messageCount'] as int?,
    );
  }

  /// Convert Conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Conversation copyWith({
    String? id,
    String? userId,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? messageCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
