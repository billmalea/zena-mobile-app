---
title: Contact Info Request Flow & UI
priority: HIGH
estimated_effort: 1-2 days
status: pending
dependencies: [02-tool-result-rendering]
---

# Contact Info Request Flow & UI

> **⚠️ IMPORTANT:** This spec has been updated based on actual backend implementation. The backend handles ALL payment polling internally - the mobile app only needs to display tool results. Much simpler than originally planned!

## Overview
Implement UI for the contact info request flow. Payment polling is handled **internally by the backend** (`enhancedRequestContactInfoTool`) - the mobile app just needs to display the tool results correctly. This is HIGH PRIORITY - users cannot complete property contact requests without proper UI.

**What the backend does automatically:**
- ✅ Initiates M-Pesa STK push
- ✅ Polls payment status every 3 seconds for up to 30 seconds
- ✅ Sends WhatsApp notifications to owner and user
- ✅ Returns final result (success/failure) after monitoring

**What the mobile app needs to do:**
- Display phone confirmation UI
- Display contact info on success
- Display error messages on failure
- Handle retry button clicks

## Current State
- ✅ Backend handles payment polling internally (no mobile polling needed)
- ❌ No phone confirmation UI
- ❌ No payment status display
- ❌ No contact info display
- ✅ Basic tool result structure exists

## Backend Implementation (Already Done ✅)

The `enhancedRequestContactInfoTool` in the backend handles:
1. ✅ Property availability check
2. ✅ User authentication validation
3. ✅ Phone number validation
4. ✅ STK push payment initiation
5. ✅ **Payment status monitoring (polls every 3s for 30s)**
6. ✅ Contact info delivery on success
7. ✅ WhatsApp notifications to owner and user
8. ✅ Error handling and cleanup

**The mobile app does NOT need to poll** - the backend tool returns the final result after monitoring internally.

## Requirements

### 1. Understanding the Tool Flow

The `requestContactInfo` tool has **3 possible flows**:

#### Flow 1: Phone Confirmation Needed
**Backend returns:**
```json
{
  "success": false,
  "needsPhoneConfirmation": true,
  "message": "I can see you have +254712345678 on file. Should I proceed with this number?",
  "userPhoneFromProfile": "+254712345678",
  "property": { ... }
}
```

**Mobile should display:** Phone confirmation card with "Yes" and "No" buttons

#### Flow 2: Phone Number Needed
**Backend returns:**
```json
{
  "success": false,
  "needsPhoneNumber": true,
  "message": "Please provide your phone number to proceed with the payment.",
  "property": { ... }
}
```

**Mobile should display:** Phone input prompt

#### Flow 3: Payment Processing & Result
**Backend returns (after internal polling):**
```json
{
  "success": true,
  "message": "Payment successful! The property agent is now contacting you.",
  "contactInfo": {
    "phone": "+254712345678",
    "email": "owner@example.com",
    "propertyTitle": "2BR Apartment",
    "propertyLocation": "Westlands",
    "rentAmount": 50000,
    "agentPhone": "+254712345678",
    "videoUrl": "https://..."
  },
  "paymentInfo": {
    "amount": 5000,
    "status": "completed",
    "transactionId": "...",
    "receiptNumber": "..."
  }
}
```

**OR on failure:**
```json
{
  "success": false,
  "error": "Payment was cancelled: User cancelled transaction",
  "errorType": "PAYMENT_CANCELLED",
  "property": { ... },
  "paymentInfo": {
    "amount": 5000,
    "status": "cancelled",
    "failureReason": "..."
  }
}
```

**Mobile should display:** Contact info card (success) or error card with retry (failure)

### 2. Phone Confirmation Card
Create `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`

**Features:**
- Display phone number from profile
- "Yes, use this number" button
- "No, use different number" button
- Clear explanation of why phone is needed
- Property details (title, commission amount)

**When to show:** Tool returns `needsPhoneConfirmation: true`

**User actions:**
- Tap "Yes" → Send message: "Yes, please use [phone number] for the payment"
- Tap "No" → Send message: "No, I'll provide a different phone number"

### 3. Phone Input Prompt
Update `lib/widgets/chat/message_bubble.dart` or create dedicated widget

**Features:**
- Text input for phone number
- Phone number validation (Kenyan format)
- Submit button
- Clear instructions

**When to show:** Tool returns `needsPhoneNumber: true`

**User action:**
- Enter phone → Send message with phone number

### 4. Contact Info Card
Create `lib/widgets/chat/tool_cards/contact_info_card.dart`

**Features:**
- Agent/owner name (if available)
- Phone number with "Call" button
- WhatsApp button (opens WhatsApp with number)
- Email (if available)
- Property details (title, location, rent)
- Payment receipt info
- Success message
- Video link (if available)

**When to show:** Tool returns `success: true` with `contactInfo`

### 5. Payment Error Card
Create `lib/widgets/chat/tool_cards/payment_error_card.dart`

**Features:**
- Error message (user-friendly)
- Error type indicator
- "Try Again" button
- Property details
- Payment info (if available)

**When to show:** Tool returns `success: false` with `error`

**Error types to handle:**
- `PAYMENT_CANCELLED` - User cancelled
- `PAYMENT_FAILED` - System error
- `PAYMENT_TIMEOUT` - Verification timeout
- `PAYMENT_PROCESSING_ERROR` - General error

### 6. Tool Result Widget Factory Update
Update `lib/widgets/chat/tool_result_widget.dart`

**Add handling for `requestContactInfo` tool:**
```dart
case 'requestContactInfo':
  return _buildContactInfoResult(context);

Widget _buildContactInfoResult(BuildContext context) {
  final result = toolResult.result;
  
  // Phone confirmation needed
  if (result['needsPhoneConfirmation'] == true) {
    return PhoneConfirmationCard(
      message: result['message'],
      phoneNumber: result['userPhoneFromProfile'],
      property: result['property'],
      onConfirm: () => onSendMessage?.call(
        'Yes, please use ${result['userPhoneFromProfile']} for the payment'
      ),
      onDecline: () => onSendMessage?.call(
        'No, I\'ll provide a different phone number'
      ),
    );
  }
  
  // Phone number needed
  if (result['needsPhoneNumber'] == true) {
    return PhoneInputCard(
      message: result['message'],
      property: result['property'],
      onSubmit: (phone) => onSendMessage?.call(
        'My phone number is $phone'
      ),
    );
  }
  
  // Success - show contact info
  if (result['success'] == true && result['contactInfo'] != null) {
    return ContactInfoCard(
      contactInfo: result['contactInfo'],
      paymentInfo: result['paymentInfo'],
      message: result['message'],
      alreadyPaid: result['alreadyPaid'] ?? false,
    );
  }
  
  // Error - show error card
  if (result['success'] == false && result['error'] != null) {
    return PaymentErrorCard(
      error: result['error'],
      errorType: result['errorType'],
      property: result['property'],
      paymentInfo: result['paymentInfo'],
      onRetry: () => onSendMessage?.call(
        'Please try the payment again'
      ),
    );
  }
  
  return SizedBox.shrink();
}
```

## Implementation Tasks

### Phase 1: Phone Confirmation Card (Day 1)
- [ ] Create `phone_confirmation_card.dart`
- [ ] Display phone number from profile
- [ ] Add "Yes" and "No" buttons
- [ ] Handle button clicks
- [ ] Test phone confirmation flow

### Phase 2: Phone Input & Contact Info Cards (Day 1)
- [ ] Create `phone_input_card.dart` (or update message bubble)
- [ ] Add phone number validation
- [ ] Create `contact_info_card.dart`
- [ ] Display contact details with call/WhatsApp buttons
- [ ] Test contact info display

### Phase 3: Payment Error Card (Day 1-2)
- [ ] Create `payment_error_card.dart`
- [ ] Handle different error types
- [ ] Add retry button
- [ ] Test error scenarios

### Phase 4: Tool Result Factory Integration (Day 2)
- [ ] Update `tool_result_widget.dart`
- [ ] Add `requestContactInfo` case handling
- [ ] Route to correct card based on result
- [ ] Test all flows

### Phase 5: End-to-End Testing (Day 2)
- [ ] Test phone confirmation flow
- [ ] Test phone input flow
- [ ] Test successful payment (with real M-Pesa)
- [ ] Test cancelled payment
- [ ] Test failed payment
- [ ] Test timeout scenario
- [ ] Test retry functionality

## Testing Checklist

### Widget Tests
- [ ] Phone confirmation card renders correctly
- [ ] Phone confirmation buttons work
- [ ] Phone input validates correctly
- [ ] Contact info card displays all fields
- [ ] Call/WhatsApp buttons work
- [ ] Error card shows correct error type
- [ ] Retry button works

### Integration Tests
- [ ] Tool result routes to correct card
- [ ] Phone confirmation flow works
- [ ] Phone input flow works
- [ ] Contact info displays after success
- [ ] Error card displays on failure
- [ ] Retry sends correct message

### Manual Tests (Real M-Pesa Required)
- [ ] Request contact info (first time)
- [ ] See phone confirmation card
- [ ] Confirm phone number
- [ ] Complete M-Pesa payment on phone
- [ ] See contact info card with details
- [ ] Call button opens phone dialer
- [ ] WhatsApp button opens WhatsApp
- [ ] Cancel payment on phone
- [ ] See error card with retry
- [ ] Retry payment works
- [ ] Test with no phone in profile
- [ ] Test with invalid phone number

## Success Criteria
- ✅ Phone confirmation UI displays correctly
- ✅ Users can confirm or decline phone number
- ✅ Phone input validates Kenyan numbers
- ✅ Contact info displays after successful payment
- ✅ Call and WhatsApp buttons work
- ✅ Error messages are user-friendly
- ✅ Retry button re-initiates payment
- ✅ All flows work with real M-Pesa

## Dependencies
- Tool result rendering system (Spec 02)
- Message sending capability
- Phone number validation
- URL launcher for call/WhatsApp buttons

## Notes
- **Backend handles all payment polling** - mobile just displays results
- Payment monitoring takes up to 30 seconds (backend polls every 3s for 10 attempts)
- Users will see a "thinking" indicator while backend processes payment
- Error messages are already cleaned by backend (no HTML/technical errors)
- WhatsApp notifications are sent automatically by backend
- Property video is sent to user via WhatsApp automatically

## Key Differences from Original Spec
- ❌ **NO mobile-side polling needed** - backend does it all
- ❌ **NO payment status API calls** - tool returns final result
- ❌ **NO countdown timer** - backend handles timeout
- ❌ **NO background service** - not needed
- ✅ **Just display tool results** - much simpler!

## Reference Files
- Backend tool: `zena/lib/tools/enhanced-contact-tool.ts` (complete implementation)
- Tool flow: Lines 23-42 (phone confirmation), 196-396 (payment processing)
- Web UI: `zena/components/chat/tool-results/` (for UI patterns)
