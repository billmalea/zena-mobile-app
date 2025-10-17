---
title: Tool Result Rendering System
priority: CRITICAL
estimated_effort: 4-5 days
status: pending
dependencies: []
---

# Tool Result Rendering System

## Overview
Implement specialized UI cards for rendering 15+ AI tool results. Currently only basic property cards exist. This is CRITICAL - users cannot interact with AI responses without proper tool result rendering.

## Current State
- ✅ Basic property card exists
- ❌ 14+ specialized tool cards missing
- ❌ No tool result widget factory
- ❌ Tool results not rendered in chat screen

## Requirements

### 1. Tool Result Widget Factory
Create `lib/widgets/chat/tool_result_widget.dart`

**Purpose:** Central factory for rendering all tool result types

**Features:**
- Switch on `toolName` to render appropriate card
- Pass `onSendMessage` callback for interactive buttons
- Handle unknown tool types gracefully
- Support all 15+ tool types from web app

**Tool Types to Support:**
1. `searchProperties` / `smartSearch` - Property search results
2. `requestContactInfo` - Payment & contact flow
3. `submitProperty` - Property submission workflow
4. `completePropertySubmission` - Submission completion
5. `adminPropertyHunting` - Property hunting requests
6. `propertyHuntingStatus` - Hunting status
7. `getNeighborhoodInfo` - Location information
8. `calculateAffordability` - Rent calculator
9. `checkPaymentStatus` - M-Pesa status
10. `confirmRentalSuccess` - Commission tracking
11. `getCommissionStatus` - Earnings display
12. `getUserBalance` - Account balance
13-15. Enhanced search variants

### 2. Property Search Results Cards

#### A. Enhanced Property Card
Update `lib/widgets/chat/tool_cards/property_card.dart`

**Features:**
- Image carousel (multiple property images)
- Property title and location
- Price with currency formatting
- Bedrooms, bathrooms, property type
- Amenities chips (WiFi, Parking, etc.)
- "Request Contact" button
- Availability status badge
- Favorite button (future)

#### B. No Properties Found Card
Create `lib/widgets/chat/tool_cards/no_properties_found_card.dart`

**Features:**
- "No properties found" message
- Display search criteria used
- Suggestions for adjusting search
- "Start Property Hunting" button
- "Adjust Search" button
- Helpful tips for better results

### 3. Payment Flow Cards

#### A. Payment Status Card
Create `lib/widgets/chat/tool_cards/payment_status_card.dart`

**Features:**
- Property title and amount
- Payment status (pending/success/failed)
- M-Pesa phone number
- CheckoutRequestID for reference
- Real-time status updates (polling)
- Progress indicator for pending
- "Try Again" button on failure
- Success animation on completion
- Contact info display on success

#### B. Phone Confirmation Card
Create `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`

**Features:**
- "Confirm your phone number" message
- Display phone number from profile
- "Yes, use this number" button
- "No, use different number" button
- Clear visual hierarchy
- Explanation of why phone is needed

#### C. Contact Info Card
Create `lib/widgets/chat/tool_cards/contact_info_card.dart`

**Features:**
- Agent/owner name
- Phone number with "Call" button
- WhatsApp button (if available)
- Email (if available)
- "Already paid" indicator
- Property reference
- Success message

### 4. Property Submission Cards

#### A. Property Submission Card
Create `lib/widgets/chat/tool_cards/property_submission_card.dart`

**Features:**
- Stage progress indicator (1/5, 2/5, etc.)
- Current stage title
- Instructions for current stage
- Submission ID reference
- Stage-specific actions
- Back button (if applicable)

**Stages:**
1. Start - Upload video instructions
2. Video Uploaded - Analyzing video
3. Confirm Data - Review extracted data
4. Provide Info - Fill missing fields
5. Final Confirm - Review before listing

#### B. Property Data Card
Create `lib/widgets/chat/tool_cards/property_data_card.dart`

**Features:**
- Display extracted property data
- Organized sections (Basic, Financial, Location, Details)
- Edit button for each field
- Confirmation buttons
- Data validation indicators
- Clear visual hierarchy

#### C. Missing Fields Card
Create `lib/widgets/chat/tool_cards/missing_fields_card.dart`

**Features:**
- List of missing required fields
- Hints for each field
- Input fields or prompts
- "Submit" button
- Field validation
- Error messages

#### D. Final Review Card
Create `lib/widgets/chat/tool_cards/final_review_card.dart`

**Features:**
- Complete property summary
- All fields displayed
- Generated title and description
- "Confirm and List" button
- "Edit" button
- Terms and conditions checkbox

### 5. Other Tool Cards

#### A. Property Hunting Card
Create `lib/widgets/chat/tool_cards/property_hunting_card.dart`

**Features:**
- Hunting request status
- Search criteria display
- Request ID
- Status badge (active/completed)
- "Check Status" button

#### B. Commission Card
Create `lib/widgets/chat/tool_cards/commission_card.dart`

**Features:**
- Commission amount
- Property reference
- Date earned
- Status (pending/paid)
- Total earnings summary

#### C. Neighborhood Info Card
Create `lib/widgets/chat/tool_cards/neighborhood_info_card.dart`

**Features:**
- Neighborhood name
- Description
- Key features (schools, hospitals, transport)
- Safety rating
- Average rent prices

#### D. Affordability Card
Create `lib/widgets/chat/tool_cards/affordability_card.dart`

**Features:**
- Monthly income input
- Recommended rent range
- Affordability percentage
- Budget breakdown
- Tips for affordability

#### E. Auth Prompt Card
Create `lib/widgets/chat/tool_cards/auth_prompt_card.dart`

**Features:**
- "Sign in required" message
- Explanation of why auth is needed
- "Sign In" button
- "Sign Up" button
- "Continue as Guest" option (if applicable)

### 6. Chat Screen Integration
Update `lib/screens/chat/chat_screen.dart`

**Changes:**
- Render tool results after message content
- Pass `onSendMessage` callback to tool widgets
- Handle tool result interactions
- Auto-scroll after tool result renders

## Implementation Tasks

### Phase 1: Core Infrastructure (Day 1)
- [ ] Create `tool_result_widget.dart` factory
- [ ] Update `message_bubble.dart` to render tool results
- [ ] Update `chat_screen.dart` with tool result support
- [ ] Test basic tool result rendering

### Phase 2: Property Search Cards (Day 2)
- [ ] Enhance `property_card.dart`
- [ ] Create `no_properties_found_card.dart`
- [ ] Test property search results rendering
- [ ] Test property hunting offer flow

### Phase 3: Payment Flow Cards (Day 3)
- [ ] Create `payment_status_card.dart`
- [ ] Create `phone_confirmation_card.dart`
- [ ] Create `contact_info_card.dart`
- [ ] Test payment flow end-to-end

### Phase 4: Property Submission Cards (Day 4)
- [ ] Create `property_submission_card.dart`
- [ ] Create `property_data_card.dart`
- [ ] Create `missing_fields_card.dart`
- [ ] Create `final_review_card.dart`
- [ ] Test submission workflow

### Phase 5: Other Tool Cards (Day 5)
- [ ] Create `property_hunting_card.dart`
- [ ] Create `commission_card.dart`
- [ ] Create `neighborhood_info_card.dart`
- [ ] Create `affordability_card.dart`
- [ ] Create `auth_prompt_card.dart`
- [ ] Test all tool cards

## Testing Checklist

### Widget Tests
- [ ] Tool result factory renders correct card for each tool
- [ ] Property card displays all fields correctly
- [ ] Payment status card shows correct status
- [ ] Phone confirmation buttons work
- [ ] Contact info displays correctly
- [ ] Submission cards show correct stage
- [ ] All interactive buttons trigger callbacks

### Integration Tests
- [ ] Property search results render
- [ ] Payment flow cards transition correctly
- [ ] Submission workflow progresses through stages
- [ ] Tool result interactions send messages
- [ ] Error states display correctly

### Manual Tests
- [ ] All 15+ tool types render correctly
- [ ] Interactive buttons work
- [ ] Layouts are responsive
- [ ] Dark mode support (if applicable)
- [ ] Accessibility (screen readers, contrast)

## Success Criteria
- ✅ All 15+ tool types have specialized UI cards
- ✅ Tool results render correctly in chat
- ✅ Interactive buttons trigger appropriate actions
- ✅ Layouts are responsive and polished
- ✅ Error states are handled gracefully
- ✅ 90%+ visual parity with web app

## Dependencies
- Tool result data structure from API
- Message model with `toolResults` field
- Chat provider with message state

## Notes
- Use factory pattern to avoid hardcoding tool types
- Reuse web app UI patterns for consistency
- Keep cards modular and testable
- Support both light and dark themes
- Follow Material Design guidelines

## Reference Files
- Web implementation: `zena/app/chat/page.tsx` (tool result rendering)
- Tool cards: `zena/components/chat/tool-results/`
- Code examples: `zena_mobile_app/MISSING MD/MOBILE_APP_CRITICAL_CODE_EXAMPLES.md`
