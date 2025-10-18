# Implementation Plan

**Note:** This spec has been simplified based on backend implementation review. The backend handles ALL payment polling internally - mobile only needs to display UI cards based on tool results.

- [x] 1. Create Phone Confirmation Card





  - Create `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`
  - Display property title and commission amount from tool result
  - Show phone number from userPhoneFromProfile field
  - Add "Yes, use this number" button (primary style)
  - Add "No, use different number" button (secondary style)
  - Add explanation text for why phone is needed
  - Implement onConfirm callback to send confirmation message
  - Implement onDecline callback to send decline message
  - Test with sample tool result data
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Create Phone Input Card


  - Create `lib/widgets/chat/tool_cards/phone_input_card.dart`
  - Add TextField for phone number input with phone keyboard type
  - Implement Kenyan phone format validation using RegExp (+254... or 07... or 01...)
  - Normalize phone to +254 format before submitting
  - Enable/disable submit button based on validation
  - Display validation error messages
  - Implement onSubmit callback to send phone number message
  - Test with various phone formats (valid and invalid)
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_


- [x] 3. Create Contact Info Card

  - Create `lib/widgets/chat/tool_cards/contact_info_card.dart`
  - Display success message with checkmark icon
  - Show property title and location from contactInfo
  - Display agent/owner name and phone number
  - Add "Call" button that opens phone dialer using url_launcher
  - Add "WhatsApp" button that opens WhatsApp using url_launcher
  - Show payment receipt information (amount, receipt number)
  - Add video link button if videoUrl is available
  - Handle alreadyPaid flag to adjust messaging
  - Test call button opens dialer on real device
  - Test WhatsApp button opens WhatsApp on real device
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 4. Create Payment Error Card


  - Create `lib/widgets/chat/tool_cards/payment_error_card.dart`
  - Display error icon based on errorType (cancel, timeout, failed, processing error)
  - Show user-friendly error message from tool result
  - Display property details (title, commission amount)
  - Show payment info if available
  - Add "Try Again" button with retry callback
  - Use appropriate icon colors for different error types (orange for cancelled, blue for timeout, red for failed)
  - Implement onRetry callback to send retry message
  - Test with all error types (PAYMENT_CANCELLED, PAYMENT_TIMEOUT, PAYMENT_FAILED, PAYMENT_PROCESSING_ERROR)
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [x] 5. Update Tool Result Factory for Contact Info Flow



  - Update `lib/widgets/chat/tool_result_widget.dart` to add requestContactInfo case
  - Implement _buildContactInfoResult() method to route based on tool result flags
  - Route to PhoneConfirmationCard when needsPhoneConfirmation is true
  - Route to PhoneInputCard when needsPhoneNumber is true
  - Route to ContactInfoCard when success is true and contactInfo exists
  - Route to PaymentErrorCard when success is false and error exists
  - Pass appropriate callbacks to each card
  - Test routing for all 4 scenarios
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 6. Configure Platform Permissions for URL Launcher



  - Verify `android/app/src/main/AndroidManifest.xml` has queries for tel and https intents
  - Verify `ios/Runner/Info.plist` has LSApplicationQueriesSchemes for tel and whatsapp
  - Test call button on Android device
  - Test call button on iOS device
  - Test WhatsApp button on Android device
  - Test WhatsApp button on iOS device
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 7. End-to-End Testing with Real M-Pesa





  - Test complete flow: Request contact info → Phone confirmation → Payment → Contact info display
  - Test phone confirmation with "Yes" button
  - Test phone confirmation with "No" button and provide different number
  - Test successful payment flow (complete M-Pesa on phone)
  - Test cancelled payment flow (cancel M-Pesa on phone)
  - Test timeout scenario (don't respond to M-Pesa prompt)
  - Test failed payment scenario (insufficient balance)
  - Test retry after error
  - Test call button functionality
  - Test WhatsApp button functionality
  - Verify backend handles all polling (mobile just waits for result)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.1, 5.2, 5.3, 5.4, 5.5_
