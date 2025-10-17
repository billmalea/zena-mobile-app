# Design Document

## Overview

The Conversation Management Enhancement provides users with the ability to view, switch between, search, and manage multiple conversations. The system builds on existing conversation API endpoints and models, adding UI components and state management for a complete conversation management experience.

**Current State:** Basic conversation API exists (`getConversations()` in ChatService). Need to add UI and state management.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Chat Screen                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  App Bar                                         │  │
│  │  [☰ Menu] Conversation Title                    │  │
│  └──────────────────────────────────────────────────┘  │
│                         │                               │
│                         ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Conversation Drawer                             │  │
│  │  ┌────────────────────────────────────────────┐ │  │
│  │  │  [+ New Conversation]                      │ │  │
│  │  │  [🔍 Search...]                            │ │  │
│  │  │                                            │ │  │
│  │  │  Conversation List                         │ │  │
│  │  │  ├─ Property Search (2h ago)               │ │  │
│  │  │  ├─ Contact Request (Yesterday)            │ │  │
│  │  │  └─ Property Submission (2 days ago)       │ │  │
│  │  └────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Conversation Provider

**Location:** `lib/providers/conversation_provider.dart`

**Purpose:** Manage conversation list state and operations

**Interface:**
```dart
class ConversationProvider with ChangeNotifier {
  final ChatService _chatService;
  
  List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  
  // Getters
  List<Conversation> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  
  // Load conversations
  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _conversations = [];
      _hasMore = true;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newConversations = await _chatService.getConversations();
      
      if (refresh) {
        _conversations = newConversations;
      } else {
        _conversations.addAll(newConversations);
      }
      
      _hasMore = newConversations.length >= 20;
      _currentPage++;
    } catch (e) {
      _error = 'Failed to load conversations: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load more (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadConversations();
  }
  
  // Switch conversation
  Future<void> switchConversation(String conversationId) async {
    _activeConversationId = conversationId;
    notifyListeners();
  }
  
  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Call API to delete (if endpoint exists)
      // await _chatService.deleteConversation(conversationId);
      
      // Remove from local list
      _conversations.removeWhere((c) => c.id == conversationId);
      
      // If deleted active conversation, clear it
      if (_activeConversationId == conversationId) {
        _activeConversationId = null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Search conversations
  Future<void> searchConversations(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      await loadConversations(refresh: true);
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Filter locally for now
      // TODO: Implement server-side search if available
      final allConversations = await _chatService.getConversations();
      _conversations = allConversations.where((conv) {
        final lastMessage = conv.messages.isNotEmpty 
          ? conv.messages.last.content.toLowerCase()
          : '';
        return lastMessage.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set active conversation
  void setActiveConversation(String conversationId) {
    _activeConversationId = conversationId;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### 2. Conversation Drawer

**Location:** `lib/widgets/conversation/conversation_drawer.dart`

**Purpose:** Slide-out drawer with conversation list

**Interface:**
```dart
class ConversationDrawer extends StatelessWidget {
  final String? activeConversationId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;
  
  const ConversationDrawer({
    this.activeConversationId,
    required this.onConversationSelected,
    required this.onNewConversation,
  });
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Conversations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: onNewConversation,
                    tooltip: 'New Conversation',
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ConversationSearch(),
            ),
            
            Divider(),
            
            // Conversation list
            Expanded(
              child: Consumer<ConversationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.conversations.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }
                  
                  if (provider.conversations.isEmpty) {
                    return Center(child: Text('No conversations yet'));
                  }
                  
                  return ListView.builder(
                    itemCount: provider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = provider.conversations[index];
                      return ConversationListItem(
                        conversation: conversation,
                        isActive: conversation.id == activeConversationId,
                        onTap: () => onConversationSelected(conversation.id),
                        onDelete: () => provider.deleteConversation(conversation.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Conversation List Item

**Location:** `lib/widgets/conversation/conversation_list_item.dart`

**Purpose:** Individual conversation item with swipe-to-delete

**Interface:**
```dart
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const ConversationListItem({
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });
  
  String get _title {
    // Generate title from first message or use default
    if (conversation.messages.isEmpty) return 'New Conversation';
    
    final firstMessage = conversation.messages.first.content;
    if (firstMessage.length > 50) {
      return firstMessage.substring(0, 50) + '...';
    }
    return firstMessage;
  }
  
  String get _lastMessagePreview {
    if (conversation.messages.isEmpty) return '';
    
    final lastMessage = conversation.messages.last.content;
    if (lastMessage.length > 60) {
      return lastMessage.substring(0, 60) + '...';
    }
    return lastMessage;
  }
  
  String get _timestamp {
    if (conversation.messages.isEmpty) return '';
    
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
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Conversation'),
            content: Text('Are you sure you want to delete this conversation?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        selected: isActive,
        onTap: onTap,
        title: Text(
          _title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(
          _lastMessagePreview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _timestamp,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
```

### 4. Conversation Search

**Location:** `lib/widgets/conversation/conversation_search.dart`

**Purpose:** Search bar for filtering conversations

**Interface:**
```dart
class ConversationSearch extends StatefulWidget {
  const ConversationSearch({super.key});
  
  @override
  State<ConversationSearch> createState() => _ConversationSearchState();
}

class _ConversationSearchState extends State<ConversationSearch> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(Duration(milliseconds: 500), () {
      context.read<ConversationProvider>().searchConversations(query);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search conversations...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onSearchChanged('');
              },
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
```

### 5. Chat Screen Integration

**Location:** `lib/screens/chat/chat_screen.dart` (update)

**Updates Required:**
- Add drawer button to app bar
- Show conversation drawer
- Handle conversation switching
- Update app bar title with conversation title

**Updated App Bar:**
```dart
AppBar(
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
  ),
  title: Text(_getConversationTitle()),
  actions: [
    // ... existing actions
  ],
)
```

**Drawer Integration:**
```dart
Scaffold(
  key: _scaffoldKey,
  appBar: _buildAppBar(),
  drawer: ConversationDrawer(
    activeConversationId: chatProvider.conversationId,
    onConversationSelected: (id) {
      chatProvider.loadConversation(id);
      Navigator.pop(context); // Close drawer
    },
    onNewConversation: () {
      chatProvider.startNewConversation();
      Navigator.pop(context);
    },
  ),
  body: _buildBody(),
)
```

## Data Models

### Conversation Model

**Location:** `lib/models/conversation.dart` (already exists)

Ensure it includes:
- Conversation ID
- Messages list
- Created/updated timestamps
- Optional title field

## Testing Strategy

### Widget Tests
- Test ConversationListItem renders correctly
- Test swipe-to-delete works
- Test search filters conversations
- Test drawer opens/closes

### Integration Tests
- Test loading conversations
- Test switching conversations
- Test deleting conversation
- Test search functionality
- Test pagination

### Manual Tests
- Create multiple conversations
- Switch between conversations
- Delete conversation
- Search for conversation
- Test pull-to-refresh

## Implementation Notes

### Phase 1: Provider and Models (Day 1)
- Create ConversationProvider
- Test state management

### Phase 2: UI Components (Day 2)
- Create ConversationDrawer
- Create ConversationListItem
- Create ConversationSearch

### Phase 3: Integration (Day 2-3)
- Update ChatScreen with drawer
- Test conversation switching
- Test all features

## Dependencies

```yaml
dependencies:
  intl: ^0.18.0  # For date formatting
```
