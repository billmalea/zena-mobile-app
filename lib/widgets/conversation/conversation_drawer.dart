import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../common/shimmer_widget.dart';
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

            // Footer with user info and settings
            const Divider(height: 1),
            _buildFooter(context),
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
        // Show shimmer loading state when loading and no conversations
        if (provider.isLoading && provider.conversations.isEmpty) {
          return const ShimmerConversationList(itemCount: 8);
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

  /// Build footer with user info, theme toggle, and sign out button
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Extract user's name from email or metadata
        String userName = 'User';
        String userInitial = 'U';

        if (authProvider.user?.email != null) {
          final email = authProvider.user!.email!;
          // Try to get name from user metadata first
          final metadataName =
              authProvider.user!.userMetadata?['name'] as String?;

          if (metadataName != null && metadataName.isNotEmpty) {
            userName = metadataName;
            userInitial = metadataName[0].toUpperCase();
          } else {
            // Use email prefix as fallback
            userName = email.split('@').first;
            userInitial = userName[0].toUpperCase();
          }
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User info row
              Row(
                children: [
                  // Avatar with user initials
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      userInitial,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User name
                  Expanded(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Theme toggle button
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      final themeProvider = context.read<ThemeProvider>();
                      themeProvider.setThemeMode(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                    tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sign out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true && context.mounted) {
                      await authProvider.signOut();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
