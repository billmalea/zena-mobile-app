import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/property_card.dart';
import '../../widgets/chat/message_input.dart';
import '../../widgets/chat/typing_indicator.dart';

/// ChatScreen - Main chat interface for interacting with the AI assistant
/// Displays message history, handles user input, and shows property results
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Track if user is manually scrolling
  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;

      if (!isAtBottom && !_isUserScrolling) {
        setState(() {
          _isUserScrolling = true;
        });
      } else if (isAtBottom && _isUserScrolling) {
        setState(() {
          _isUserScrolling = false;
        });
      }
    }
  }

  /// Scroll to bottom of message list
  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zena'),
        actions: [
          // New chat button
          IconButton(
            onPressed: () => _handleNewChat(context),
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New conversation',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Auto-scroll to bottom when new messages arrive (if not manually scrolling)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isUserScrolling && _scrollController.hasClients) {
              _scrollToBottom(animate: true);
            }
          });

          return Column(
            children: [
              // Error display
              if (chatProvider.error != null) _buildErrorBanner(chatProvider),

              // Message list
              Expanded(
                child: Stack(
                  children: [
                    _buildMessageList(chatProvider),

                    // Typing indicator
                    if (chatProvider.isLoading)
                      const Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: TypingIndicator(),
                      ),
                  ],
                ),
              ),

              // Message input
              MessageInput(
                onSend: (text, fileUrls) => _handleSendMessage(
                  context,
                  chatProvider,
                  text,
                  fileUrls,
                ),
                isLoading: chatProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build message list widget
  Widget _buildMessageList(ChatProvider chatProvider) {
    final messages = chatProvider.messages;

    // Empty state
    if (messages.isEmpty && !chatProvider.isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text message bubble
            if (message.content.isNotEmpty) MessageBubble(message: message),

            // Tool results (property cards)
            if (message.hasToolResults)
              ...message.toolResults!.map((toolResult) {
                return _buildToolResult(toolResult);
              }),
          ],
        );
      },
    );
  }

  /// Build empty state widget
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
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me about properties, rentals, or anything else!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tool result widget (property cards, etc.)
  Widget _buildToolResult(dynamic toolResult) {
    // Check if it's a property search result
    if (toolResult.toolName == 'searchProperties' ||
        toolResult.toolName == 'search_properties') {
      final result = toolResult.result;

      // Handle array of properties
      if (result['properties'] is List) {
        final properties = result['properties'] as List;

        return Column(
          children: properties.map((property) {
            if (property is Map<String, dynamic>) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: PropertyCard(propertyData: property),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        );
      }

      // Handle single property
      if (result is Map<String, dynamic>) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: PropertyCard(propertyData: result),
        );
      }
    }

    // For other tool results, show a simple card
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tool: ${toolResult.toolName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  /// Build error banner widget
  Widget _buildErrorBanner(ChatProvider chatProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatProvider.error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => chatProvider.clearError(),
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: Colors.red[700],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Handle send message
  Future<void> _handleSendMessage(
    BuildContext context,
    ChatProvider chatProvider,
    String text,
    List<String>? fileUrls,
  ) async {
    if (text.trim().isEmpty && (fileUrls == null || fileUrls.isEmpty)) {
      return;
    }

    try {
      await chatProvider.sendMessage(text, fileUrls);

      // Scroll to bottom after sending
      _scrollToBottom(animate: true);
    } catch (e) {
      // Error is handled by ChatProvider
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleSendMessage(
                context,
                chatProvider,
                text,
                fileUrls,
              ),
            ),
          ),
        );
      }
    }
  }

  /// Handle new chat button press
  void _handleNewChat(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

    // Show confirmation dialog if there are existing messages
    if (chatProvider.messages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start new conversation?'),
          content: const Text(
            'This will clear the current conversation. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewConversation(context, chatProvider);
              },
              child: const Text('Start New'),
            ),
          ],
        ),
      );
    } else {
      _startNewConversation(context, chatProvider);
    }
  }

  /// Start a new conversation
  Future<void> _startNewConversation(
    BuildContext context,
    ChatProvider chatProvider,
  ) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start new conversation: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
