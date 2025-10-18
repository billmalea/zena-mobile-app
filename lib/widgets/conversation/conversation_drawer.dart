import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_provider.dart';
import 'conversation_list_item.dart';
import 'conversation_search.dart';

/// Conversation Drawer Widget
/// Displays a slide-out drawer with conversation list, search, and new conversation button
class ConversationDrawer extends StatefulWidget {
  final String? activeConversationId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;

  const ConversationDrawer({
    super.key,
    this.activeConversationId,
    required this.onConversationSelected,
    required this.onNewConversation,
  });

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  @override
  void initState() {
    super.initState();
    // Load conversations when drawer is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConversationProvider>();
      if (provider.conversations.isEmpty && !provider.isLoading) {
        provider.loadConversations(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with title and new conversation button
            _buildHeader(context),

            const Divider(height: 1),

            // Search bar
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ConversationSearch(),
            ),

            const Divider(height: 1),

            // Conversation list
            Expanded(
              child: _buildConversationList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header with "Conversations" title and "New Conversation" button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Conversations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.onNewConversation,
            tooltip: 'New Conversation',
          ),
        ],
      ),
    );
  }

  /// Build conversation list with loading, error, and empty states
  Widget _buildConversationList(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, child) {
        // Show loading indicator when loading and no conversations
        if (provider.isLoading && provider.conversations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show error message when error occurs
        if (provider.error != null) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(provider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadConversations(refresh: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Show empty state when no conversations
        if (provider.conversations.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(provider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new conversation to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Show conversation list with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => _handleRefresh(provider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = provider.conversations[index];
              return ConversationListItem(
                conversation: conversation,
                isActive: conversation.id == widget.activeConversationId,
                onTap: () => widget.onConversationSelected(conversation.id),
                onDelete: () => provider.deleteConversation(conversation.id),
              );
            },
          ),
        );
      },
    );
  }

  /// Handle pull-to-refresh action
  Future<void> _handleRefresh(ConversationProvider provider) async {
    await provider.loadConversations(refresh: true);
  }
}
