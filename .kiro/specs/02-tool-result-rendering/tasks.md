# Implementation Plan

- [x] 1. Create Tool Result Widget Factory





  - Create `lib/widgets/chat/tool_result_widget.dart` as central factory for routing tool results
  - Implement switch statement on toolName to route to appropriate card
  - Add case for `searchProperties` / `smartSearch` → PropertyCard
  - Add case for `requestContactInfo` → Contact flow cards
  - Add case for `submitProperty` → Submission workflow cards
  - Add fallback case for unknown tool types
  - Pass `onSendMessage` callback to all cards
  - Handle null/missing tool result data gracefully
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Update Message Bubble to Render Tool Results





  - Update `lib/widgets/chat/message_bubble.dart` to display tool results after message content
  - Add loop to render multiple tool results per message
  - Pass `onSendMessage` callback from ChatScreen to ToolResultWidget
  - Handle auto-scroll after tool result renders
  - Test with sample tool results
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3. Enhance Property Card





  - Update `lib/widgets/chat/property_card.dart` with image carousel using PageView
  - Add carousel indicators (dots) below images
  - Display property title, location, price with KES formatting
  - Add icons for bedrooms, bathrooms, property type
  - Display amenities as chips (WiFi, Parking, Security, etc.)
  - Add "Request Contact" button with callback
  - Add availability status badge
  - Test with real property data
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Create No Properties Found Card





  - Create `lib/widgets/chat/tool_cards/no_properties_found_card.dart`
  - Display "No properties found" message
  - Show search criteria used
  - Add suggestions for adjusting search
  - Add "Start Property Hunting" button
  - Add "Adjust Search" button
  - Test with empty search results
  - _Requirements: 2.6_

- [x] 5. Create Phone Confirmation Card





  - Create `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`
  - Display property title and commission amount
  - Show phone number from profile
  - Add "Yes, use this number" button (primary style)
  - Add "No, use different number" button (secondary style)
  - Add explanation text for why phone is needed
  - Handle button callbacks to send messages
  - Test with sample data
  - _Requirements: 3.1_

- [x] 6. Create Phone Input Card





  - Create `lib/widgets/chat/tool_cards/phone_input_card.dart`
  - Add TextField for phone number input
  - Implement Kenyan phone format validation (+254... or 07... or 01...)
  - Normalize phone to +254 format before sending
  - Enable/disable submit button based on validation
  - Display validation error messages
  - Handle submit callback
  - Test with various phone formats
  - _Requirements: 3.1_

- [x] 7. Create Contact Info Card





  - Create `lib/widgets/chat/tool_cards/contact_info_card.dart`
  - Display success message with checkmark icon
  - Show property title and details
  - Display agent/owner name and phone number
  - Add "Call" button that opens phone dialer using url_launcher
  - Add "WhatsApp" button that opens WhatsApp using url_launcher
  - Show payment receipt information
  - Add video link button if available
  - Test call and WhatsApp buttons on real device
  - _Requirements: 3.3_

- [x] 8. Create Payment Error Card





  - Create `lib/widgets/chat/tool_cards/payment_error_card.dart`
  - Display error icon based on error type (cancelled, timeout, failed)
  - Show user-friendly error message
  - Display property details and payment amount
  - Add "Try Again" button with retry callback
  - Handle different error types (PAYMENT_CANCELLED, PAYMENT_TIMEOUT, PAYMENT_FAILED, PAYMENT_PROCESSING_ERROR)
  - Use appropriate colors for different error types
  - Test with various error scenarios
  - _Requirements: 3.4_
-

- [x] 9. Create Property Submission Card






  - Create `lib/widgets/chat/tool_cards/property_submission_card.dart`
  - Display stage progress indicator (1/5, 2/5, etc.)
  - Show current stage title and instructions
  - Display submission ID reference
  - Add stage-specific action buttons
  - Add back button if applicable
  - Handle different stages (start, video_uploaded, confirm_data, provide_info, final_confirm)
  - Test stage transitions
  - _Requirements: 4.1, 4.2_

- [x] 10. Create Property Data Card









  - Create `lib/widgets/chat/tool_cards/property_data_card.dart`
  - Display extracted property data in organized sections (Basic, Financial, Location, Details)
  - Add edit button for each field
  - Add confirmation buttons
  - Show data validation indicators
  - Use clear visual hierarchy
  - Handle edit callbacks
  - Test with sample extracted data
  - _Requirements: 4.2_

- [x] 11. Create Missing Fields Card




  - Create `lib/widgets/chat/tool_cards/missing_fields_card.dart`
  - Display list of missing required fields
  - Show hints for each field
  - Add input fields or prompts for each missing field
  - Add "Submit" button
  - Implement field validation
  - Display error messages for invalid inputs
  - Handle submit callback with collected data
  - Test with various missing field scenarios
  - _Requirements: 4.3_

- [x] 12. Create Final Review Card





  - Create `lib/widgets/chat/tool_cards/final_review_card.dart`
  - Display complete property summary with all fields
  - Show generated title and description
  - Add "Confirm and List" button (primary)
  - Add "Edit" button (secondary)
  - Add terms and conditions checkbox
  - Handle confirmation callback
  - Test complete review flow
  - _Requirements: 4.4, 4.5_

- [x] 13. Create Additional Tool Cards





  - Create `lib/widgets/chat/tool_cards/property_hunting_card.dart` for hunting requests
  - Create `lib/widgets/chat/tool_cards/commission_card.dart` for earnings display
  - Create `lib/widgets/chat/tool_cards/neighborhood_info_card.dart` for location info
  - Create `lib/widgets/chat/tool_cards/affordability_card.dart` for rent calculator
  - Create `lib/widgets/chat/tool_cards/auth_prompt_card.dart` for sign-in prompts
  - Implement each card according to design specifications
  - Test each card with sample data
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 14. Integrate All Tool Cards into Factory





  - Update ToolResultWidget factory with all tool card cases
  - Add routing for property hunting tool
  - Add routing for commission tool
  - Add routing for neighborhood info tool
  - Add routing for affordability tool
  - Add routing for auth prompt tool
  - Test routing for all 15+ tool types
  - Verify fallback for unknown tools
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 15. Configure Platform Permissions for URL Launcher





  - Update `android/app/src/main/AndroidManifest.xml` with queries for tel and https intents
  - Update `ios/Runner/Info.plist` with LSApplicationQueriesSchemes for tel and whatsapp
  - Test call button on Android device
  - Test call button on iOS device
  - Test WhatsApp button on Android device
  - Test WhatsApp button on iOS device
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_



- [x] 16. Apply Consistent Styling and Theming


  - Create shared card decoration style
  - Apply consistent padding and margins to all cards
  - Ensure all cards support light and dark themes
  - Add consistent loading indicators
  - Add consistent error message styling
  - Test all cards in light theme
  - Test all cards in dark theme
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 17. End-to-End Integration Testing






  - Test property search results display correctly
  - Test payment flow cards transition properly (phone confirm → payment → contact info)
  - Test property submission workflow through all 5 stages
  - Test all interactive buttons trigger correct callbacks
  - Test error states display correctly
  - Test with real backend responses
  - Test on different screen sizes
  - Test with long text content
  - Test with missing optional fields
  - Verify 90%+ visual parity with web app
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.3, 7.4, 7.5_
