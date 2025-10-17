---
title: Conversation Management Enhancement
priority: MEDIUM
estimated_effort: 2-3 days
status: pending
dependencies: []
---

# Conversation Management Enhancement

## Overview
Enhance conversation management with list view, switching, search, and persistence. This is MEDIUM PRIORITY - improves UX but not blocking core functionality.

## Current State
- ✅ Basic conversation creation works
- ✅ Basic conversation loading works
- ❌ No conversation list UI
- ❌ No conversation switching
- ❌ No conversation search
- ❌ No conversation deletion
- ❌ No conversation history display

## Requirements

### 1. Conversation List Screen
Create `lib/screens/conversation/conversation_list_screen.dart`

**Features:**
- Display all user conversations
- Show last message preview
- Show timestamp (relative: "2 hours ago")
- Show unread indicator (optional)
- Pull to refresh
- Empty state for no conversations
- Loading state
- Error state

**UI Layout:**
```
┌─────────────────────────────────┐
│ Conversations            [+]    │
├─────────────────────────────────┤
│ 🏠 Property Search              │
│    Found 3 properties in...     │
│    2 hours ago              →   │
├─────────────────────────────────┤
│ 💰 Contact Request              │
│    Payment successful! Here...  │
│    Yesterday                →   │
├─────────────────────────────────┤
│ 📝 Property Submission          │
│    Your property has been...    │
│    2 days ago               →   │
└─────────────────────────────────┘
```

### 2. Conversation List Widget
Create `lib/widgets/conversation/conversation_list_item.dart`

**Features:**
- Conversation title (auto-generated or custom)
- Last message preview (truncated to 2 lines)
- Timestamp with relative formatting
- Unread badge (optional)
- Swipe to delete
- Tap to open conversation

### 3. Conversation Drawer
Create `lib/widgets/conversation/conversation_drawer.dart`

**Features:**
- Slide-out drawer from left
- Conversation list
- New conversation button
- Search conversations
- Settings button
- User profile section

**Alternative:** Use bottom sheet instead of drawer for mobile-first design

### 4. Conversation Search
Create `lib/widgets/conversation/conversation_search.dart`

**Features:**
- Search bar at top of conversation list
- Search by message content
- Search by date range
- Filter by conversation type (optional)
- Clear search button
- Search results highlighting

### 5. Conversation Service Enhancement
Update `lib/services/chat_service.dart`

**Features:**
- Get all conversations with pagination
- Search conversations
- Delete conversation
- Update conversation title
- Mark conversation as read (optional)

**Methods:**
```dart
Future<List<Conversation>> getConversations({
  int page = 1,
  int limit = 20,
})

Future<List<Conversation>> searchConversations(String query)

Future<void> deleteConversation(String conversationId)

Future<void> updateConversationTitle(
  String conversationId,
  String title,
)
```

### 6. Conversation Provider
Create `lib/providers/conversation_provider.dart`

**Features:**
- Manage conversation list state
- Track active conversation
- Handle conversation switching
- Handle conversation deletion
- Handle conversation search
- Pagination support

**State Management:**
```dart
class ConversationProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  
  List<Conversation> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  
  Future<void> loadConversations({bool refresh = false})
  Future<void> loadMore()
  Future<void> switchConversation(String conversationId)
  Future<void> deleteConversation(String conversationId)
  Future<void> searchConversations(String query)
  void setActiveConversation(String conversationId)
}
```

### 7. Chat Screen Integration
Update `lib/screens/chat/chat_screen.dart`

**Features:**
- Add drawer/menu button to app bar
- Show conversation drawer on tap
- Handle conversation switching
- Update UI when conversation changes
- Show conversation title in app bar

### 8. Conversation Persistence
Update `lib/services/conversation_storage_service.dart`

**Features:**
- Cache conversations locally
- Sync with backend
- Offline support
- Auto-refresh on app start

### 9. Conversation Title Generation

**Features:**
- Auto-generate title from first message
- Extract key topics (property search, submission, etc.)
- Allow user to edit title
- Show default title if empty

**Examples:**
- "Property Search in Westlands"
- "Contact Request for 2BR Apartment"
- "Property Submission - Kilimani"
- "General Inquiry"

## Implementation Tasks

### Phase 1: Conversation List UI (Day 1)
- [ ] Create `conversation_list_screen.dart`
- [ ] Create `conversation_list_item.dart`
- [ ] Create `conversation_drawer.dart`
- [ ] Add empty state
- [ ] Add loading state
- [ ] Test UI rendering

### Phase 2: Conversation Provider (Day 2)
- [ ] Create `conversation_provider.dart`
- [ ] Implement conversation loading
- [ ] Implement conversation switching
- [ ] Implement conversation deletion
- [ ] Add pagination support
- [ ] Test state management

### Phase 3: Integration (Day 2-3)
- [ ] Update chat screen with drawer
- [ ] Integrate conversation provider
- [ ] Handle conversation switching
- [ ] Test end-to-end flow
- [ ] Add conversation search
- [ ] Test search functionality

### Phase 4: Polish (Day 3)
- [ ] Add swipe to delete
- [ ] Add pull to refresh
- [ ] Add conversation title editing
- [ ] Add offline support
- [ ] Test all features

## Testing Checklist

### Widget Tests
- [ ] Conversation list renders
- [ ] Conversation item displays correctly
- [ ] Drawer opens and closes
- [ ] Search bar works
- [ ] Empty state shows

### Integration Tests
- [ ] Load conversations
- [ ] Switch conversations
- [ ] Delete conversation
- [ ] Search conversations
- [ ] Pagination works

### Manual Tests
- [ ] Create multiple conversations
- [ ] Switch between conversations
- [ ] Delete conversation
- [ ] Search for conversation
- [ ] Load more conversations
- [ ] Offline mode works

## Success Criteria
- ✅ Users can view all conversations
- ✅ Users can switch between conversations
- ✅ Users can delete conversations
- ✅ Users can search conversations
- ✅ Conversations persist locally
- ✅ UI is responsive and smooth

## Dependencies
- Conversation API endpoints
- Chat provider for active conversation
- Local storage for caching

## Notes
- Consider using drawer vs bottom sheet for mobile
- Pagination improves performance with many conversations
- Offline support enhances UX
- Auto-generated titles improve discoverability

## Reference Files
- Web implementation: `zena/app/chat/page.tsx` (conversation sidebar)
- Conversation API: `zena/app/api/chat/conversation/route.ts`
