# Implementation Plan - Zena Flutter Mobile App

## Task Overview

This implementation plan breaks down the Flutter mobile app development into discrete, manageable tasks. Each task builds incrementally on previous work, following test-driven development principles where appropriate.

**Estimated Total Time:** 3-5 hours  
**Complexity:** Medium  
**Prerequisites:** Flutter SDK installed, backend running, Supabase configured

---

## Implementation Tasks

- [x] 1. Project Setup and Configuration





  - Create Flutter project structure
  - Configure pubspec.yaml with all required dependencies
  - Set up folder structure (config, models, services, providers, screens, widgets)
  - _Requirements: All_

- [x] 1.1 Create configuration files


  - Create lib/config/app_config.dart with API URLs and Supabase credentials
  - Create lib/config/theme.dart with app theme matching web design
  - _Requirements: 7, 13_


- [x] 1.2 Configure platform-specific settings

  - Configure Android deep linking in AndroidManifest.xml
  - Configure iOS deep linking in Info.plist
  - Set up app identifiers and version numbers
  - _Requirements: 1, 10_

- [x] 2. Implement Data Models





  - Create lib/models/message.dart with Message and ToolResult classes
  - Create lib/models/property.dart with Property class and formatting methods
  - Create lib/models/conversation.dart with Conversation class
  - _Requirements: 2, 3, 5_

- [x] 3. Implement Service Layer




  - Services handle all backend communication
  - _Requirements: 12_

- [x] 3.1 Create API service


  - Create lib/services/api_service.dart with singleton pattern
  - Implement _getHeaders() method for authentication
  - Implement post() method for JSON requests
  - Implement get() method for retrieving data
  - Implement streamPost() method for SSE streaming
  - _Requirements: 12_

- [x] 3.2 Create chat service


  - Create lib/services/chat_service.dart
  - Implement sendMessage() method with SSE streaming
  - Implement getConversation() method
  - Implement getConversations() method
  - Implement createConversation() method
  - Create ChatEvent class for stream events
  - _Requirements: 2, 4, 5_

- [x] 3.3 Create authentication service


  - Create lib/services/auth_service.dart with singleton pattern
  - Implement signInWithGoogle() method using Supabase OAuth
  - Implement signOut() method
  - Implement getAccessToken() method
  - Expose authStateChanges stream
  - _Requirements: 1_

- [x] 4. Implement State Management





  - Use Provider pattern for state management
  - _Requirements: 11_

- [x] 4.1 Create authentication provider


  - Create lib/providers/auth_provider.dart extending ChangeNotifier
  - Implement user state management
  - Implement signInWithGoogle() method
  - Implement signOut() method
  - Listen to AuthService.authStateChanges and update state
  - _Requirements: 1, 11_


- [x] 4.2 Create chat provider

  - Create lib/providers/chat_provider.dart extending ChangeNotifier
  - Implement messages list state
  - Implement loadConversation() method
  - Implement startNewConversation() method
  - Implement sendMessage() method with streaming support
  - Handle ChatEvent stream and update messages incrementally
  - Implement error state management
  - _Requirements: 2, 4, 5, 11_

- [x] 5. Implement UI Widgets





  - Create reusable chat widgets
  - _Requirements: 7_

- [x] 5.1 Create message bubble widget


  - Create lib/widgets/chat/message_bubble.dart
  - Implement user message styling (right-aligned, emerald background)
  - Implement assistant message styling (left-aligned, white background)
  - Handle text wrapping and constraints
  - _Requirements: 2, 7_



- [ ] 5.2 Create property card widget
  - Create lib/widgets/chat/property_card.dart
  - Implement property image display with CachedNetworkImage
  - Display property title, location, bedrooms, bathrooms, type
  - Display formatted rent amount
  - Implement contact button
  - Handle image loading states and errors


  - _Requirements: 3, 7_

- [ ] 5.3 Create message input widget
  - Create lib/widgets/chat/message_input.dart
  - Implement multi-line TextField
  - Implement attach button for file selection
  - Implement send button


  - Handle file preview display
  - Manage input state
  - _Requirements: 2, 6, 7_

- [ ] 5.4 Create typing indicator widget
  - Create lib/widgets/chat/typing_indicator.dart
  - Implement animated dots using AnimationController
  - Style to match assistant message bubble
  - _Requirements: 4, 7_

- [ ] 6. Implement Authentication Screens
  - Create authentication UI
  - _Requirements: 1_

- [ ] 6.1 Create welcome screen
  - Create lib/screens/auth/welcome_screen.dart
  - Display app logo and branding
  - Implement Google Sign In button
  - Add terms and privacy text
  - Handle sign in button tap
  - Show loading state during authentication
  - Display error messages if authentication fails
  - _Requirements: 1, 7, 8_

- [ ] 7. Implement Chat Screen
  - Create main chat interface
  - _Requirements: 2, 3, 4, 5_

- [ ] 7.1 Create chat screen structure
  - Create lib/screens/chat/chat_screen.dart
  - Implement AppBar with title and new chat button
  - Implement Column layout with message list and input
  - Use Consumer<ChatProvider> for state management
  - _Requirements: 2, 7_

- [ ] 7.2 Implement message list
  - Implement ListView.builder for messages
  - Handle empty state display
  - Implement auto-scroll to bottom on new messages
  - Maintain scroll position when loading history
  - Render MessageBubble for text messages
  - Render PropertyCard for tool results
  - _Requirements: 2, 3, 5_

- [ ] 7.3 Implement chat interactions
  - Connect MessageInput to ChatProvider.sendMessage()
  - Display TypingIndicator when isLoading is true
  - Handle new conversation button
  - Implement error display
  - _Requirements: 2, 4, 8_

- [ ] 8. Implement Main App Entry Point
  - Set up app initialization and routing
  - _Requirements: 1, 11_

- [ ] 8.1 Create main.dart
  - Initialize Supabase in main() function
  - Set up MultiProvider with AuthProvider and ChatProvider
  - Configure MaterialApp with theme
  - Create AuthWrapper widget for conditional routing
  - _Requirements: 1, 7, 11_

- [ ] 8.2 Implement auth wrapper
  - Check AuthProvider.isAuthenticated
  - Show WelcomeScreen if not authenticated
  - Show ChatScreen if authenticated
  - Handle loading state
  - _Requirements: 1_

- [ ] 9. Implement File Upload Support
  - Add file attachment functionality
  - _Requirements: 6_

- [ ] 9.1 Implement file selection
  - Add image_picker integration to MessageInput
  - Implement camera capture option
  - Implement gallery selection option
  - Display file previews
  - _Requirements: 6, 10_

- [ ]* 9.2 Implement file upload
  - Create upload method in ApiService
  - Upload files to POST /api/upload
  - Show upload progress
  - Handle upload errors
  - Include file URLs in chat message
  - _Requirements: 6, 8_

- [ ] 10. Testing and Quality Assurance
  - Ensure app quality and reliability
  - _Requirements: 8, 9, 14_

- [ ] 10.1 Run static analysis
  - Run `flutter analyze` and fix all issues
  - Ensure no compilation warnings
  - _Requirements: 14_

- [ ] 10.2 Test on Android device
  - Build and install on Android device
  - Test Google Sign In flow
  - Test chat messaging and streaming
  - Test property card display
  - Test file attachments
  - Test error scenarios
  - _Requirements: 1, 2, 3, 4, 6, 8, 10_

- [ ] 10.3 Test on iOS device
  - Build and install on iOS device
  - Test Google Sign In flow
  - Test chat messaging and streaming
  - Test property card display
  - Test file attachments
  - Test error scenarios
  - _Requirements: 1, 2, 3, 4, 6, 8, 10_

- [ ] 11. Build and Deployment Preparation
  - Prepare app for release
  - _Requirements: 15_

- [ ] 11.1 Configure release builds
  - Update version numbers in Android and iOS configs
  - Configure app signing for Android
  - Configure app signing for iOS
  - _Requirements: 15_

- [ ] 11.2 Build release artifacts
  - Build Android APK: `flutter build apk --release`
  - Build Android App Bundle: `flutter build appbundle --release`
  - Build iOS IPA: `flutter build ios --release`
  - Test release builds on devices
  - _Requirements: 15_

---

## Task Dependencies

```
1 → 1.1, 1.2
2 (no dependencies)
3 → 2
3.1 → 2
3.2 → 2, 3.1
3.3 → 2
4 → 3
4.1 → 3.3
4.2 → 3.2
5 → 2, 4
5.1 → 2
5.2 → 2
5.3 → 2
5.4 (no dependencies)
6 → 4.1, 5
6.1 → 4.1
7 → 4.2, 5
7.1 → 4.2, 5.1, 5.2, 5.3, 5.4
7.2 → 7.1
7.3 → 7.2
8 → 4, 6, 7
8.1 → 4.1, 4.2
8.2 → 6.1, 7.1
9 → 7
9.1 → 5.3
9.2 → 3.1, 9.1
10 → 8, 9
10.1 → 8
10.2 → 10.1
10.3 → 10.1
11 → 10
11.1 → 10
11.2 → 11.1
```

---

## Notes

- Tasks marked with * are optional and can be skipped for MVP
- Each task should be completed and tested before moving to the next
- Refer to FLUTTER_COMPLETE_FILES.md for code examples
- Refer to FLUTTER_ARCHITECTURE_DIAGRAMS.md for visual guidance
- Test frequently using hot reload during development
- Commit code after completing each major task

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Status:** Ready for Execution
