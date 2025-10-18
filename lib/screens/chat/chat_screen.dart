import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/chat_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/workflow/submission_recovery_dialog.dart';
import '../../widgets/conversation/conversation_drawer.dart';
import '../../widgets/connectivity_indicator.dart';

/// ChatScreen - Main chat interface for interacting with the AI assistant
/// Displays message history, handles user input, and shows property results
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check for recovered submission after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForRecoveredSubmission();
    });
  }

  /// Check if there's a recovered submission and prompt user
  void _checkForRecoveredSubmission() {
    final chatProvider = context.read<ChatProvider>();

    if (chatProvider.hasRecoveredSubmission &&
        chatProvider.currentSubmissionState != null) {
      _showRecoveryDialog(chatProvider);
    }
  }

  /// Show recovery dialog to prompt user to continue or cancel submission
  void _showRecoveryDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmissionRecoveryDialog(
        submissionState: chatProvider.currentSubmissionState!,
        onContinue: () {
          Navigator.of(context).pop();
          // Submission is already restored, just dismiss dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Continuing your property submission'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
          chatProvider.cancelSubmission();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submission cancelled'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Track user scroll behavior
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Check if user is manually scrolling (not at bottom)
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;

    if (!isAtBottom) {
      _isUserScrolling = true;
    } else if (isAtBottom) {
      _isUserScrolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Error banner (if error exists)
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.error != null) {
                return _buildErrorBanner(context, chatProvider);
              }
              return const SizedBox.shrink();
            },
          ),

          // Message list (takes up remaining space)
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // Auto-scroll to bottom when new messages arrive
                _handleAutoScroll(chatProvider);
                return _buildMessageList(chatProvider);
              },
            ),
          ),

          // Message input (fixed at bottom)
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return MessageInput(
                onSend: (text, files) => _handleSendMessage(
                  context,
                  chatProvider,
                  text,
                  files,
                ),
                isLoading:
                    chatProvider.isLoading || chatProvider.isUploadingFiles,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build AppBar with menu button, conversation title, and new chat button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Conversations',
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Consumer2<ChatProvider, ConversationProvider>(
        builder: (context, chatProvider, conversationProvider, child) {
          return Text(
              _getConversationTitle(chatProvider, conversationProvider));
        },
      ),
      actions: [
        const ConnectivityIndicator(size: 10),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'New Chat',
          onPressed: () => _handleNewChat(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build conversation drawer
  Widget _buildDrawer(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return ConversationDrawer(
          activeConversationId: chatProvider.conversationId,
          onConversationSelected: (conversationId) =>
              _handleConversationSelected(context, conversationId),
          onNewConversation: () => _handleNewConversationFromDrawer(context),
        );
      },
    );
  }

  /// Get conversation title for app bar
  /// Returns conversation title based on first message or default
  String _getConversationTitle(
      ChatProvider chatProvider, ConversationProvider conversationProvider) {
    // If we have an active conversation ID, try to find it in the conversation list
    if (chatProvider.conversationId != null) {
      final conversation = conversationProvider.conversations
          .where((c) => c.id == chatProvider.conversationId)
          .firstOrNull;

      if (conversation != null && conversation.messages.isNotEmpty) {
        // Generate title from first message
        final firstMessage = conversation.messages.first.content;
        if (firstMessage.length > 30) {
          return '${firstMessage.substring(0, 30)}...';
        }
        return firstMessage;
      }
    }

    // Default title
    return 'Zena';
  }

  /// Handle auto-scroll behavior when messages change
  void _handleAutoScroll(ChatProvider chatProvider) {
    final currentMessageCount = chatProvider.messages.length;

    // Check if messages have changed
    if (currentMessageCount != _previousMessageCount) {
      final isNewMessage = currentMessageCount > _previousMessageCount;
      _previousMessageCount = currentMessageCount;

      // Auto-scroll to bottom if:
      // 1. New message arrived AND user is not manually scrolling up
      // 2. OR we're loading (streaming response)
      if (isNewMessage && !_isUserScrolling) {
        _scrollToBottom();
      } else if (chatProvider.isLoading && !_isUserScrolling) {
        _scrollToBottom();
      }
    }
  }

  /// Build message list with messages and typing indicator
  Widget _buildMessageList(ChatProvider chatProvider) {
    // Show empty state if no messages
    if (chatProvider.messages.isEmpty && !chatProvider.isLoading) {
      _previousMessageCount = 0;
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount:
          chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator at the end if loading
        if (index == chatProvider.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: TypingIndicator(),
          );
        }

        final message = chatProvider.messages[index];

        // Message bubble now handles both content and tool results
        return MessageBubble(
          message: message,
          onSendMessage: (text) => _handleSendMessage(
            context,
            chatProvider,
            text,
            null,
          ),
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
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me about properties, rentals, or anything else!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error banner with dismiss and retry options
  Widget _buildErrorBanner(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              chatProvider.error ?? 'An error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: theme.colorScheme.error,
            tooltip: 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: () {
              chatProvider.clearError();
            },
          ),
        ],
      ),
    );
  }

  /// Handle sending a message
  Future<void> _handleSendMessage(
    BuildContext context,
    ChatProvider chatProvider,
    String text,
    List<File>? files,
  ) async {
    if (text.trim().isEmpty && (files == null || files.isEmpty)) return;

    try {
      // Reset user scrolling flag when sending a new message
      _isUserScrolling = false;

      await chatProvider.sendMessage(text, files);

      // Auto-scroll will be handled by _handleAutoScroll
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to send message: ${e.toString()}');
      }
    }
  }

  /// Handle conversation selection from drawer
  Future<void> _handleConversationSelected(
      BuildContext context, String conversationId) async {
    final chatProvider = context.read<ChatProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    try {
      // Reset scroll state
      _previousMessageCount = 0;
      _isUserScrolling = false;

      // Load the selected conversation
      await chatProvider.loadConversation(conversationId);

      // Update active conversation in conversation provider
      conversationProvider.setActiveConversation(conversationId);

      // Close the drawer
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close drawer even on error
        _showError(context, 'Failed to load conversation: ${e.toString()}');
      }
    }
  }

  /// Handle new conversation from drawer
  Future<void> _handleNewConversationFromDrawer(BuildContext context) async {
    // Close drawer first
    Navigator.pop(context);

    // Then handle new chat
    await _handleNewChat(context);
  }

  /// Handle new chat button press
  Future<void> _handleNewChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    final conversationProvider = context.read<ConversationProvider>();

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
      // Reset scroll state
      _previousMessageCount = 0;
      _isUserScrolling = false;

      await chatProvider.startNewConversation();

      // Clear active conversation in conversation provider
      conversationProvider
          .setActiveConversation(chatProvider.conversationId ?? '');

      // Refresh conversation list to include the new conversation
      await conversationProvider.loadConversations(refresh: true);

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
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
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
