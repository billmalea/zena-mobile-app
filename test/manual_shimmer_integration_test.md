# Manual Shimmer Integration Test Guide

This guide helps you manually verify that shimmer loading states are properly integrated throughout the app.

## Test Environment Setup

1. Ensure the app is built and running on a device or emulator
2. Have a stable internet connection (for testing network-dependent loading states)
3. Clear app data to start fresh (optional)

## Test Cases

### 1. Chat Screen - Message Loading Shimmer

**Objective:** Verify shimmer appears when AI is generating a response

**Steps:**
1. Open the app and navigate to the chat screen
2. Send a message to the AI assistant (e.g., "Find me properties in Westlands")
3. Observe the loading state at the bottom of the message list

**Expected Results:**
- ✅ A typing indicator appears
- ✅ A shimmer message bubble appears below the typing indicator
- ✅ The shimmer effect animates smoothly (gradient moves across the bubble)
- ✅ When the response arrives, the shimmer disappears and is replaced with the actual message
- ✅ The transition from shimmer to content is smooth

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

### 2. Conversation Drawer - List Loading Shimmer

**Objective:** Verify shimmer appears when loading conversation list

**Steps:**
1. Open the app
2. Tap the menu icon (☰) to open the conversation drawer
3. If conversations are already loaded, clear app data and repeat
4. Observe the drawer while conversations are loading

**Expected Results:**
- ✅ Shimmer conversation list items appear (8 skeleton items)
- ✅ Each shimmer item shows placeholder for title, preview, and timestamp
- ✅ The shimmer effect animates smoothly across all items
- ✅ When conversations load, shimmer is replaced with actual conversation items
- ✅ The transition is smooth without flickering

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

### 3. Property Card - Image Loading Shimmer

**Objective:** Verify shimmer appears while property images are loading

**Steps:**
1. Open the app and navigate to the chat screen
2. Send a message that will return property results (e.g., "Show me 2-bedroom apartments")
3. Observe the property cards as they load
4. Pay attention to the image area at the top of each card

**Expected Results:**
- ✅ While images are loading, a shimmer effect appears in the image area
- ✅ The shimmer shows a placeholder icon and "Loading..." text
- ✅ The shimmer effect animates smoothly
- ✅ When the image loads, it replaces the shimmer smoothly
- ✅ If image fails to load, an error placeholder appears (no shimmer)

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

### 4. Slow Network Simulation

**Objective:** Verify shimmer states work well on slow connections

**Steps:**
1. Enable network throttling on your device/emulator (simulate slow 3G)
2. Open the app
3. Open the conversation drawer
4. Send a message that returns property results
5. Observe all loading states

**Expected Results:**
- ✅ Shimmer states appear for longer duration
- ✅ Shimmer animation remains smooth even on slow network
- ✅ No UI freezing or stuttering
- ✅ Transitions still work smoothly when content arrives

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

### 5. Multiple Shimmer States Simultaneously

**Objective:** Verify multiple shimmer effects can run at the same time

**Steps:**
1. Open the app with no conversations loaded
2. Open the conversation drawer (shimmer list appears)
3. While drawer is open, send a message from the chat screen
4. Observe both shimmer states

**Expected Results:**
- ✅ Both shimmer effects (conversation list and message bubble) animate smoothly
- ✅ No performance degradation
- ✅ Both transitions work correctly when content loads

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

### 6. Empty State vs Loading State

**Objective:** Verify shimmer only appears during loading, not for empty states

**Steps:**
1. Clear all conversations
2. Open the conversation drawer
3. Wait for loading to complete
4. Observe the empty state

**Expected Results:**
- ✅ During loading: Shimmer conversation list appears
- ✅ After loading completes with no conversations: Empty state message appears (no shimmer)
- ✅ Empty state shows "No conversations yet" with icon
- ✅ No shimmer effect in empty state

**Pass/Fail:** ___________

**Notes:**
_________________________________________________________________

---

## Performance Checks

### Animation Smoothness
- [ ] All shimmer animations run at 60fps (no stuttering)
- [ ] Scrolling remains smooth while shimmer is active
- [ ] No memory leaks (app doesn't slow down over time)

### Visual Quality
- [ ] Shimmer gradient is smooth and pleasant
- [ ] Shimmer speed is appropriate (not too fast or slow)
- [ ] Shimmer colors match the app theme
- [ ] Skeleton layouts match actual content layouts

### Accessibility
- [ ] Screen readers announce loading states appropriately
- [ ] Shimmer doesn't interfere with accessibility features
- [ ] Loading states are perceivable by users with visual impairments

---

## Summary

**Total Tests:** 6
**Passed:** ___________
**Failed:** ___________

**Overall Assessment:** ___________

**Issues Found:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Recommendations:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Test Completion

**Tester Name:** ___________________
**Date:** ___________________
**Device/Emulator:** ___________________
**OS Version:** ___________________
**App Version:** ___________________

