# Manual Offline Testing Guide

This guide helps you manually test the conversation persistence feature.

## Test Scenarios

### 1. Cache Persistence After App Restart

**Steps:**
1. Launch the app and log in
2. Navigate to the conversations list
3. Wait for conversations to load from the backend
4. Close the app completely
5. Restart the app
6. Navigate to conversations list

**Expected Result:**
- Conversations should appear immediately from cache
- A background sync should occur to update with latest data

### 2. Offline Access to Conversations

**Steps:**
1. Launch the app with internet connection
2. Load conversations list
3. Turn off internet connection (airplane mode)
4. Close and restart the app
5. Navigate to conversations list

**Expected Result:**
- Cached conversations should be displayed
- User can view conversation list offline
- May see a message indicating offline mode

### 3. Cache Update on Changes

**Steps:**
1. Launch the app with internet connection
2. Load conversations
3. Delete a conversation
4. Turn off internet
5. Restart the app

**Expected Result:**
- Deleted conversation should not appear in cached list
- Cache was updated when deletion occurred

### 4. Sync When Coming Back Online

**Steps:**
1. Start app in offline mode (airplane mode on)
2. View cached conversations
3. Turn internet back on
4. Pull to refresh or wait a moment

**Expected Result:**
- App should sync with backend
- Any new conversations should appear
- Cache should be updated with latest data

## Debug Output

When running in debug mode, you should see console output like:
- `Loaded X conversations from cache`
- `Saved X conversations to cache`
- `Synced X conversations with backend`
- `Failed to sync with backend: ...` (when offline)
- `Cache expired, will sync with backend`

## Cache Location

The conversations are cached using SharedPreferences with the key:
- `cached_conversations` - JSON array of conversation data
- `conversations_cache_timestamp` - Timestamp of last cache update

Cache expires after 24 hours and will trigger a background sync.
