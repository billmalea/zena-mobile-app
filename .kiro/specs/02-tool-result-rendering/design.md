# Design Document

## Overview

The Tool Result Rendering System provides a comprehensive UI framework for displaying AI tool results in the chat interface. The system uses a factory pattern to route tool results to specialized card widgets, enabling rich, interactive displays for 15+ different tool types. This is critical for users to interact with property searches, payment flows, submission workflows, and other AI-powered features.

**Current State:** Only basic property card exists. Need to implement tool result factory and 14+ additional specialized cards.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Chat Screen                          │
│  ┌───────────────────────────────────────────────────┐ │
│  │           Message Bubble                          │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Message Content (Text)                     │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Tool Result Widget Factory                 │ │ │
│  │  │  ┌───────────────────────────────────────┐ │ │ │
│  │  │  │  Switch on toolName                   │ │ │ │
│  │  │  │  ├─ searchProperties → PropertyCard   │ │ │ │
│  │  │  │  ├─ requestContactInfo → ContactCard  │ │ │ │
│  │  │  │  ├─ submitProperty → SubmissionCard   │ │ │ │
│  │  │  │  └─ ... (15+ tool types)              │ │ │ │
│  │  │  └───────────────────────────────────────┘ │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. AI returns tool result in message
2. MessageBubble renders message content
3. MessageBubble passes tool results to ToolResultWidget factory
4. Factory switches on toolName and renders appropriate card
5. Card displays data and provides interactive buttons
6. Button callbacks send messages back to chat

## Components and Interfaces

### 1. Tool Result Widget Factory

**Location:** `lib/widgets/chat/tool_result_widget.dart`

**Purpose:** Central factory for routing tool results to specialized cards

**Interface:**
```dart
class ToolResultWidget extends StatelessWidget {
  final ToolResult toolResult;
  final Function(String)? onSendMessage;
  
  const ToolResultWidget({
    required this.toolResult,
    this.onSendMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    switch (toolResult.toolName) {
      case 'searchProperties':
      case 'smartSearch':
        return _buildPropertySearchResults(context);
      case 'requestContactInfo':
        return _buildContactInfoResult(context);
      case 'submitProperty':
        return _buildPropertySubmissionResult(context);
      // ... 15+ tool types
      default:
        return _buildUnknownToolResult(context);
    }
  }
}
```

**Supported Tool Types:**
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

**Location:** `lib/widgets/chat/tool_cards/property_card.dart` (update existing)

**Purpose:** Display individual property with rich details

**Interface:**
```dart
class PropertyCard extends StatelessWidget {
  final Property property;
  final Function(String)? onRequestContact;
  
  const PropertyCard({
    required this.property,
    this.onRequestContact,
  });
}
```

**UI Components:**
- Image carousel (PageView with indicators)
- Property title and location
- Price with currency formatting (KES)
- Bedrooms, bathrooms, property type icons
- Amenities chips (WiFi, Parking, Security, etc.)
- "Request Contact" button
- Availability status badge

**Layout:**
```
┌─────────────────────────────────┐
│  [Image Carousel]               │
│  ● ○ ○                          │
├─────────────────────────────────┤
│  2BR Apartment in Westlands     │
│  📍 Westlands, Nairobi          │
│                                 │
│  KES 50,000/month               │
│                                 │
│  🛏️ 2  🚿 2  🏠 Apartment       │
│                                 │
│  [WiFi] [Parking] [Security]    │
│                                 │
│  [Request Contact Info]         │
└─────────────────────────────────┘
```

#### B. No Properties Found Card

**Location:** `lib/widgets/chat/tool_cards/no_properties_found_card.dart`

**Purpose:** Display helpful message when no properties match search

**Interface:**
```dart
class NoPropertiesFoundCard extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  final Function(String)? onSendMessage;
  
  const NoPropertiesFoundCard({
    required this.searchCriteria,
    this.onSendMessage,
  });
}
```

**UI Components:**
- "No properties found" message
- Display search criteria used
- Suggestions for adjusting search
- "Start Property Hunting" button
- "Adjust Search" button

### 3. Payment Flow Cards

#### A. Phone Confirmation Card

**Location:** `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`

**Purpose:** Confirm user's phone number before payment

**Interface:**
```dart
class PhoneConfirmationCard extends StatelessWidget {
  final String phoneNumber;
  final String message;
  final Map<String, dynamic> property;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  
  const PhoneConfirmationCard({
    required this.phoneNumber,
    required this.message,
    required this.property,
    required this.onConfirm,
    required this.onDecline,
  });
}
```

**UI Components:**
- Property title and commission amount
- Phone number display
- "Yes, use this number" button (primary)
- "No, use different number" button (secondary)
- Explanation text

#### B. Phone Input Card

**Location:** `lib/widgets/chat/tool_cards/phone_input_card.dart`

**Purpose:** Collect phone number if not in profile

**Interface:**
```dart
class PhoneInputCard extends StatelessWidget {
  final String message;
  final Map<String, dynamic> property;
  final Function(String) onSubmit;
  
  const PhoneInputCard({
    required this.message,
    required this.property,
    required this.onSubmit,
  });
}
```

**UI Components:**
- Text input for phone number
- Phone number validation (Kenyan format: +254...)
- Submit button
- Clear instructions

#### C. Contact Info Card

**Location:** `lib/widgets/chat/tool_cards/contact_info_card.dart`

**Purpose:** Display property owner contact details after successful payment

**Interface:**
```dart
class ContactInfoCard extends StatelessWidget {
  final Map<String, dynamic> contactInfo;
  final Map<String, dynamic>? paymentInfo;
  final String message;
  final bool alreadyPaid;
  
  const ContactInfoCard({
    required this.contactInfo,
    this.paymentInfo,
    required this.message,
    this.alreadyPaid = false,
  });
}
```

**UI Components:**
- Success message
- Agent/owner name
- Phone number with "Call" button
- WhatsApp button
- Email (if available)
- Property details
- Payment receipt info
- Video link (if available)

#### D. Payment Error Card

**Location:** `lib/widgets/chat/tool_cards/payment_error_card.dart`

**Purpose:** Display payment errors with retry option

**Interface:**
```dart
class PaymentErrorCard extends StatelessWidget {
  final String error;
  final String? errorType;
  final Map<String, dynamic> property;
  final Map<String, dynamic>? paymentInfo;
  final VoidCallback onRetry;
  
  const PaymentErrorCard({
    required this.error,
    this.errorType,
    required this.property,
    this.paymentInfo,
    required this.onRetry,
  });
}
```

**UI Components:**
- Error icon
- User-friendly error message
- Error type indicator
- "Try Again" button
- Property details
- Payment info (if available)

**Error Types:**
- `PAYMENT_CANCELLED` - User cancelled
- `PAYMENT_FAILED` - System error
- `PAYMENT_TIMEOUT` - Verification timeout
- `PAYMENT_PROCESSING_ERROR` - General error

### 4. Property Submission Cards

#### A. Property Submission Card

**Location:** `lib/widgets/chat/tool_cards/property_submission_card.dart`

**Purpose:** Display submission workflow progress

**Interface:**
```dart
class PropertySubmissionCard extends StatelessWidget {
  final String submissionId;
  final String stage;
  final String message;
  final Map<String, dynamic>? data;
  final Function(String)? onSendMessage;
  
  const PropertySubmissionCard({
    required this.submissionId,
    required this.stage,
    required this.message,
    this.data,
    this.onSendMessage,
  });
}
```

**UI Components:**
- Stage progress indicator (1/5, 2/5, etc.)
- Current stage title
- Instructions for current stage
- Submission ID reference
- Stage-specific actions
- Back button (if applicable)

**Stages:**
1. `start` - Upload video instructions
2. `video_uploaded` - Analyzing video
3. `confirm_data` - Review extracted data
4. `provide_info` - Fill missing fields
5. `final_confirm` - Review before listing

#### B. Property Data Card

**Location:** `lib/widgets/chat/tool_cards/property_data_card.dart`

**Purpose:** Display extracted property data for review

**Interface:**
```dart
class PropertyDataCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final Function(String, dynamic)? onEdit;
  final VoidCallback? onConfirm;
  
  const PropertyDataCard({
    required this.propertyData,
    this.onEdit,
    this.onConfirm,
  });
}
```

**UI Components:**
- Organized sections (Basic, Financial, Location, Details)
- Edit button for each field
- Confirmation buttons
- Data validation indicators

#### C. Missing Fields Card

**Location:** `lib/widgets/chat/tool_cards/missing_fields_card.dart`

**Purpose:** Prompt user for missing required fields

**Interface:**
```dart
class MissingFieldsCard extends StatelessWidget {
  final List<String> missingFields;
  final Map<String, String> fieldHints;
  final Function(Map<String, dynamic>) onSubmit;
  
  const MissingFieldsCard({
    required this.missingFields,
    required this.fieldHints,
    required this.onSubmit,
  });
}
```

**UI Components:**
- List of missing required fields
- Hints for each field
- Input fields or prompts
- "Submit" button
- Field validation
- Error messages

#### D. Final Review Card

**Location:** `lib/widgets/chat/tool_cards/final_review_card.dart`

**Purpose:** Display complete property summary before listing

**Interface:**
```dart
class FinalReviewCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  
  const FinalReviewCard({
    required this.propertyData,
    required this.onConfirm,
    required this.onEdit,
  });
}
```

**UI Components:**
- Complete property summary
- All fields displayed
- Generated title and description
- "Confirm and List" button
- "Edit" button
- Terms and conditions checkbox

### 5. Other Tool Cards

#### A. Property Hunting Card

**Location:** `lib/widgets/chat/tool_cards/property_hunting_card.dart`

**Interface:**
```dart
class PropertyHuntingCard extends StatelessWidget {
  final String requestId;
  final String status;
  final Map<String, dynamic> searchCriteria;
  final Function(String)? onCheckStatus;
}
```

#### B. Commission Card

**Location:** `lib/widgets/chat/tool_cards/commission_card.dart`

**Interface:**
```dart
class CommissionCard extends StatelessWidget {
  final double amount;
  final String propertyReference;
  final DateTime dateEarned;
  final String status;
  final double totalEarnings;
}
```

#### C. Neighborhood Info Card

**Location:** `lib/widgets/chat/tool_cards/neighborhood_info_card.dart`

**Interface:**
```dart
class NeighborhoodInfoCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> keyFeatures;
  final double? safetyRating;
  final Map<String, double>? averageRent;
}
```

#### D. Affordability Card

**Location:** `lib/widgets/chat/tool_cards/affordability_card.dart`

**Interface:**
```dart
class AffordabilityCard extends StatelessWidget {
  final double monthlyIncome;
  final Map<String, double> recommendedRange;
  final double affordabilityPercentage;
  final Map<String, double> budgetBreakdown;
  final List<String> tips;
}
```

#### E. Auth Prompt Card

**Location:** `lib/widgets/chat/tool_cards/auth_prompt_card.dart`

**Interface:**
```dart
class AuthPromptCard extends StatelessWidget {
  final String message;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback? onContinueAsGuest;
}
```

### 6. Message Bubble Integration

**Location:** `lib/widgets/chat/message_bubble.dart` (update existing)

**Updates Required:**
- Render tool results after message content
- Pass `onSendMessage` callback to ToolResultWidget
- Handle multiple tool results per message
- Auto-scroll after tool result renders

**Updated Structure:**
```dart
class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String)? onSendMessage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Message content
        if (message.content.isNotEmpty)
          Text(message.content),
        
        // Tool results
        if (message.toolResults != null)
          ...message.toolResults!.map((toolResult) =>
            ToolResultWidget(
              toolResult: toolResult,
              onSendMessage: onSendMessage,
            ),
          ),
      ],
    );
  }
}
```

## Data Models

### Tool Result Model

**Location:** `lib/models/message.dart` (already exists)

```dart
class ToolResult {
  final String toolName;
  final Map<String, dynamic> result;
  
  ToolResult({
    required this.toolName,
    required this.result,
  });
}
```

### Property Model

**Location:** `lib/models/property.dart` (already exists)

Ensure it includes:
- Images list
- Amenities list
- All required fields for display

## Error Handling

### Error Types

1. **Missing Tool Result Data**
   - Display fallback card with raw data
   - Log error for debugging

2. **Invalid Tool Result Format**
   - Display error message in card
   - Provide "Report Issue" button

3. **Button Callback Errors**
   - Show error snackbar
   - Allow retry

4. **Image Loading Errors**
   - Show placeholder image
   - Display error icon

### Error Handling Strategy

```dart
Widget _buildToolResultCard(BuildContext context) {
  try {
    // Validate tool result data
    if (!_isValidToolResult(toolResult)) {
      return _buildFallbackCard(context);
    }
    
    // Render appropriate card
    return _renderCard(context);
  } catch (e) {
    // Log error
    debugPrint('Error rendering tool result: $e');
    
    // Show error card
    return ErrorCard(
      message: 'Failed to display result',
      onRetry: () => setState(() {}),
    );
  }
}
```

## Testing Strategy

### Widget Tests

**Tool Result Factory:**
- Test routing to correct card for each tool type
- Test fallback for unknown tool types
- Test callback passing

**Individual Cards:**
- Test each card renders correctly
- Test interactive buttons trigger callbacks
- Test error states display
- Test loading states display

### Integration Tests

**End-to-End Tool Result Flow:**
1. Send message that triggers tool
2. Receive tool result from backend
3. Verify correct card renders
4. Tap interactive button
5. Verify message sent

**Multiple Tool Results:**
- Test message with multiple tool results
- Verify all render correctly
- Verify scroll behavior

### Manual Testing

**Visual Testing:**
- Test all 15+ tool cards render correctly
- Test on different screen sizes
- Test in light and dark themes
- Test with long text content
- Test with missing optional fields

**Interaction Testing:**
- Test all buttons work
- Test phone number validation
- Test call/WhatsApp buttons
- Test image carousel
- Test error retry buttons

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**
   - Load images on demand
   - Use cached network images

2. **Widget Reuse**
   - Extract common components
   - Use const constructors where possible

3. **Efficient Rendering**
   - Avoid rebuilding entire card on state changes
   - Use keys for list items

4. **Memory Management**
   - Dispose controllers properly
   - Clear image cache when needed

## Styling and Theming

### Design System

**Card Styling:**
```dart
BoxDecoration cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).dividerColor,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}
```

**Button Styling:**
- Primary buttons: Filled with primary color
- Secondary buttons: Outlined with primary color
- Destructive buttons: Filled with error color

**Spacing:**
- Card padding: 16px
- Section spacing: 12px
- Element spacing: 8px

## Implementation Notes

### Phase 1: Core Infrastructure (Day 1)
- Create ToolResultWidget factory
- Update MessageBubble to render tool results
- Test basic routing

### Phase 2: Property Cards (Day 2)
- Enhance existing PropertyCard
- Create NoPropertiesFoundCard
- Test property search results

### Phase 3: Payment Flow Cards (Day 3)
- Create PhoneConfirmationCard
- Create PhoneInputCard
- Create ContactInfoCard
- Create PaymentErrorCard
- Test payment flow

### Phase 4: Submission Cards (Day 4)
- Create PropertySubmissionCard
- Create PropertyDataCard
- Create MissingFieldsCard
- Create FinalReviewCard
- Test submission workflow

### Phase 5: Other Cards (Day 5)
- Create remaining tool cards
- Test all tool types
- Polish and bug fixes

## Dependencies

### Required Packages

```yaml
dependencies:
  cached_network_image: ^3.3.0  # For image caching
  url_launcher: ^6.2.0  # For call/WhatsApp buttons
  flutter_svg: ^2.0.0  # For SVG icons (optional)
```

### Platform Configuration

**Android (AndroidManifest.xml):**
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.DIAL" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

**iOS (Info.plist):**
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>whatsapp</string>
</array>
```

## Future Enhancements

1. **Card Animations**
   - Slide-in animations for cards
   - Expand/collapse animations

2. **Advanced Interactions**
   - Swipe actions on cards
   - Long-press for options

3. **Offline Support**
   - Cache tool results
   - Display cached results when offline

4. **Accessibility**
   - Screen reader support
   - High contrast mode
   - Larger touch targets
