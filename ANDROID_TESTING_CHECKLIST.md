# Android Device Testing Checklist

## Device Information
- **Device Model:** SM A155F
- **Android Version:** Android 14 (API 34)
- **Build:** app-debug.apk
- **Test Date:** {{ Current Date }}

---

## Test Scenarios

### ✅ 1. Google Sign In Flow (Requirement 1)

**Test Steps:**
1. Open the app
2. Verify welcome screen displays with "Sign in with Google" button
3. Tap "Sign in with Google" button
4. Verify Google account picker appears
5. Select a Google account
6. Verify authentication completes successfully
7. Verify app navigates to chat screen
8. Close and reopen app
9. Verify user remains signed in (auto-login)

**Expected Results:**
- [ ] Welcome screen displays correctly
- [ ] Google Sign In button is visible and tappable
- [ ] Google account picker appears
- [ ] Authentication succeeds
- [ ] Navigation to chat screen occurs
- [ ] Session persists across app restarts

**Issues Found:**
_Document any issues here_

---

### ✅ 2. Chat Messaging and Streaming (Requirements 2, 4)

**Test Steps:**
1. From chat screen, type a message: "Hello, I'm looking for a 2-bedroom apartment in Nairobi"
2. Tap send button
3. Verify user message appears immediately on the right side
4. Verify typing indicator appears
5. Verify AI response streams in real-time (text appears incrementally)
6. Verify typing indicator disappears when response completes
7. Send another message: "What's the price range?"
8. Verify conversation continues correctly

**Expected Results:**
- [ ] User messages appear instantly
- [ ] User messages are right-aligned with emerald background
- [ ] Typing indicator shows during AI response
- [ ] AI responses stream in real-time
- [ ] AI messages are left-aligned with white background
- [ ] Conversation history is maintained
- [ ] Auto-scroll to bottom works

**Issues Found:**
_Document any issues here_

---

### ✅ 3. Property Card Display (Requirement 3)

**Test Steps:**
1. Send message: "Show me available properties in Westlands"
2. Wait for AI to call searchProperties tool
3. Verify property cards display in the chat
4. Check each property card shows:
   - Property image
   - Title
   - Location
   - Bedrooms count
   - Bathrooms count
   - Property type
   - Rent amount (formatted as KSh X,XXX)
5. Verify images load correctly
6. Tap on a property card
7. Verify contact button works

**Expected Results:**
- [ ] Property cards render correctly
- [ ] All property information displays
- [ ] Images load and display
- [ ] Currency formatting is correct (KSh)
- [ ] Cards are tappable
- [ ] Layout is responsive

**Issues Found:**
_Document any issues here_

---

### ✅ 4. File Attachments (Requirement 6)

**Test Steps:**
1. Tap the attach button (paperclip icon)
2. Verify options appear: Camera / Gallery
3. Select "Gallery"
4. Choose an image from gallery
5. Verify image preview appears
6. Type a message: "Here's a photo of the property I'm interested in"
7. Tap send
8. Verify file uploads (progress indicator shows)
9. Verify message sends with attached image
10. Repeat with camera option

**Expected Results:**
- [ ] Attach button is visible and works
- [ ] Camera and gallery options appear
- [ ] Gallery picker opens correctly
- [ ] Camera opens correctly (if tested)
- [ ] Image preview displays
- [ ] Upload progress shows
- [ ] Message sends with attachment
- [ ] Attached images display in chat

**Issues Found:**
_Document any issues here_

---

### ✅ 5. Error Scenarios (Requirement 8)

**Test Steps:**

**5a. Network Error:**
1. Turn off WiFi and mobile data
2. Try to send a message
3. Verify error message displays: "No internet connection"
4. Turn network back on
5. Verify retry works

**5b. Authentication Error:**
1. Sign out from the app
2. Try to access chat (if possible)
3. Verify redirect to login

**5c. Streaming Error:**
1. Send a message
2. Turn off network mid-response
3. Verify partial content shows
4. Verify error message displays
5. Verify retry option available

**Expected Results:**
- [ ] Network errors show clear message
- [ ] Authentication errors handled gracefully
- [ ] Streaming errors show partial content
- [ ] Retry buttons work
- [ ] Error messages are user-friendly

**Issues Found:**
_Document any issues here_

---

### ✅ 6. Performance (Requirement 9)

**Test Observations:**
1. App launch time: _____ seconds (should be < 2s)
2. Message send responsiveness: _____ ms (should be < 100ms)
3. Scrolling smoothness: Smooth / Laggy
4. Image loading speed: Fast / Slow
5. Memory usage: Check in device settings
6. Battery drain: Normal / High

**Expected Results:**
- [ ] App launches within 2 seconds
- [ ] Messages appear instantly
- [ ] Scrolling is smooth (>50 FPS)
- [ ] Images load quickly
- [ ] Memory usage < 200MB
- [ ] No excessive battery drain

**Issues Found:**
_Document any issues here_

---

### ✅ 7. Platform Integration (Requirement 10)

**Test Steps:**
1. Verify app icon displays correctly
2. Verify splash screen shows
3. Test app backgrounding (press home button)
4. Reopen app from recent apps
5. Verify state is preserved
6. Test deep link: Open `zena://auth-callback` (if possible)
7. Check permissions:
   - Camera permission requested when needed
   - Gallery permission requested when needed

**Expected Results:**
- [ ] App icon is correct
- [ ] Splash screen displays
- [ ] App backgrounds correctly
- [ ] State persists when backgrounded
- [ ] Deep links work
- [ ] Permission dialogs are appropriate
- [ ] Follows Android design patterns

**Issues Found:**
_Document any issues here_

---

### ✅ 8. UI/UX Design (Requirement 7)

**Visual Inspection:**
1. Verify emerald/teal color scheme
2. Verify Inter font is used
3. Check Material 3 design elements
4. Test keyboard behavior (input stays visible)
5. Test on different orientations (portrait/landscape)
6. Check button feedback (ripple effects)
7. Verify loading indicators

**Expected Results:**
- [ ] Colors match design (emerald/teal)
- [ ] Typography is correct (Inter font)
- [ ] Material 3 design is evident
- [ ] Keyboard doesn't hide input
- [ ] Responsive to orientation changes
- [ ] Buttons provide visual feedback
- [ ] Loading states are clear

**Issues Found:**
_Document any issues here_

---

## Overall Test Summary

### Test Results
- **Total Tests:** 8 categories
- **Passed:** ___
- **Failed:** ___
- **Blocked:** ___

### Critical Issues
_List any critical issues that prevent core functionality_

### Minor Issues
_List any minor issues or improvements_

### Recommendations
_Any recommendations for improvements or fixes_

---

## Sign Off

**Tested By:** _______________
**Date:** _______________
**Status:** ✅ Pass / ❌ Fail / ⚠️ Pass with Issues

---

## Notes

- This checklist covers Requirements 1, 2, 3, 4, 6, 8, 10 as specified in task 10.2
- All tests should be performed on the physical Android device (SM A155F)
- Document all issues with screenshots if possible
- Retest any failed scenarios after fixes are applied
