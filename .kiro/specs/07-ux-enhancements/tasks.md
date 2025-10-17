# Implementation Plan

- [ ] 1. Create Suggested Queries Widget
  - Create `lib/widgets/chat/suggested_queries.dart`
  - Define defaultSuggestions list with 6 common queries
  - Implement _buildQueryChip() method to create tappable query chips
  - Add onQuerySelected callback to send query as message
  - Style chips with border and rounded corners
  - Add arrow icon to indicate tappability
  - Test query selection
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 2. Create Enhanced Empty State Widget
  - Create `lib/widgets/chat/enhanced_empty_state.dart`
  - Display app logo/icon
  - Show welcome message with user name if available
  - Add "I'm your AI rental assistant" subtitle
  - List key features (Find properties, List property, Calculate affordability, Get neighborhood info)
  - Integrate SuggestedQueries widget
  - Style with proper spacing and hierarchy
  - Test empty state display
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 3. Update Chat Screen with Enhanced Empty State
  - Update `lib/screens/chat/chat_screen.dart` to use EnhancedEmptyState
  - Show EnhancedEmptyState when messages list is empty
  - Pass user name from auth provider
  - Pass onQuerySelected callback to send message
  - Test empty state appears correctly
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 4. Create Shimmer Widget
  - Create `lib/widgets/common/shimmer_widget.dart`
  - Implement shimmer animation using AnimationController
  - Create ShaderMask with LinearGradient for shimmer effect
  - Add enabled parameter to toggle shimmer on/off
  - Test shimmer animation
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 5. Create Skeleton Screen Widgets
  - Create ShimmerPropertyCard for property loading state
  - Create ShimmerMessageBubble for message loading state
  - Create ShimmerConversationList for conversation list loading state
  - Use ShimmerWidget to wrap skeleton content
  - Test skeleton screens
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 6. Integrate Shimmer Loading States
  - Update property card list to show ShimmerPropertyCard while loading
  - Update message list to show ShimmerMessageBubble while streaming
  - Update conversation list to show ShimmerConversationList while loading
  - Test smooth transition from shimmer to actual content
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 7. Create Theme Provider
  - Create `lib/providers/theme_provider.dart` with ChangeNotifier
  - Add _themeMode state variable (default: ThemeMode.system)
  - Implement _loadThemeMode() to load saved preference from SharedPreferences
  - Implement setThemeMode() to update theme and persist preference
  - Implement toggleTheme() to switch between light and dark
  - Add isDarkMode getter
  - Test theme switching
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 8. Integrate Theme Provider into App
  - Update `lib/main.dart` to add ThemeProvider to MultiProvider
  - Update MaterialApp to use themeMode from ThemeProvider
  - Test theme changes apply to entire app
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 9. Add Theme Toggle to Settings
  - Create settings screen or add to existing settings
  - Add theme toggle switch or radio buttons (Light/Dark/System)
  - Connect to ThemeProvider.setThemeMode()
  - Test theme toggle in settings
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 10. Create Enhanced Error State Widget
  - Create `lib/widgets/common/error_state.dart`
  - Define ErrorType enum (network, auth, server, validation, unknown)
  - Display appropriate icon based on error type
  - Show error message
  - Add "Try Again" button if onRetry callback provided
  - Add "Dismiss" button if onDismiss callback provided
  - Test with different error types
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 11. Update Error Handling Throughout App
  - Replace basic error displays with ErrorState widget
  - Categorize errors by type (network, auth, server, validation)
  - Add retry callbacks where appropriate
  - Test error states in various scenarios
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 12. Create Haptic Feedback Helper
  - Create `lib/utils/haptic_helper.dart`
  - Define HapticType enum (light, medium, heavy, selection)
  - Implement trigger() method to call appropriate HapticFeedback method
  - Add convenience methods (onButtonPress, onSuccess, onError, onSelection)
  - Test haptic feedback on real device
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 13. Add Haptic Feedback to Interactions
  - Add haptic feedback to button presses (light)
  - Add haptic feedback to successful actions (medium)
  - Add haptic feedback to errors (heavy)
  - Add haptic feedback to selections (selection)
  - Test haptic feedback feels appropriate
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 14. Create Message Send Animation
  - Create `lib/widgets/chat/animated_message_bubble.dart`
  - Implement slide and fade animation for new messages
  - Use AnimationController with SlideTransition and FadeTransition
  - Set duration to 300ms with easeOut curve
  - Test animation smoothness
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 15. Add Animations Throughout App
  - Add message send animation to new messages
  - Add tool result reveal animation
  - Add page transition animations
  - Add button press animations (scale down slightly)
  - Add success animations (checkmark with scale)
  - Test all animations are smooth (60fps)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 16. Implement Accessibility Improvements
  - Add Semantics labels to all interactive elements
  - Verify color contrast meets WCAG AA (4.5:1 for normal text)
  - Ensure all touch targets are at least 48x48 pixels
  - Add visible focus indicators for keyboard navigation
  - Test with screen reader (TalkBack on Android, VoiceOver on iOS)
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 17. Implement Performance Optimizations
  - Add image caching using cached_network_image package
  - Optimize list views with ListView.builder
  - Implement lazy loading for long lists
  - Debounce search input (500ms delay)
  - Dispose controllers properly in all widgets
  - Test scrolling performance (should maintain 60fps)
  - Test memory usage with large message lists
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 18. End-to-End UX Testing
  - Test suggested queries on empty state
  - Test shimmer loading states appear and transition smoothly
  - Test theme toggle switches between light and dark
  - Test enhanced error states display correctly
  - Test haptic feedback on various interactions
  - Test animations are smooth and not jarring
  - Test accessibility with screen reader
  - Test performance with large data sets
  - Verify app feels polished and responsive
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 9.4, 9.5_
