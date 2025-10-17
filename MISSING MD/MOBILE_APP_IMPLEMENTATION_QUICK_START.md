# ZENA MOBILE APP - QUICK START IMPLEMENTATION GUIDE

## 🚀 Priority 1: File Upload (3-4 days)

### Files to Create:
1. `lib/widgets/chat/file_upload_widget.dart` - File picker UI
2. `lib/services/file_upload_service.dart` - Upload logic
3. Update `lib/services/api_service.dart` - Add multipart support

### Key Changes:
```dart
// In MessageInput widget, add file upload button
IconButton(
  icon: Icon(Icons.attach_file),
  onPressed: () => _showFileUploadSheet(),
)

// In ChatProvider, handle file uploads
Future<void> sendMessageWithFiles(String text, List<File> files) async {
  // Convert files to data URLs
  // Upload to Supabase Storage
  // Send message with file URLs
}
```

### Testing:
- [ ] Can pick video from camera
- [ ] Can pick video from gallery
- [ ] File preview works
- [ ] Upload progress shows
- [ ] Files upload to Supabase
- [ ] Message sends with file URLs

---

## 🎨 Priority 2: Tool Result Cards (4-5 days)

### Files to Create:
1. `lib/widgets/chat/tool_result_widget.dart` - Main factory
2. `lib/widgets/chat/tool_cards/property_card.dart` - Enhanced
3. `lib/widgets/chat/tool_cards/payment_status_card.dart`
4. `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`
5. `lib/widgets/chat/tool_cards/contact_info_card.dart`
6. `lib/widgets/chat/tool_cards/property_submission_card.dart`
7. `lib/widgets/chat/tool_cards/property_data_card.dart`
8. `lib/widgets/chat/tool_cards/missing_fields_card.dart`
9. `lib/widgets/chat/tool_cards/final_review_card.dart`
10. `lib/widgets/chat/tool_cards/no_properties_found_card.dart`

### Key Pattern:
```dart
// In MessageBubble, render tool results
if (message.hasToolResults) {
  ...message.toolResults!.map((toolResult) {
    return ToolResultWidget(
      toolResult: toolResult,
      onSendMessage: (text) => _sendMessage(text),
    );
  }),
}
```

### Testing:
- [ ] Property cards display correctly
- [ ] Payment cards show status
- [ ] Confirmation buttons work
- [ ] All tool types render
- [ ] Interactive elements work

---

## 🔄 Priority 3: Multi-Turn Workflows (3-4 days)

### Files to Create:
1. `lib/services/submission_state_manager.dart` - State tracking
2. `lib/models/submission_state.dart` - State model
3. Update `lib/providers/chat_provider.dart` - Add state management

### Key Changes:
```dart
// Track submission state
class ChatProvider {
  final SubmissionStateManager _stateManager;
  String? _currentSubmissionId;
  
  void startSubmission() {
    final state = _stateManager.createNew(userId);
    _currentSubmissionId = state.submissionId;
  }
  
  void updateSubmissionStage(String stage) {
    // Update state and persist
  }
}
```

### Testing:
- [ ] State persists between messages
- [ ] Stages progress correctly
- [ ] Data carries forward
- [ ] State clears on completion
- [ ] Multiple submissions work

---

## 💳 Priority 4: Payment Polling (2-3 days)

### Files to Create:
1. `lib/services/payment_polling_service.dart` - Polling logic
2. Update `lib/widgets/chat/tool_cards/payment_status_card.dart` - Add polling

### Key Changes:
```dart
class PaymentPollingService {
  Stream<PaymentStatus> pollPaymentStatus(String checkoutRequestId) async* {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(seconds: 3));
      final status = await _checkStatus(checkoutRequestId);
      yield status;
      if (status.isComplete) break;
    }
  }
}
```

### Testing:
- [ ] Polling starts automatically
- [ ] Status updates in real-time
- [ ] Success shows contact info
- [ ] Failure shows retry
- [ ] Timeout handled gracefully

---

## 📋 Quick Implementation Checklist

### Week 1: File Upload + Basic Tool Cards
- [ ] Day 1-2: File upload widget
- [ ] Day 3: Supabase Storage integration
- [ ] Day 4: Property card enhancement
- [ ] Day 5: Payment status card

### Week 2: Remaining Tool Cards + Workflows
- [ ] Day 1-2: Phone confirmation + contact info cards
- [ ] Day 3: Property submission cards
- [ ] Day 4: Submission state manager
- [ ] Day 5: Workflow integration

### Week 3: Payment + Polish
- [ ] Day 1-2: Payment polling service
- [ ] Day 3: Integration testing
- [ ] Day 4-5: Bug fixes + polish

---

## 🔧 Development Tips

### 1. Start Small
- Implement one tool card at a time
- Test each card independently
- Don't move on until it works

### 2. Reuse Web Logic
- Copy tool result structures from web
- Match UI patterns from web
- Use same error handling

### 3. Test on Real Device
- File upload needs real device
- M-Pesa needs real phone
- Camera needs real camera

### 4. Handle Errors Gracefully
- Show user-friendly messages
- Provide retry options
- Log errors for debugging

### 5. Keep State Simple
- Use Provider for UI state
- Use SharedPreferences for persistence
- Don't over-engineer

---

## 📱 Testing Strategy

### Unit Tests
- Test state management
- Test file conversion
- Test data parsing

### Widget Tests
- Test each tool card
- Test file upload UI
- Test message rendering

### Integration Tests
- Test complete flows
- Test payment flow
- Test submission flow

### Manual Tests
- Test on Android
- Test on iOS
- Test with real M-Pesa

---

## 🎯 Success Criteria

### Must Have (Phase 1)
- ✅ File upload works
- ✅ Property cards display
- ✅ Payment flow works
- ✅ Submission workflow works

### Should Have (Phase 2)
- ✅ All tool cards render
- ✅ Conversation switching
- ✅ Message persistence

### Nice to Have (Phase 3)
- ✅ Suggested queries
- ✅ Theme toggle
- ✅ Shimmer loading

---

## 🚨 Common Pitfalls

1. **Don't skip file upload** - Everything depends on it
2. **Don't hardcode tool results** - Use factory pattern
3. **Don't forget state persistence** - Users will lose data
4. **Don't ignore payment timeout** - Handle gracefully
5. **Don't skip testing** - Bugs will compound

---

## 📞 Need Help?

Refer to:
- `ZENA_CHAT_SYSTEM_ANALYSIS.md` - Complete analysis
- Web implementation in `zena/app/chat/`
- Tool implementations in `zena/lib/tools/`
- Existing mobile code in `zena_mobile_app/lib/`

---

**Ready to start? Begin with Priority 1: File Upload!**
