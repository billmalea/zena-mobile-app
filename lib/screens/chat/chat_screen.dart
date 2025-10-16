import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/property_card.dart';
import '../../widgets/chat/message_input.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../config/theme.dart';

/// ChatScreen - Main chat interface for interacting with the AI assistant
/// Displays message history, handles user input, and shows property results
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Message list (takes up remaining space)
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return _buildMessageList(chatProvider);
              },
            ),
          ),

          // Message input (fixed at bottom)
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return MessageInput(
                onSend: (text, fileUrls) => _handleSendMessage(
                  context,
                  chatProvider,
                  text,
                  fileUrls,
                ),
                isLoading: chatProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build AppBar with title and new chat button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Zena'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_comment_outlined),
          tooltip: 'New Chat',
          onPressed: () => _handleNewChat(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build message list with messages and typing indicator
  Widget _buildMessageList(ChatProvider chatProvider) {
    // Show empty state if no messages
    if (chatProvider.messages.isEmpty && !chatProvider.isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator at the end if loading
        if (index == chatProvider.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: TypingIndicator(),
          );
        }

        final message = chatProvider.messages[index];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message bubble for text content
            if (message.content.isNotEmpty)
              MessageBubble(message: message),

            // Property cards for tool results
            if (message.hasToolResults)
              ...message.toolResults!.map((toolResult) {
                if (toolResult.toolName == 'searchProperties') {
                  return _buildPropertyResults(toolResult.result);
                }
                return const SizedBox.shrink();
              }),
          ],
        );
      },
    );
  }

  /// Build empty state when no messages
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me about properties, rentals, or anything else!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build property results from tool result
  Widget _buildPropertyResults(Map<String, dynamic> result) {
    final properties = result['properties'] as List<dynamic>?;
    
    if (properties == null || properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: properties.map((property) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: PropertyCard(
            propertyData: property as Map<String, dynamic>,
          ),
        );
      }).toList(),
    );
  }

  /// Handle sending a message
  Future<void> _handleSendMessage(
    BuildContext context,
    ChatProvider chatProvider,
    String text,
    List<String>? fileUrls,
  ) async {
    if (text.trim().isEmpty) return;

    try {
      await chatProvider.sendMessage(text, fileUrls);
      
      // Auto-scroll to bottom after sending
      _scrollToBottom();
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to send message: ${e.toString()}');
      }
    }
  }

  /// Handle new chat button press
  Future<void> _handleNewChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();

    // Show confirmation dialog if there are existing messages
    if (chatProvider.messages.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start New Chat?'),
          content: const Text(
            'This will clear the current conversation. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start New'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    try {
      await chatProvider.startNewConversation();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New conversation started'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to start new chat: ${e.toString()}');
      }
    }
  }

  /// Scroll to bottom of message list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Show error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
