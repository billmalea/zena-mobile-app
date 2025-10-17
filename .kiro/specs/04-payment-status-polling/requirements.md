# Requirements Document

## Introduction

The Contact Info Request Flow provides UI for users to request property owner contact information through M-Pesa payment. **The backend handles ALL payment polling internally** - the mobile app only needs to display the appropriate UI cards based on tool results. This is high priority as it enables users to complete the property contact request workflow.

**Key Insight:** After reviewing the backend implementation (`enhancedRequestContactInfoTool`), we discovered that payment monitoring is handled entirely server-side. The backend polls M-Pesa status every 3 seconds for up to 30 seconds and returns the final result. The mobile app simply displays the result - no polling, no background services, no complex state management needed.

**Effort Reduction:** Original estimate was 2-3 days for payment polling. Updated estimate is 1-2 days for UI cards only - 50% reduction in complexity!

## Requirements

### Requirement 1: Phone Number Confirmation

**User Story:** As a property seeker, I want to confirm my phone number before payment, so that I receive M-Pesa prompts on the correct device.

#### Acceptance Criteria

1. WHEN phone confirmation is needed THEN the system SHALL display the user's phone number from their profile
2. WHEN phone confirmation card is displayed THEN it SHALL show "Yes, use this number" and "No, use different number" buttons
3. WHEN user taps "Yes" THEN the system SHALL send a confirmation message with the phone number
4. WHEN user taps "No" THEN the system SHALL send a message requesting a different phone number
5. WHEN phone confirmation card is displayed THEN it SHALL show the property details and commission amount

### Requirement 2: Phone Number Input

**User Story:** As a property seeker, I want to provide my phone number if it's not in my profile, so that I can proceed with payment.

#### Acceptance Criteria

1. WHEN phone number is needed THEN the system SHALL display a phone input card
2. WHEN entering phone number THEN the system SHALL validate Kenyan phone number format (+254...)
3. WHEN phone number is valid THEN the system SHALL enable the submit button
4. WHEN phone number is invalid THEN the system SHALL display validation error
5. WHEN submit is tapped THEN the system SHALL send a message with the provided phone number

### Requirement 3: Contact Info Display

**User Story:** As a property seeker, I want to see the property owner's contact information after successful payment, so that I can reach out to them.

#### Acceptance Criteria

1. WHEN payment is successful THEN the system SHALL display a contact info card
2. WHEN contact info card is displayed THEN it SHALL show agent/owner name, phone number, and email (if available)
3. WHEN contact info card is displayed THEN it SHALL include a "Call" button that opens the phone dialer
4. WHEN contact info card is displayed THEN it SHALL include a "WhatsApp" button that opens WhatsApp
5. WHEN contact info card is displayed THEN it SHALL show property details and payment receipt information
6. WHEN contact info card is displayed THEN it SHALL show a success message confirming payment

### Requirement 4: Payment Error Handling

**User Story:** As a property seeker, I want clear error messages when payment fails, so that I understand what went wrong and can retry.

#### Acceptance Criteria

1. WHEN payment fails THEN the system SHALL display a payment error card
2. WHEN payment error card is displayed THEN it SHALL show a user-friendly error message
3. WHEN payment error card is displayed THEN it SHALL include a "Try Again" button
4. WHEN payment is cancelled THEN the system SHALL display "Payment was cancelled" message
5. WHEN payment times out THEN the system SHALL display "Payment verification timeout" message
6. WHEN "Try Again" is tapped THEN the system SHALL send a message to retry the payment

### Requirement 5: Backend Integration

**User Story:** As a developer, I want the mobile app to correctly handle tool results from the backend, so that the payment flow works seamlessly.

#### Acceptance Criteria

1. WHEN tool result has needsPhoneConfirmation flag THEN the system SHALL display phone confirmation card
2. WHEN tool result has needsPhoneNumber flag THEN the system SHALL display phone input card
3. WHEN tool result has success=true and contactInfo THEN the system SHALL display contact info card
4. WHEN tool result has success=false and error THEN the system SHALL display payment error card
5. WHEN backend is processing payment THEN the system SHALL display loading indicator (backend polls internally)
