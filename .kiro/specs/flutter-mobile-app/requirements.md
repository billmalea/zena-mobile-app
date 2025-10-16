# Requirements Document - Zena Flutter Mobile App

## Introduction

The Zena Flutter Mobile App is a native mobile application (iOS & Android) that provides users with a mobile-first experience for interacting with the Zena rental platform. The app connects to the existing Zena backend (https://zena.co.ke) and provides a chat-first interface powered by AI for property search, listing, and management.

**Key Principle:** This is a mobile UI layer that connects to the existing, fully-functional backend. No backend changes are required.

---

## Requirements

### Requirement 1: User Authentication

**User Story:** As a user, I want to sign in with my Google account, so that I can access the Zena platform securely on my mobile device.

#### Acceptance Criteria

1. WHEN the user opens the app for the first time THEN the system SHALL display a welcome screen with a "Sign in with Google" button
2. WHEN the user taps the "Sign in with Google" button THEN the system SHALL redirect to Google OAuth consent screen
3. WHEN the user completes Google authentication THEN the system SHALL receive an OAuth callback at `zena://auth-callback`
4. WHEN the OAuth callback is received THEN the system SHALL create a Supabase session with JWT token
5. WHEN authentication is successful THEN the system SHALL navigate to the main chat screen
6. WHEN the user reopens the app with a valid session THEN the system SHALL automatically log them in
7. WHEN the user signs out THEN the system SHALL clear the session and return to the welcome screen

---

### Requirement 2: Chat Interface

**User Story:** As a user, I want to chat with an AI assistant, so that I can search for properties, list properties, and get help with rental-related tasks.

#### Acceptance Criteria

1. WHEN the user is authenticated THEN the system SHALL display the main chat screen
2. WHEN the user types a message and taps send THEN the system SHALL add the message to the chat history immediately
3. WHEN a message is sent THEN the system SHALL call POST /api/chat with the message content
4. WHEN the backend responds THEN the system SHALL stream the AI response in real-time using SSE (Server-Sent Events)
5. WHEN streaming text chunks THEN the system SHALL update the assistant message incrementally
6. WHEN the AI response is complete THEN the system SHALL stop the loading indicator
7. WHEN there is an error THEN the system SHALL display an error message and allow retry
8. WHEN the user scrolls up THEN the system SHALL maintain scroll position
9. WHEN a new message arrives THEN the system SHALL auto-scroll to the bottom
10. WHEN the user starts a new conversation THEN the system SHALL clear the current messages

---

### Requirement 3: Property Display

**User Story:** As a user, I want to see property search results as cards in the chat, so that I can browse available rentals visually.

#### Acceptance Criteria

1. WHEN the AI calls the searchProperties tool THEN the system SHALL receive tool results in the SSE stream
2. WHEN tool results contain properties THEN the system SHALL render PropertyCard widgets for each property
3. WHEN a PropertyCard is displayed THEN it SHALL show property image, title, location, bedrooms, bathrooms, and rent amount
4. WHEN property images are loading THEN the system SHALL show a placeholder
5. WHEN a property image fails to load THEN the system SHALL show an error placeholder
6. WHEN the user taps a PropertyCard THEN the system SHALL show property details or contact request option
7. WHEN no properties are found THEN the system SHALL display a "no results" message
8. WHEN properties are displayed THEN they SHALL be formatted with Kenyan currency (KSh) and proper number formatting

---

### Requirement 4: Real-time Streaming

**User Story:** As a user, I want to see AI responses appear in real-time, so that I get immediate feedback and a conversational experience.

#### Acceptance Criteria

1. WHEN the backend sends SSE data THEN the system SHALL parse lines starting with "data: "
2. WHEN SSE data contains type "text" THEN the system SHALL append the content to the current assistant message
3. WHEN SSE data contains type "tool" THEN the system SHALL add the tool result to the message metadata
4. WHEN streaming is in progress THEN the system SHALL display a typing indicator
5. WHEN the stream ends THEN the system SHALL remove the typing indicator
6. WHEN the connection is lost THEN the system SHALL show an error and allow retry
7. WHEN streaming fails THEN the system SHALL display the last successfully received content

---

### Requirement 5: Message History

**User Story:** As a user, I want to see my previous conversations, so that I can continue where I left off.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL load the most recent conversation
2. WHEN a conversation is loaded THEN the system SHALL call GET /api/chat/conversation
3. WHEN conversation history is received THEN the system SHALL display all messages in chronological order
4. WHEN messages contain tool results THEN the system SHALL render them appropriately (property cards, etc.)
5. WHEN loading conversation history THEN the system SHALL show a loading indicator
6. WHEN conversation history fails to load THEN the system SHALL show an error message
7. WHEN the user creates a new conversation THEN the system SHALL call POST /api/chat/conversation

---

### Requirement 6: File Attachments

**User Story:** As a user, I want to attach images and videos to my messages, so that I can share property photos or provide visual context.

#### Acceptance Criteria

1. WHEN the user taps the attach button THEN the system SHALL show options for camera or gallery
2. WHEN the user selects camera THEN the system SHALL open the device camera
3. WHEN the user selects gallery THEN the system SHALL open the image picker
4. WHEN files are selected THEN the system SHALL show file previews
5. WHEN the user sends a message with files THEN the system SHALL upload files to POST /api/upload
6. WHEN files are uploading THEN the system SHALL show upload progress
7. WHEN upload is complete THEN the system SHALL include file URLs in the chat message
8. WHEN upload fails THEN the system SHALL show an error and allow retry
9. WHEN files are too large THEN the system SHALL show a size limit error

---

### Requirement 7: UI/UX Design

**User Story:** As a user, I want a beautiful and intuitive interface, so that I can easily navigate and use the app.

#### Acceptance Criteria

1. WHEN the app is displayed THEN it SHALL use the Emerald/Teal color scheme matching the web app
2. WHEN text is displayed THEN it SHALL use the Inter font family via Google Fonts
3. WHEN the app is displayed THEN it SHALL follow Material 3 design guidelines
4. WHEN user messages are displayed THEN they SHALL appear on the right with emerald background
5. WHEN assistant messages are displayed THEN they SHALL appear on the left with white background
6. WHEN the keyboard is shown THEN the chat input SHALL remain visible above the keyboard
7. WHEN the app is used on different screen sizes THEN it SHALL be responsive and adapt layout
8. WHEN the app is used in dark mode THEN it SHALL respect system theme preferences (optional)
9. WHEN buttons are tapped THEN they SHALL provide visual feedback
10. WHEN loading states occur THEN they SHALL show appropriate indicators

---

### Requirement 8: Error Handling

**User Story:** As a user, I want clear error messages and recovery options, so that I can resolve issues and continue using the app.

#### Acceptance Criteria

1. WHEN the backend is unreachable THEN the system SHALL display "Cannot connect to server" message
2. WHEN authentication fails THEN the system SHALL display the specific error and allow retry
3. WHEN a message fails to send THEN the system SHALL show an error indicator on the message
4. WHEN streaming fails mid-response THEN the system SHALL show partial content and error message
5. WHEN file upload fails THEN the system SHALL show error and allow retry
6. WHEN there is no internet connection THEN the system SHALL display "No internet connection" message
7. WHEN an error occurs THEN the system SHALL log it for debugging (development mode only)
8. WHEN the user taps retry THEN the system SHALL attempt the failed operation again

---

### Requirement 9: Performance

**User Story:** As a user, I want the app to be fast and responsive, so that I can have a smooth experience.

#### Acceptance Criteria

1. WHEN the app launches THEN it SHALL display the first screen within 2 seconds
2. WHEN messages are sent THEN they SHALL appear in the UI within 100ms
3. WHEN scrolling through messages THEN the frame rate SHALL remain above 50 FPS
4. WHEN images are loaded THEN they SHALL be cached for subsequent views
5. WHEN the app is in the background THEN it SHALL minimize resource usage
6. WHEN large conversations are loaded THEN the system SHALL use pagination or virtualization
7. WHEN the app uses memory THEN it SHALL not exceed 200MB under normal usage
8. WHEN network requests are made THEN they SHALL have appropriate timeouts (30 seconds)

---

### Requirement 10: Platform Integration

**User Story:** As a user, I want the app to work seamlessly on both iOS and Android, so that I get a native experience on my device.

#### Acceptance Criteria

1. WHEN the app is built for Android THEN it SHALL support Android 6.0 (API 23) and above
2. WHEN the app is built for iOS THEN it SHALL support iOS 12.0 and above
3. WHEN deep links are received THEN the system SHALL handle `zena://auth-callback` for OAuth
4. WHEN the app requests permissions THEN it SHALL show appropriate permission dialogs
5. WHEN camera permission is needed THEN the system SHALL request camera access
6. WHEN gallery permission is needed THEN the system SHALL request photo library access
7. WHEN the app is installed THEN it SHALL have appropriate app icon and splash screen
8. WHEN the app is backgrounded THEN it SHALL save state and restore on resume
9. WHEN push notifications are received THEN the system SHALL handle them appropriately (future)
10. WHEN the app is on Android THEN it SHALL follow Android design patterns
11. WHEN the app is on iOS THEN it SHALL follow iOS design patterns

---

### Requirement 11: State Management

**User Story:** As a developer, I want clean state management, so that the app is maintainable and scalable.

#### Acceptance Criteria

1. WHEN state changes occur THEN the system SHALL use Provider pattern for state management
2. WHEN authentication state changes THEN AuthProvider SHALL notify all listeners
3. WHEN chat state changes THEN ChatProvider SHALL notify all listeners
4. WHEN providers notify listeners THEN only affected widgets SHALL rebuild
5. WHEN the app is initialized THEN providers SHALL be set up in the correct order
6. WHEN state is updated THEN it SHALL be done immutably
7. WHEN errors occur in providers THEN they SHALL be caught and exposed to the UI

---

### Requirement 12: API Integration

**User Story:** As a developer, I want robust API integration, so that the app reliably communicates with the backend.

#### Acceptance Criteria

1. WHEN API calls are made THEN they SHALL include proper authentication headers
2. WHEN the access token is available THEN it SHALL be included as Bearer token
3. WHEN API calls are made THEN they SHALL use the configured base URL from app_config.dart
4. WHEN POST requests are made THEN they SHALL include Content-Type: application/json
5. WHEN SSE streaming is used THEN it SHALL properly parse Server-Sent Events format
6. WHEN API responses are received THEN they SHALL be validated before use
7. WHEN API calls fail THEN they SHALL throw appropriate exceptions
8. WHEN network timeouts occur THEN they SHALL be handled gracefully
9. WHEN the API returns 401 THEN the system SHALL trigger re-authentication

---

### Requirement 13: Configuration Management

**User Story:** As a developer, I want easy configuration management, so that I can deploy to different environments.

#### Acceptance Criteria

1. WHEN the app is built THEN it SHALL read configuration from lib/config/app_config.dart
2. WHEN configuration is needed THEN it SHALL include backend URL, Supabase URL, and Supabase anon key
3. WHEN different environments are needed THEN configuration SHALL be easily changeable
4. WHEN sensitive data is stored THEN it SHALL not be committed to version control
5. WHEN the app is deployed THEN environment-specific configuration SHALL be used

---

### Requirement 14: Testing Support

**User Story:** As a developer, I want the app to be testable, so that I can ensure quality and catch bugs early.

#### Acceptance Criteria

1. WHEN code is written THEN it SHALL be structured to support unit testing
2. WHEN services are implemented THEN they SHALL be mockable for testing
3. WHEN widgets are created THEN they SHALL be testable in isolation
4. WHEN the app is built THEN it SHALL pass `flutter analyze` without errors
5. WHEN the app is built THEN it SHALL have no compilation warnings

---

### Requirement 15: Build and Deployment

**User Story:** As a developer, I want streamlined build and deployment, so that I can release updates efficiently.

#### Acceptance Criteria

1. WHEN building for Android THEN the system SHALL generate APK or App Bundle
2. WHEN building for iOS THEN the system SHALL generate IPA file
3. WHEN version is updated THEN it SHALL be reflected in both Android and iOS configs
4. WHEN the app is released THEN it SHALL have proper app signing
5. WHEN the app is submitted THEN it SHALL meet Google Play and App Store requirements
6. WHEN the app is built for release THEN it SHALL be optimized and minified
7. WHEN the app is deployed THEN it SHALL connect to production backend

---

## Non-Functional Requirements

### Security
- All API communication SHALL use HTTPS
- Authentication tokens SHALL be stored securely
- Sensitive data SHALL not be logged in production
- OAuth flow SHALL follow security best practices

### Accessibility
- Text SHALL have sufficient contrast ratios
- Touch targets SHALL be at least 44x44 points
- Screen readers SHALL be supported (future enhancement)

### Compatibility
- App SHALL work on Android 6.0+ and iOS 12.0+
- App SHALL support various screen sizes and orientations
- App SHALL handle different network conditions gracefully

### Maintainability
- Code SHALL follow Flutter best practices
- Code SHALL be well-documented
- Architecture SHALL be modular and scalable
- Dependencies SHALL be kept up to date

---

## Out of Scope

The following features are explicitly out of scope for this implementation:

- Phone number authentication (Google Sign In only)
- Offline mode with local database
- Push notifications (future enhancement)
- In-app payments (handled via web redirect)
- Property map view (future enhancement)
- Advanced property filters UI (handled via chat)
- User profile management screen (future enhancement)
- Settings screen (future enhancement)
- Multi-language support (English only)
- Tablet-optimized layouts (phone-first)

---

## Success Criteria

The implementation will be considered successful when:

1. ✅ Users can sign in with Google
2. ✅ Users can send and receive chat messages
3. ✅ AI responses stream in real-time
4. ✅ Property cards display correctly
5. ✅ Images load and display properly
6. ✅ File attachments work
7. ✅ App works on both Android and iOS
8. ✅ App connects to production backend
9. ✅ No critical bugs or crashes
10. ✅ App passes app store review guidelines

---

## Dependencies

### External Services
- Zena Backend API (https://zena.live/api)
- Supabase (authentication and database)
- Google OAuth (authentication)

### Flutter Packages
- provider (state management)
- http (API calls)
- supabase_flutter (authentication)
- google_fonts (typography)
- cached_network_image (image caching)
- image_picker (file selection)
- uuid (unique IDs)
- intl (internationalization)
- shared_preferences (local storage)

---

## Assumptions

1. The backend API is stable and available
2. Supabase is properly configured with Google OAuth
3. Users have Google accounts
4. Users have internet connectivity
5. Backend handles all business logic and AI processing
6. Backend API endpoints match documentation
7. SSE streaming format is consistent

---

## Constraints

1. Must use existing backend without modifications
2. Must support Android 6.0+ and iOS 12.0+
3. Must use Flutter framework
4. Must use Provider for state management
5. Must follow Material 3 design guidelines
6. Must complete implementation within 3-5 hours
7. Must be deployable to app stores

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Status:** Ready for Implementation
