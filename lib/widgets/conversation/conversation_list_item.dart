import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/conversation.dart';

/// A list item widget that displays a conversation summary
/// Supports swipe-to-delete with confirmation dialog
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  /// Generate conversation title from first message or use default
  String get _title {
    if (conversation.messages.isEmpty) {
      return 'New Conversation';
    }

    final firstMessage = conversation.messages.first.content;
    if (firstMessage.length > 50) {
      return '${firstMessage.substring(0, 50)}...';
    }
    return firstMessage;
  }

  /// Get last message preview (truncated to 2 lines worth of text)
  String get _lastMessagePreview {
    if (conversation.messages.isEmpty) {
      return 'No messages yet';
    }

    final lastMessage = conversation.messages.last.content;
    // Approximate 2 lines as ~60 characters
    if (lastMessage.length > 60) {
      return '${lastMessage.substring(0, 60)}...';
    }
    return lastMessage;
  }

  /// Get relative timestamp (e.g., "2h ago", "Yesterday", "2d ago")
  String get _timestamp {
    if (conversation.messages.isEmpty) {
      return '';
    }

    final lastMessage = conversation.messages.last;
    final now = DateTime.now();
    final diff = now.difference(lastMessage.createdAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(lastMessage.createdAt);
    }
  }

  /// Show confirmation dialog before deletion
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        selected: isActive,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        onTap: onTap,
        title: Text(
          _title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _lastMessagePreview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          _timestamp,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
