# Spec 04 Update Notes

## What Changed

**Original Spec:** "Payment Status Polling System"  
**Updated Spec:** "Contact Info Request Flow & UI"

## Why the Change?

After reviewing the actual backend implementation (`zena/lib/tools/enhanced-contact-tool.ts`), we discovered that **payment polling is handled entirely by the backend**, not the mobile app.

## Backend Implementation (Already Complete ✅)

The `enhancedRequestContactInfoTool` handles:

1. ✅ Property availability check
2. ✅ User authentication validation
3. ✅ Phone number validation
4. ✅ STK push payment initiation
5. ✅ **Payment status monitoring** (polls M-Pesa every 3s for up to 30s)
6. ✅ Contact info delivery on success
7. ✅ WhatsApp notifications to owner and user
8. ✅ Error handling and cleanup

**Key Code (lines 196-396 in enhanced-contact-tool.ts):**
```typescript
// Step 7: Initiate M-Pesa payment and monitor status internally
const paymentAmount = property.commission_amount

// Initiate STK push
const stkResult = await initiateSTKPush({ ... })

// Step 8: Monitor payment status internally
const paymentResult = await monitorPaymentStatus(
  stkResult.CheckoutRequestID,
  property,
  userPhone,
  user,
  supabaseClient
)

return paymentResult
```

**The `monitorPaymentStatus` function (lines 398-end):**
- Polls M-Pesa status every 3 seconds
- Maximum 10 attempts (30 seconds total)
- Handles success (ResultCode 0)
- Handles cancellation (ResultCode 1, 1032, 1037)
- Handles failure (ResultCode 2001-2003)
- Handles timeout (no response after 30s)
- Sends WhatsApp notifications automatically
- Returns final result to mobile app

## What This Means for Mobile App

### ❌ What We DON'T Need (Originally Planned)
- ~~Payment polling service~~
- ~~Payment status API calls~~
- ~~Countdown timer~~
- ~~Background polling service~~
- ~~Real-time status updates~~
- ~~Payment state management~~

### ✅ What We DO Need (Much Simpler!)
1. **Phone Confirmation Card** - Display phone from profile with Yes/No buttons
2. **Phone Input Card** - Ask for phone if not in profile
3. **Contact Info Card** - Display contact details on success
4. **Payment Error Card** - Display error with retry button
5. **Tool Result Routing** - Route to correct card based on tool result

## Tool Result Flows

### Flow 1: Phone Confirmation Needed
**Backend returns:**
```json
{
  "success": false,
  "needsPhoneConfirmation": true,
  "message": "I can see you have +254712345678 on file...",
  "userPhoneFromProfile": "+254712345678",
  "property": { ... }
}
```
**Mobile displays:** Phone confirmation card with buttons

### Flow 2: Phone Number Needed
**Backend returns:**
```json
{
  "success": false,
  "needsPhoneNumber": true,
  "message": "Please provide your phone number...",
  "property": { ... }
}
```
**Mobile displays:** Phone input prompt

### Flow 3: Payment Success (After Internal Polling)
**Backend returns:**
```json
{
  "success": true,
  "message": "Payment successful!...",
  "contactInfo": {
    "phone": "+254712345678",
    "email": "owner@example.com",
    "propertyTitle": "2BR Apartment",
    "agentPhone": "+254712345678",
    "videoUrl": "https://..."
  },
  "paymentInfo": {
    "amount": 5000,
    "status": "completed",
    "receiptNumber": "..."
  }
}
```
**Mobile displays:** Contact info card with call/WhatsApp buttons

### Flow 4: Payment Failure (After Internal Polling)
**Backend returns:**
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
**Mobile displays:** Error card with retry button

## Effort Reduction

**Original Estimate:** 2-3 days  
**Updated Estimate:** 1-2 days

**Complexity Reduction:**
- No polling service needed
- No background service needed
- No payment state management needed
- Just display tool results!

## Updated Implementation Tasks

### Day 1:
- [ ] Create phone confirmation card
- [ ] Create phone input card
- [ ] Create contact info card
- [ ] Create payment error card

### Day 2:
- [ ] Update tool result factory
- [ ] Test all flows
- [ ] Test with real M-Pesa

## Key Takeaways

1. **Always review backend implementation first** - Don't assume mobile needs to do everything
2. **Backend can handle complex workflows** - Let it do the heavy lifting
3. **Mobile should focus on UI** - Display results, handle user interactions
4. **Simpler is better** - Less code = fewer bugs

## Testing Notes

When testing with real M-Pesa:
- Backend will show "thinking" indicator for up to 30 seconds
- User completes payment on their phone
- Backend monitors status automatically
- Mobile receives final result (success/failure)
- No mobile-side polling needed!

---

**Updated:** October 17, 2025  
**Reason:** Aligned with actual backend implementation  
**Impact:** Reduced complexity and effort by 50%
