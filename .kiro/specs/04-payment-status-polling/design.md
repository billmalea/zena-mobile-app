# Design Document

## Overview

The Contact Info Request Flow provides UI for users to request property owner contact information through M-Pesa payment. **The backend handles ALL payment polling internally** - the mobile app only displays UI cards based on tool results. This significantly simplifies the implementation compared to the original plan.

**Key Insight:** The backend's `enhancedRequestContactInfoTool` polls M-Pesa status every 3 seconds for up to 30 seconds and returns the final result. The mobile app simply displays the appropriate card based on the result - no polling, no background services, no complex state management needed.

**Effort Reduction:** 50% reduction in complexity (from 2-3 days to 1-2 days).

## Architecture

### Simplified Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App                           │
│                                                         │
│  User Action                                            │
│      │                                                  │
│      ▼                                                  │
│  Send Message ──────────────────────┐                  │
│                                     │                  │
│                                     ▼                  │
│                              Backend API               │
│                                     │                  │
│                                     ▼                  │
│                    enhancedRequestContactInfoTool      │
│                                     │                  │
│                    ┌────────────────┼────────────────┐ │
│                    ▼                ▼                ▼ │
│              Check Property   Initiate STK    Monitor  │
│              Availability     Push Payment    Status   │
│                                                (polls   │
│                                                 every   │
│                                                 3s for  │
│                                                 30s)    │
│                                     │                  │
│                                     ▼                  │
│                              Return Result             │
│                                     │                  │
│                                     ▼                  │
│  Display Appropriate Card ◄─────────┘                  │
│  (Phone Confirm / Contact Info / Error)                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Tool Result Flow

```
Backend Tool Result
        │
        ▼
┌───────────────────────────────────────┐
│  Tool Result Widget Factory           │
│                                       │
│  if (needsPhoneConfirmation)          │
│    → PhoneConfirmationCard            │
│                                       │
│  else if (needsPhoneNumber)           │
│    → PhoneInputCard                   │
│                                       │
│  else if (success && contactInfo)     │
│    → ContactInfoCard                  │
│                                       │
│  else if (!success && error)          │
│    → PaymentErrorCard                 │
│                                       │
└───────────────────────────────────────┘
```

## Components and Interfaces

### 1. Phone Confirmation Card

**Location:** `lib/widgets/chat/tool_cards/phone_confirmation_card.dart`

**Purpose:** Confirm user's phone number before initiating payment

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
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property info
            Text(property['title']),
            Text('Commission: KES ${property['commission_amount']}'),
            
            SizedBox(height: 16),
            
            // Phone confirmation
            Text('Confirm your phone number:'),
            Text(phoneNumber, style: TextStyle(fontWeight: FontWeight.bold)),
            
            SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: Text('Yes, use this number'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: Text('No, use different'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  2BR Apartment in Westlands     │
│  Commission: KES 5,000          │
│                                 │
│  Confirm your phone number:     │
│  +254 712 345 678               │
│                                 │
│  [Yes, use this number]         │
│  [No, use different number]     │
└─────────────────────────────────┘
```

### 2. Phone Input Card

**Location:** `lib/widgets/chat/tool_cards/phone_input_card.dart`

**Purpose:** Collect phone number if not in profile

**Interface:**
```dart
class PhoneInputCard extends StatefulWidget {
  final String message;
  final Map<String, dynamic> property;
  final Function(String) onSubmit;
  
  const PhoneInputCard({
    required this.message,
    required this.property,
    required this.onSubmit,
  });
  
  @override
  State<PhoneInputCard> createState() => _PhoneInputCardState();
}

class _PhoneInputCardState extends State<PhoneInputCard> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  
  bool get _isValid {
    final phone = _controller.text.trim();
    // Kenyan phone format: +254... or 07... or 01...
    return RegExp(r'^(\+254|0)[17]\d{8}$').hasMatch(phone);
  }
  
  void _handleSubmit() {
    if (!_isValid) {
      setState(() {
        _error = 'Please enter a valid Kenyan phone number';
      });
      return;
    }
    
    String phone = _controller.text.trim();
    // Normalize to +254 format
    if (phone.startsWith('0')) {
      phone = '+254${phone.substring(1)}';
    }
    
    widget.onSubmit(phone);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            SizedBox(height: 16),
            
            // Phone input
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+254 712 345 678',
                errorText: _error,
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            
            SizedBox(height: 16),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _handleSubmit : null,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  Please provide your phone      │
│  number to proceed with payment │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 📱 +254 712 345 678       │ │
│  └───────────────────────────┘ │
│                                 │
│  [Submit]                       │
└─────────────────────────────────┘
```

### 3. Contact Info Card

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
  
  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  
  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove + and spaces
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final phone = contactInfo['phone'] as String?;
    final agentPhone = contactInfo['agentPhone'] as String?;
    final email = contactInfo['email'] as String?;
    final propertyTitle = contactInfo['propertyTitle'] as String?;
    final videoUrl = contactInfo['videoUrl'] as String?;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success message
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Property info
            if (propertyTitle != null) ...[
              Text(propertyTitle, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
            ],
            
            // Contact details
            if (agentPhone != null) ...[
              Text('Agent Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              
              // Phone with call button
              Row(
                children: [
                  Icon(Icons.phone, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(agentPhone)),
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () => _makeCall(agentPhone),
                    tooltip: 'Call',
                  ),
                  IconButton(
                    icon: Icon(Icons.chat),
                    onPressed: () => _openWhatsApp(agentPhone),
                    tooltip: 'WhatsApp',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
            
            // Email
            if (email != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(email)),
                ],
              ),
            ],
            
            // Payment info
            if (paymentInfo != null && !alreadyPaid) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text('Payment Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Amount: KES ${paymentInfo['amount']}'),
              if (paymentInfo['receiptNumber'] != null)
                Text('Receipt: ${paymentInfo['receiptNumber']}'),
            ],
            
            // Video link
            if (videoUrl != null) ...[
              SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(videoUrl)),
                icon: Icon(Icons.video_library),
                label: Text('View Property Video'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  ✓ Payment successful!          │
│                                 │
│  2BR Apartment in Westlands     │
│                                 │
│  Agent Contact:                 │
│  📱 +254 712 345 678            │
│     [📞 Call] [💬 WhatsApp]    │
│                                 │
│  ✉️ agent@example.com           │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Payment Details:               │
│  Amount: KES 5,000              │
│  Receipt: ABC123456             │
│                                 │
│  [📹 View Property Video]       │
└─────────────────────────────────┘
```

### 4. Payment Error Card

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
  
  IconData get _errorIcon {
    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return Icons.cancel;
      case 'PAYMENT_TIMEOUT':
        return Icons.access_time;
      case 'PAYMENT_FAILED':
      case 'PAYMENT_PROCESSING_ERROR':
      default:
        return Icons.error;
    }
  }
  
  Color get _errorColor {
    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return Colors.orange;
      case 'PAYMENT_TIMEOUT':
        return Colors.blue;
      case 'PAYMENT_FAILED':
      case 'PAYMENT_PROCESSING_ERROR':
      default:
        return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header
            Row(
              children: [
                Icon(_errorIcon, color: _errorColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _errorColor,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Error message
            Text(error),
            
            SizedBox(height: 16),
            
            // Property info
            Text(
              property['title'] ?? 'Property',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (paymentInfo != null)
              Text('Amount: KES ${paymentInfo['amount']}'),
            
            SizedBox(height: 16),
            
            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  ⚠️ Payment Failed              │
│                                 │
│  Payment was cancelled by user  │
│                                 │
│  2BR Apartment in Westlands     │
│  Amount: KES 5,000              │
│                                 │
│  [🔄 Try Again]                 │
└─────────────────────────────────┘
```

### 5. Tool Result Factory Integration

**Location:** `lib/widgets/chat/tool_result_widget.dart` (update)

**Add handling for `requestContactInfo` tool:**

```dart
Widget _buildContactInfoResult(BuildContext context) {
  final result = toolResult.result;
  
  // Phone confirmation needed
  if (result['needsPhoneConfirmation'] == true) {
    return PhoneConfirmationCard(
      phoneNumber: result['userPhoneFromProfile'] as String,
      message: result['message'] as String,
      property: result['property'] as Map<String, dynamic>,
      onConfirm: () => onSendMessage?.call(
        'Yes, please use ${result['userPhoneFromProfile']} for the payment'
      ),
      onDecline: () => onSendMessage?.call(
        'No, I\'ll provide a different phone number'
      ),
    );
  }
  
  // Phone number needed
  if (result['needsPhoneNumber'] == true) {
    return PhoneInputCard(
      message: result['message'] as String,
      property: result['property'] as Map<String, dynamic>,
      onSubmit: (phone) => onSendMessage?.call(
        'My phone number is $phone'
      ),
    );
  }
  
  // Success - show contact info
  if (result['success'] == true && result['contactInfo'] != null) {
    return ContactInfoCard(
      contactInfo: result['contactInfo'] as Map<String, dynamic>,
      paymentInfo: result['paymentInfo'] as Map<String, dynamic>?,
      message: result['message'] as String,
      alreadyPaid: result['alreadyPaid'] as bool? ?? false,
    );
  }
  
  // Error - show error card
  if (result['success'] == false && result['error'] != null) {
    return PaymentErrorCard(
      error: result['error'] as String,
      errorType: result['errorType'] as String?,
      property: result['property'] as Map<String, dynamic>,
      paymentInfo: result['paymentInfo'] as Map<String, dynamic>?,
      onRetry: () => onSendMessage?.call(
        'Please try the payment again'
      ),
    );
  }
  
  // Fallback
  return SizedBox.shrink();
}
```

## Data Models

### Tool Result Examples

**Phone Confirmation:**
```json
{
  "toolName": "requestContactInfo",
  "result": {
    "success": false,
    "needsPhoneConfirmation": true,
    "message": "I can see you have +254712345678 on file. Should I proceed with this number?",
    "userPhoneFromProfile": "+254712345678",
    "property": {
      "id": "prop_123",
      "title": "2BR Apartment in Westlands",
      "commission_amount": 5000
    }
  }
}
```

**Payment Success:**
```json
{
  "toolName": "requestContactInfo",
  "result": {
    "success": true,
    "message": "Payment successful! The property agent is now contacting you.",
    "contactInfo": {
      "phone": "+254712345678",
      "email": "owner@example.com",
      "propertyTitle": "2BR Apartment",
      "propertyLocation": "Westlands",
      "rentAmount": 50000,
      "agentPhone": "+254712345678",
      "videoUrl": "https://..."
    },
    "paymentInfo": {
      "amount": 5000,
      "status": "completed",
      "transactionId": "ABC123",
      "receiptNumber": "XYZ789"
    }
  }
}
```

**Payment Error:**
```json
{
  "toolName": "requestContactInfo",
  "result": {
    "success": false,
    "error": "Payment was cancelled: User cancelled transaction",
    "errorType": "PAYMENT_CANCELLED",
    "property": {
      "id": "prop_123",
      "title": "2BR Apartment in Westlands",
      "commission_amount": 5000
    },
    "paymentInfo": {
      "amount": 5000,
      "status": "cancelled",
      "failureReason": "User cancelled"
    }
  }
}
```

## Error Handling

### Error Types

1. **PAYMENT_CANCELLED** - User cancelled on phone
2. **PAYMENT_TIMEOUT** - No response after 30s
3. **PAYMENT_FAILED** - System error
4. **PAYMENT_PROCESSING_ERROR** - General error

### User-Friendly Messages

```dart
String _getUserFriendlyError(String errorType, String error) {
  switch (errorType) {
    case 'PAYMENT_CANCELLED':
      return 'You cancelled the payment on your phone. Would you like to try again?';
    case 'PAYMENT_TIMEOUT':
      return 'Payment verification timed out. Please check your phone and try again.';
    case 'PAYMENT_FAILED':
      return 'Payment failed. Please check your M-Pesa balance and try again.';
    default:
      return error; // Use backend error message
  }
}
```

## Testing Strategy

### Widget Tests

**Phone Confirmation Card:**
- Test renders with phone number
- Test confirm button triggers callback
- Test decline button triggers callback

**Phone Input Card:**
- Test phone validation
- Test submit button enables/disables
- Test Kenyan phone format normalization

**Contact Info Card:**
- Test displays all contact details
- Test call button opens dialer
- Test WhatsApp button opens WhatsApp

**Payment Error Card:**
- Test displays error message
- Test retry button triggers callback
- Test different error types show correct icons

### Integration Tests

**Complete Flow:**
1. Request contact info
2. Confirm phone number
3. Wait for backend (shows loading)
4. Receive success result
5. Display contact info card
6. Test call/WhatsApp buttons

**Error Flow:**
1. Request contact info
2. Confirm phone number
3. Simulate payment cancellation
4. Display error card
5. Tap retry
6. Verify retry message sent

### Manual Testing (Real M-Pesa)

**Success Scenario:**
1. Request contact info for property
2. Confirm phone number
3. Complete M-Pesa payment on phone
4. Verify contact info displays
5. Test call button
6. Test WhatsApp button

**Cancellation Scenario:**
1. Request contact info
2. Confirm phone number
3. Cancel M-Pesa prompt on phone
4. Verify error card displays
5. Tap retry
6. Complete payment
7. Verify success

## Dependencies

### Required Packages

```yaml
dependencies:
  url_launcher: ^6.2.0  # For call/WhatsApp buttons
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

## Implementation Notes

### Phase 1: UI Cards (Day 1)
- Create PhoneConfirmationCard
- Create PhoneInputCard
- Create ContactInfoCard
- Create PaymentErrorCard
- Test individual cards

### Phase 2: Integration (Day 1-2)
- Update ToolResultWidget factory
- Add requestContactInfo case
- Test all flows
- Test with real M-Pesa

## Key Simplifications

**What We DON'T Need:**
- ❌ Payment polling service
- ❌ Payment status API calls
- ❌ Countdown timer
- ❌ Background service
- ❌ Real-time status updates
- ❌ Payment state management

**What We DO Need:**
- ✅ 4 simple UI cards
- ✅ Tool result routing
- ✅ Button callbacks
- ✅ Phone validation

**Result:** 50% less code, 50% less complexity, 50% less time!
