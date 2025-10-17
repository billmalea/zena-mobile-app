---
title: UX Enhancements & Polish
priority: LOW
estimated_effort: 2-3 days
status: pending
dependencies: []
---

# UX Enhancements & Polish

## Overview
Add polish and UX improvements to match web app experience. This is LOW PRIORITY - nice to have features that improve user experience but not blocking.

## Current State
- ✅ Basic empty state exists
- ✅ Basic error handling exists
- ❌ No suggested queries
- ❌ No shimmer loading states
- ❌ No theme toggle
- ❌ No animations

## Requirements

### 1. Suggested Queries
Create `lib/widgets/chat/suggested_queries.dart`

**Features:**
- Show 6 suggested queries on empty state
- Contextual suggestions based on user history
- Tap to send query
- Smooth animation on tap
- Refresh suggestions button

**Suggested Queries:**
```dart
const List<String> defaultSuggestions = [
  "Find me a 2-bedroom apartment in Westlands under 50k",
  "I want to list my property",
  "Show me bedsitters near Ngong Road",
  "What's the difference between a bedsitter and studio?",
  "Help me calculate what I can afford",
  "Tell me about Kilimani neighborhood",
];
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  Try asking:                    │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Find me a 2BR in...       │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ I want to list my...      │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

### 2. Shimmer Loading States
Create `lib/widgets/common/shimmer_widget.dart`

**Features:**
- Shimmer effect for loading states
- Property card shimmer
- Message bubble shimmer
- Conversation list shimmer
- Customizable colors and duration

**Usage:**
```dart
// Property card loading
ShimmerPropertyCard()

// Message loading
ShimmerMessageBubble()

// Conversation list loading
ShimmerConversationList(count: 5)
```

### 3. Theme Toggle
Create `lib/providers/theme_provider.dart`

**Features:**
- Light/dark theme toggle
- System theme detection
- Persist theme preference
- Smooth theme transition
- Theme toggle button in settings

**Implementation:**
```dart
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }
}
```

### 4. Enhanced Empty State
Update `lib/widgets/chat/empty_state.dart`

**Features:**
- Welcome message with user name
- App logo/illustration
- Suggested queries
- Feature highlights
- Getting started tips

**UI Layout:**
```
┌─────────────────────────────────┐
│                                 │
│         🏠 Zena                 │
│                                 │
│   Hi [Name]! I'm your AI        │
│   rental assistant.             │
│                                 │
│   I can help you:               │
│   • Find properties             │
│   • List your property          │
│   • Calculate affordability     │
│   • Get neighborhood info       │
│                                 │
│   Try asking:                   │
│   [Suggested Queries]           │
│                                 │
└─────────────────────────────────┘
```

### 5. Enhanced Error States
Update error handling throughout app

**Features:**
- User-friendly error messages
- Error illustrations
- Retry button
- Dismiss button
- Error categorization (network, auth, server, etc.)

**Error Types:**
```dart
enum ErrorType {
  network,      // No internet connection
  auth,         // Authentication failed
  server,       // Server error
  validation,   // Input validation error
  unknown,      // Unknown error
}

class ErrorState {
  final ErrorType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
}
```

### 6. Loading States
Enhance loading indicators throughout app

**Features:**
- Skeleton screens for content loading
- Progress indicators for actions
- Shimmer effects for lists
- Smooth transitions

**Components:**
- `SkeletonPropertyCard`
- `SkeletonMessageBubble`
- `SkeletonConversationList`
- `LoadingOverlay`
- `ProgressButton`

### 7. Animations & Transitions

**Features:**
- Message send animation
- Tool result reveal animation
- Page transitions
- Button press animations
- Success animations
- Error shake animation

**Animations:**
```dart
// Message send animation
AnimatedSlide(
  offset: _isSending ? Offset(0, 0) : Offset(0, 1),
  duration: Duration(milliseconds: 300),
  child: MessageBubble(...),
)

// Success animation
Lottie.asset('assets/animations/success.json')

// Error shake
AnimatedContainer(
  transform: Matrix4.translationValues(_shake ? 10 : 0, 0, 0),
  duration: Duration(milliseconds: 100),
)
```

### 8. Haptic Feedback

**Features:**
- Button press feedback
- Success feedback
- Error feedback
- Selection feedback

**Implementation:**
```dart
import 'package:flutter/services.dart';

void triggerHaptic(HapticFeedbackType type) {
  switch (type) {
    case HapticFeedbackType.light:
      HapticFeedback.lightImpact();
      break;
    case HapticFeedbackType.medium:
      HapticFeedback.mediumImpact();
      break;
    case HapticFeedbackType.heavy:
      HapticFeedback.heavyImpact();
      break;
    case HapticFeedbackType.selection:
      HapticFeedback.selectionClick();
      break;
  }
}
```

### 9. Accessibility Improvements

**Features:**
- Screen reader support
- Semantic labels
- Sufficient color contrast
- Touch target sizes (min 48x48)
- Focus indicators
- Keyboard navigation (desktop)

**Implementation:**
```dart
Semantics(
  label: 'Send message',
  button: true,
  enabled: !isLoading,
  child: IconButton(...),
)
```

### 10. Performance Optimizations

**Features:**
- Image caching
- List view optimization
- Lazy loading
- Memory management
- Debounced search
- Throttled scroll events

## Implementation Tasks

### Phase 1: Suggested Queries & Empty State (Day 1)
- [ ] Create suggested queries widget
- [ ] Update empty state with suggestions
- [ ] Add contextual suggestions
- [ ] Test suggested queries

### Phase 2: Loading States (Day 1-2)
- [ ] Create shimmer widget
- [ ] Create skeleton screens
- [ ] Update loading states throughout app
- [ ] Test loading states

### Phase 3: Theme Toggle (Day 2)
- [ ] Create theme provider
- [ ] Add theme toggle button
- [ ] Persist theme preference
- [ ] Test theme switching

### Phase 4: Animations & Polish (Day 2-3)
- [ ] Add message animations
- [ ] Add success animations
- [ ] Add error animations
- [ ] Add haptic feedback
- [ ] Test animations

### Phase 5: Accessibility & Performance (Day 3)
- [ ] Add semantic labels
- [ ] Improve color contrast
- [ ] Optimize performance
- [ ] Test accessibility

## Testing Checklist

### Widget Tests
- [ ] Suggested queries render
- [ ] Shimmer effects work
- [ ] Theme toggle works
- [ ] Animations play correctly

### Accessibility Tests
- [ ] Screen reader support
- [ ] Color contrast meets WCAG AA
- [ ] Touch targets are 48x48+
- [ ] Focus indicators visible

### Performance Tests
- [ ] Smooth scrolling (60fps)
- [ ] Fast image loading
- [ ] Low memory usage
- [ ] No jank or stuttering

### Manual Tests
- [ ] Suggested queries work
- [ ] Loading states look good
- [ ] Theme switching is smooth
- [ ] Animations are smooth
- [ ] Haptic feedback works
- [ ] Accessibility features work

## Success Criteria
- ✅ Suggested queries help new users
- ✅ Loading states are smooth and polished
- ✅ Theme toggle works seamlessly
- ✅ Animations enhance UX
- ✅ App is accessible to all users
- ✅ Performance is smooth (60fps)

## Dependencies
- Theme provider
- Animation packages (optional: lottie, rive)
- Shimmer package (optional: shimmer)

## Notes
- These are polish features, not blocking
- Prioritize based on user feedback
- Consider using animation packages for complex animations
- Test on real devices for performance
- Accessibility is important for all users

## Reference Files
- Web implementation: `zena/app/chat/page.tsx` (suggested queries, empty state)
- Theme: `zena_mobile_app/lib/config/theme.dart`
