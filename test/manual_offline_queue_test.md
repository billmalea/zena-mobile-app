# Manual Offline Queue Testing Guide

This guide provides step-by-step instructions for manually testing the offline message queue functionality.

## Prerequisites
- Flutter app installed on a physical device or emulator
- Active internet connection
- Ability to toggle airplane mode or disable network

## Test Scenarios

### Test 1: Detect Offline State When Sending Message

**Steps:**
1. Open the app and navigate to a chat conversation
2. Turn on airplane mode or disable network connection
3. Type a message and send it
4. Observe the behavior

**Expected Results:**
- Message appears in the chat with a "pending" indicator (localOnly flag)
- Error message displays: "You are offline. Message will be sent when connection is restored."
- Message is saved to local storage
- Message is added to the offline queue

**Verification:**
- Check that `chatProvider.isOnline` returns `false`
- Check that `chatProvider.hasQueuedMessages` returns `true`
- Check that `chatProvider.queuedMessageCount` equals `1`

---

### Test 2: Enqueue Message When Offline

**Steps:**
1. Ensure device is offline (airplane mode on)
2. Send multiple messages (3-5 messages)
3. Check the queue status

**Expected Results:**
- All messages appear in the chat with pending indicators
- Each message is saved to local storage with `localOnly: true` and `synced: false`
- Queue count increases with each message
- Error message persists showing offline status

**Verification:**
- Check that `chatProvider.queuedMessageCount` matches the number of sent messages
- Verify messages in local database have `local_only = 1` and `synced = 0`

---

### Test 3: Process Queue When Connection Restored

**Steps:**
1. With queued messages from Test 2, turn off airplane mode
2. Wait for automatic queue processing (or trigger manually)
3. Observe the messages being sent

**Expected Results:**
- Messages are automatically sent to the backend in order
- Each message's `synced` flag is updated to `true`
- `localOnly` flag is updated to `false`
- Queue count decreases to 0
- Error message clears
- Assistant responses appear for each sent message

**Verification:**
- Check that `chatProvider.hasQueuedMessages` returns `false`
- Check that `chatProvider.queuedMessageCount` equals `0`
- Verify messages in database have `synced = 1` and `local_only = 0`

---

### Test 4: Show Pending Indicator for Queued Messages

**Steps:**
1. Go offline and send a message
2. Observe the message in the chat UI
3. Check for visual indicators

**Expected Results:**
- Message displays with a pending/clock icon or similar indicator
- Message text is visible but marked as unsent
- Timestamp shows when message was created locally

**UI Implementation Notes:**
- Use `message.localOnly` flag to show pending indicator
- Use `message.synced` flag to determine if message was sent
- Consider showing a retry button for failed messages

---

### Test 5: Automatic Sending When Online

**Steps:**
1. Start with device offline
2. Send 2-3 messages (they get queued)
3. Turn on network connection
4. Wait 5-10 seconds without any user action

**Expected Results:**
- Queue is automatically processed
- Messages are sent in the background
- UI updates to show messages as sent
- Pending indicators are removed
- Assistant responses appear

**Verification:**
- No user interaction required
- Queue processing happens automatically
- All messages successfully sent

---

### Test 6: Handle Network Errors During Send

**Steps:**
1. Start with device online
2. Begin sending a message
3. Quickly turn off network mid-send
4. Observe error handling

**Expected Results:**
- Network error is detected
- Message is automatically queued
- Error message shows offline status
- Message marked as pending

**Verification:**
- Message appears in queue
- No crash or unhandled exception
- Graceful degradation to offline mode

---

### Test 7: Retry Queued Messages Manually

**Steps:**
1. Have queued messages from offline state
2. Turn on network connection
3. Use pull-to-refresh or retry button
4. Observe queue processing

**Expected Results:**
- Manual trigger initiates queue processing
- Messages are sent immediately
- UI updates in real-time
- Success/failure feedback provided

**Implementation:**
```dart
// In UI code
await chatProvider.retryQueuedMessages();
```

---

### Test 8: Multiple Queued Messages

**Steps:**
1. Go offline
2. Send 10+ messages
3. Go back online
4. Observe batch processing

**Expected Results:**
- All messages are queued successfully
- Queue processes messages in order (FIFO)
- No message loss
- All messages eventually sent
- Performance remains acceptable

**Verification:**
- Check message order in backend
- Verify all messages have correct timestamps
- Confirm no duplicates

---

### Test 9: App Restart with Queued Messages

**Steps:**
1. Go offline and send messages
2. Close the app completely
3. Reopen the app (still offline)
4. Verify queued messages persist
5. Go online
6. Verify automatic sending

**Expected Results:**
- Queued messages survive app restart
- Messages still marked as pending
- Queue count accurate after restart
- Automatic processing when online

**Verification:**
- Messages loaded from local database
- Queue reconstructed from persistence
- No data loss

---

### Test 10: Network Error Types

**Steps:**
Test various network error scenarios:
1. Airplane mode
2. WiFi disabled
3. Mobile data disabled
4. Weak/intermittent connection
5. Server timeout

**Expected Results:**
- All network errors detected correctly
- Appropriate error messages shown
- Messages queued when appropriate
- Retry logic handles different error types

---

## UI Indicators to Implement

### Pending Message Indicator
```dart
// In message bubble widget
if (message.localOnly && !message.synced) {
  // Show pending icon (clock, spinner, etc.)
  Icon(Icons.schedule, size: 16, color: Colors.grey)
}
```

### Queue Status Banner
```dart
// At top of chat screen
if (chatProvider.hasQueuedMessages) {
  Container(
    color: Colors.orange.shade100,
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        Icon(Icons.cloud_off, size: 16),
        SizedBox(width: 8),
        Text('${chatProvider.queuedMessageCount} messages pending'),
        Spacer(),
        TextButton(
          onPressed: () => chatProvider.retryQueuedMessages(),
          child: Text('Retry'),
        ),
      ],
    ),
  )
}
```

### Offline Status Indicator
```dart
// In app bar or status bar
if (!chatProvider.isOnline) {
  Container(
    color: Colors.red,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off, size: 14, color: Colors.white),
        SizedBox(width: 4),
        Text('Offline', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  )
}
```

---

## Troubleshooting

### Messages Not Queuing
- Check that `_offlineQueue` is initialized
- Verify `_persistenceService` is available
- Check for errors in console logs

### Queue Not Processing
- Verify network connectivity restored
- Check `_checkConnectivity()` is being called
- Look for errors in `_processOfflineQueue()`

### Messages Sent Multiple Times
- Verify queue removal logic
- Check `markAsSynced()` is called
- Ensure no duplicate queue entries

---

## Success Criteria

✅ Messages can be sent while offline
✅ Messages are queued automatically
✅ Queue persists across app restarts
✅ Messages send automatically when online
✅ Pending indicators show correctly
✅ No message loss in any scenario
✅ Error messages are clear and helpful
✅ Manual retry works as expected
