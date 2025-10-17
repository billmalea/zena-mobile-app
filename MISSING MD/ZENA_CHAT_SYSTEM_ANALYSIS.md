# ZENA CHAT SYSTEM - COMPLETE ANALYSIS
## Web vs Mobile Implementation Gap Analysis

**Date:** October 17, 2025  
**Analyzed By:** Kiro AI Assistant  
**Purpose:** Deep dive into chat architecture to identify missing features for seamless web-mobile experience

---

## EXECUTIVE SUMMARY

After thorough analysis of both web (`zena/app/chat` + `zena/app/api/chat`) and mobile (`zena_mobile_app`) implementations, I've identified **CRITICAL GAPS** that prevent feature parity between platforms. The web app has a sophisticated AI-powered tool system with 15+ tools, while the mobile app has a basic chat interface with minimal tool support.

### Key Findings:
- ✅ **Web App**: Fully functional with 15+ AI tools, streaming responses, file uploads, multi-turn workflows
- ⚠️ **Mobile App**: Basic chat with NO tool result rendering, NO file uploads, NO multi-turn workflows
- 🚨 **Gap**: ~70% of web features are missing in mobile

---

## PART 1: WEB APP ARCHITECTURE (COMPLETE)

### 1.1 API Layer (`zena/app/api/chat/route.ts`)

**Core Capabilities:**

1. **Message Processing**
   - Accepts both JSON and FormData (for file uploads)
   - Converts files to base64 data URLs using AI SDK format
   - Uploads files to Supabase Storage (`property-media` bucket)
   - Categorizes uploads as images or videos

2. **AI Integration**
   - Uses Google Gemini 2.5 Flash Lite model
   - Implements `streamText` from AI SDK for streaming responses
   - Temperature set to 0 for maximum consistency
   - Max output tokens: 2000

3. **Tool System**
   - **15+ Tools Available** (from `zena/lib/tools/index.ts`):
     - `searchProperties` / `smartSearch` - AI-powered property search with hunting offer
     - `requestContactInfo` - M-Pesa payment + contact delivery
     - `submitProperty` - Video-first 5-stage property submission
     - `completePropertySubmission` - Finalize property listing
     - `adminPropertyHunting` - Create hunting requests
     - `propertyHuntingStatus` - Check hunting status
     - `getNeighborhoodInfo` - Location intelligence
     - `calculateAffordability` - Rent affordability calculator
     - `checkPaymentStatus` - M-Pesa status checker
     - `confirmRentalSuccess` - Commission tracking
     - `getCommissionStatus` - Earnings checker
     - `getUserBalance` - Account balance
     - Plus enhanced search variants

4. **System Prompt Engineering**
   - Comprehensive 500+ character system prompt
   - User profile context injection (name, phone, email)
   - Conversation history (last 5 messages)
   - Tool-specific workflow instructions
   - Critical rules for tool usage

5. **Message Persistence**
   - Saves user messages immediately
   - Saves assistant messages with tool results in metadata
   - Stores tool calls and tool results separately
   - Retry logic for failed saves

6. **Conversation Management**
   - Creates/loads conversations via `/api/chat/conversation`
   - Tracks conversation ID in URL params
   - Supports conversation history loading
   - Browser navigation (back/forward) support


### 1.2 Frontend Layer (`zena/app/chat/page.tsx`)

**Core Capabilities:**

1. **Message Rendering**
   - User messages: Right-aligned, primary color
   - Assistant messages: Left-aligned, surface color
   - Tool results: Custom UI cards per tool type
   - Thinking indicator during AI processing

2. **Tool Result UI Components** (15+ specialized cards):
   - `PropertyCard` - Property listings with images, details, contact button
   - `PaymentStatusCard` - M-Pesa payment tracking with retry
   - `ContactInfoCard` - Agent contact info after payment
   - `PropertySubmissionCard` - Multi-stage submission progress
   - `PropertyDataCard` - Extracted video data for confirmation
   - `MissingFieldsCard` - Request missing property info
   - `FinalReviewCard` - Final property review before listing
   - `NoPropertiesFoundCard` - Property hunting offer
   - `PropertyHuntingRequestCard` - Hunting request status
   - `AuthPromptCard` - Login/signup prompts
   - `CommissionStatusCard` - Earnings display
   - `RentalSuccessCard` - Rental confirmation
   - `NeighborhoodInfo` - Location details
   - `AffordabilityCalculator` - Rent calculator
   - `ShimmerCard` - Loading states

3. **File Upload System**
   - Drag-and-drop support
   - File preview before sending
   - Progress indicators
   - Image and video support
   - Converts files to data URLs for AI SDK

4. **Conversation Features**
   - Sidebar with conversation list
   - New conversation button
   - Conversation switching
   - URL-based conversation routing
   - Auto-scroll to latest message
   - Message history persistence

5. **User Experience**
   - Suggested queries for new users
   - Empty state with helpful prompts
   - Error banners with dismiss/retry
   - Loading states and typing indicators
   - Responsive design (mobile + desktop)


### 1.3 Tool Implementation Deep Dive

#### Example: `submitProperty` Tool (Video-First Workflow)

**5-Stage Multi-Turn Process:**

1. **Stage 1: Start** (`action: 'start'`)
   - Creates submission state with unique ID
   - Returns video upload instructions
   - UI shows upload button

2. **Stage 2: Video Uploaded** (`action: 'video_uploaded'`)
   - Analyzes video with Gemini Video Analyzer
   - Validates video quality (duration, clarity, contact info detection)
   - Extracts 20+ property fields automatically:
     - Basic: propertyType, bedrooms, bathrooms, amenities
     - Financial: rentAmount, depositAmount, additionalCosts
     - Location: location (validated against Kenya location database)
     - Details: furnishingStatus, floorLevel, parkingSpaces, availabilityDate
     - Enhanced: viewType, buildingType, securityFeatures, waterSupply, etc.
   - Uses user profile phone if available
   - Returns extracted data for confirmation

3. **Stage 3: Confirm Data** (`action: 'confirm_data'`)
   - AI detects if user confirmed or made corrections
   - Extracts corrections using AI Info Extractor
   - Updates submission state
   - Identifies missing required fields
   - Returns missing fields list with hints

4. **Stage 4: Provide Info** (`action: 'provide_info'`)
   - AI extracts missing info from user message
   - Validates location against Kenya database
   - Generates title and description using AI
   - Returns final review data

5. **Stage 5: Final Confirm** (`action: 'final_confirm'`)
   - Calls `completePropertySubmission` tool
   - Saves property to database
   - Returns success with property card

**State Management:**
- Uses `SubmissionStateStore` for multi-turn tracking
- Stores: submissionId, userId, stage, video, aiExtracted, userProvided
- Persists state between tool calls
- Merges AI extracted + user provided data


#### Example: `requestContactInfo` Tool (Enhanced Payment Flow)

**Multi-Step Internal Process:**

1. **Property Validation**
   - Checks property exists and is available
   - Checks if user already paid (returns contact immediately)

2. **Phone Number Handling**
   - Checks user profile for phone number
   - If found: Returns confirmation UI with buttons
   - If not found: Requests phone number
   - Validates phone format (Kenyan numbers)

3. **Payment Initiation**
   - Creates payment record in database
   - Calls M-Pesa STK Push API directly
   - Returns CheckoutRequestID

4. **Payment Monitoring** (Internal Loop)
   - Polls M-Pesa status every 3 seconds
   - Max 10 attempts (30 seconds total)
   - Handles: success (0), cancelled (1, 1032, 1037), failed (2001-2003), processing (4999)

5. **Success Actions**
   - Updates user phone in profile
   - Sends WhatsApp notification to property owner
   - Waits 6 seconds (rate limit)
   - Sends property video to user via WhatsApp
   - Returns contact info

**Error Handling:**
- Cleans HTML/technical errors from M-Pesa responses
- Returns user-friendly error messages
- Categorizes errors: PROPERTY_NOT_FOUND, PAYMENT_FAILED, PAYMENT_TIMEOUT, etc.

---

## PART 2: MOBILE APP ARCHITECTURE (INCOMPLETE)

### 2.1 API Service (`lib/services/api_service.dart`)

**Current Implementation:**
- Basic HTTP client with authentication headers
- POST and GET methods
- SSE streaming support (parses `data:` lines)
- Timeout handling (30 seconds)
- Error categorization: ApiException, AuthException, NetworkException

**What's Working:**
✅ Authentication token injection  
✅ JSON request/response handling  
✅ SSE stream parsing  
✅ Basic error handling

**What's Missing:**
❌ File upload support (no FormData/multipart)  
❌ File-to-base64 conversion  
❌ Progress tracking for uploads  
❌ Retry logic for failed requests


### 2.2 Chat Service (`lib/services/chat_service.dart`)

**Current Implementation:**
- Sends messages with optional file URLs
- Streams responses as `ChatEvent` objects
- Event types: 'text', 'tool', 'error'
- Conversation CRUD operations

**What's Working:**
✅ Message sending  
✅ Response streaming  
✅ Conversation loading  
✅ Basic event parsing

**What's Missing:**
❌ File upload before sending message  
❌ File-to-data-URL conversion  
❌ Tool result parsing (only basic structure)  
❌ Multi-turn workflow state management  
❌ Conversation history in messages  
❌ Message persistence after streaming

### 2.3 Chat Provider (`lib/providers/chat_provider.dart`)

**Current Implementation:**
- Manages message list state
- Handles streaming responses
- Appends text chunks to assistant message
- Stores tool results in message metadata

**What's Working:**
✅ Message state management  
✅ Streaming text accumulation  
✅ Tool result storage  
✅ Error handling

**What's Missing:**
❌ Tool result UI rendering logic  
❌ Multi-turn workflow tracking  
❌ Submission state management  
❌ File upload state  
❌ Payment status polling  
❌ Conversation persistence


### 2.4 Chat Screen (`lib/screens/chat/chat_screen.dart`)

**Current Implementation:**
- Displays message bubbles (user + assistant)
- Shows typing indicator
- Handles property card rendering (basic)
- Auto-scroll to bottom
- Error banner
- New chat button

**What's Working:**
✅ Message list rendering  
✅ Auto-scroll behavior  
✅ Empty state  
✅ Error display  
✅ Basic property cards

**What's Missing:**
❌ 14+ specialized tool result cards  
❌ File upload UI  
❌ Multi-stage workflow UI  
❌ Payment status tracking UI  
❌ Phone confirmation buttons  
❌ Missing fields form  
❌ Video preview  
❌ Conversation sidebar  
❌ Suggested queries

### 2.5 Message Models (`lib/models/message.dart`)

**Current Implementation:**
```dart
class Message {
  String id, role, content;
  List<ToolResult>? toolResults;
  DateTime createdAt;
}

class ToolResult {
  String toolName;
  Map<String, dynamic> result;
}
```

**What's Working:**
✅ Basic message structure  
✅ Tool result storage

**What's Missing:**
❌ Message parts (text + file + tool)  
❌ Tool call metadata  
❌ Submission state tracking  
❌ File attachments  
❌ Message metadata (timestamp, status, etc.)


---

## PART 3: CRITICAL GAPS & MISSING FEATURES

### 3.1 File Upload System (CRITICAL)

**Web Implementation:**
- Drag-and-drop file picker
- File preview before sending
- Converts files to base64 data URLs
- Uploads to Supabase Storage
- Returns public URLs
- Supports images and videos

**Mobile Status:** ❌ **COMPLETELY MISSING**

**Required Implementation:**
1. Add `image_picker` package (already in pubspec.yaml ✅)
2. Create `FileUploadWidget` with:
   - Camera/gallery picker
   - File preview
   - Upload progress
   - File type validation
3. Update `ApiService` to support multipart/form-data
4. Convert files to base64 for AI SDK compatibility
5. Upload to Supabase Storage
6. Return file URLs in message

**Impact:** HIGH - Property submission requires video upload

---

### 3.2 Tool Result Rendering (CRITICAL)

**Web Implementation:**
- 15+ specialized UI cards
- Each tool has custom rendering logic
- Interactive buttons (confirm, retry, contact)
- Rich data display (images, videos, prices)

**Mobile Status:** ❌ **ONLY BASIC PROPERTY CARD**

**Required Implementation:**

1. **Property Search Results**
   - `PropertyCard` widget (exists but basic)
   - Enhance with: image carousel, amenities chips, contact button
   - Add `NoPropertiesFoundCard` for hunting offer

2. **Payment Flow**
   - `PaymentStatusCard` - M-Pesa payment tracking
   - `PhoneConfirmationCard` - Phone number confirmation buttons
   - `ContactInfoCard` - Agent contact after payment

3. **Property Submission**
   - `PropertySubmissionCard` - Stage progress indicator
   - `PropertyDataCard` - Extracted data review
   - `MissingFieldsCard` - Form for missing info
   - `FinalReviewCard` - Final confirmation
   - `VideoUploadCard` - Video upload instructions

4. **Other Tools**
   - `PropertyHuntingCard` - Hunting request status
   - `CommissionCard` - Earnings display
   - `NeighborhoodCard` - Location info
   - `AffordabilityCard` - Rent calculator
   - `AuthPromptCard` - Login/signup

**Impact:** CRITICAL - Users can't interact with tool results


---

### 3.3 Multi-Turn Workflow Support (CRITICAL)

**Web Implementation:**
- Tracks submission state across multiple tool calls
- Uses `submissionId` to link related calls
- Stores intermediate data (video, extracted fields, user corrections)
- Supports 5-stage property submission workflow

**Mobile Status:** ❌ **NO STATE TRACKING**

**Required Implementation:**

1. **Submission State Manager**
   ```dart
   class SubmissionStateManager {
     Map<String, SubmissionState> _states = {};
     
     SubmissionState? getState(String submissionId);
     void saveState(SubmissionState state);
     void clearState(String submissionId);
   }
   
   class SubmissionState {
     String submissionId;
     String userId;
     String stage; // 'start', 'video_uploaded', 'confirm_data', etc.
     VideoData? video;
     Map<String, dynamic>? aiExtracted;
     Map<String, dynamic>? userProvided;
   }
   ```

2. **Workflow UI Components**
   - Stage progress indicator (1/5, 2/5, etc.)
   - Back button to previous stage
   - Stage-specific instructions
   - Data persistence between stages

3. **Message Context Tracking**
   - Store `submissionId` in message metadata
   - Pass `submissionId` in subsequent tool calls
   - Link related messages visually

**Impact:** CRITICAL - Property submission won't work without this

---

### 3.4 Payment Status Polling (HIGH PRIORITY)

**Web Implementation:**
- Tool handles payment monitoring internally
- Polls M-Pesa status every 3 seconds
- Max 30 seconds timeout
- Returns contact info on success
- Shows payment status card with retry

**Mobile Status:** ❌ **NO POLLING MECHANISM**

**Required Implementation:**

1. **Payment Polling Service**
   ```dart
   class PaymentPollingService {
     Stream<PaymentStatus> pollPaymentStatus(String checkoutRequestId);
     Future<PaymentStatus> checkStatus(String checkoutRequestId);
   }
   ```

2. **Payment Status UI**
   - Real-time status updates
   - Progress indicator
   - Retry button on failure
   - Success animation
   - Error messages

3. **Background Polling**
   - Continue polling even if app is backgrounded
   - Show notification on payment success
   - Handle timeout gracefully

**Impact:** HIGH - Users can't complete property contact requests


---

### 3.5 Conversation Management (MEDIUM PRIORITY)

**Web Implementation:**
- Conversation sidebar with list
- URL-based conversation routing
- Browser back/forward support
- Conversation switching
- New conversation creation
- Conversation history loading

**Mobile Status:** ⚠️ **BASIC IMPLEMENTATION**

**Current Gaps:**
- No conversation list UI
- No conversation switching
- No conversation history display
- No conversation search

**Required Implementation:**

1. **Conversation List Screen**
   - Drawer or bottom sheet with conversations
   - Last message preview
   - Time ago display
   - Delete conversation
   - Search conversations

2. **Conversation Persistence**
   - Save conversations locally (SQLite)
   - Sync with backend
   - Offline support

3. **Navigation**
   - Deep linking to specific conversations
   - Share conversation link

**Impact:** MEDIUM - Improves UX but not blocking

---

### 3.6 Message Persistence (MEDIUM PRIORITY)

**Web Implementation:**
- Saves user messages immediately
- Saves assistant messages after streaming
- Stores tool results in metadata
- Retry logic for failed saves

**Mobile Status:** ❌ **NO PERSISTENCE AFTER STREAMING**

**Required Implementation:**

1. **Message Persistence Service**
   ```dart
   class MessagePersistenceService {
     Future<void> saveMessage(Message message, String conversationId);
     Future<List<Message>> loadMessages(String conversationId);
     Future<void> updateMessage(String messageId, Message message);
   }
   ```

2. **Streaming + Persistence**
   - Save message chunks during streaming
   - Update message when streaming completes
   - Save tool results in metadata

**Impact:** MEDIUM - Messages lost on app restart


---

### 3.7 User Experience Enhancements (LOW PRIORITY)

**Web Implementation:**
- Suggested queries for new users
- Empty state with helpful prompts
- Error banners with dismiss/retry
- Loading states and shimmer effects
- Responsive design
- Theme toggle (dark/light)

**Mobile Status:** ⚠️ **PARTIAL IMPLEMENTATION**

**Current Gaps:**
- No suggested queries
- Basic empty state
- No shimmer loading states
- No theme toggle

**Required Implementation:**

1. **Suggested Queries**
   - Show 6 suggested queries on empty state
   - Tap to send query
   - Contextual suggestions based on user history

2. **Loading States**
   - Shimmer cards for property loading
   - Skeleton screens for conversation loading
   - Progress indicators for file uploads

3. **Theme Support**
   - Dark/light theme toggle
   - System theme detection
   - Persist theme preference

**Impact:** LOW - Nice to have, not blocking

---

## PART 4: IMPLEMENTATION ROADMAP

### Phase 1: Critical Features (Week 1-2)

**Priority: CRITICAL - Blocking core functionality**

1. **File Upload System** (3-4 days)
   - [ ] Create `FileUploadWidget` with camera/gallery picker
   - [ ] Add file preview and validation
   - [ ] Implement multipart/form-data in `ApiService`
   - [ ] Add file-to-base64 conversion
   - [ ] Integrate Supabase Storage upload
   - [ ] Test with property video upload

2. **Tool Result Rendering** (4-5 days)
   - [ ] Create `PropertyCard` (enhanced)
   - [ ] Create `PaymentStatusCard`
   - [ ] Create `PhoneConfirmationCard`
   - [ ] Create `ContactInfoCard`
   - [ ] Create `PropertySubmissionCard`
   - [ ] Create `PropertyDataCard`
   - [ ] Create `MissingFieldsCard`
   - [ ] Create `FinalReviewCard`
   - [ ] Create `NoPropertiesFoundCard`
   - [ ] Update `MessageBubble` to render tool results

3. **Multi-Turn Workflow** (3-4 days)
   - [ ] Create `SubmissionStateManager`
   - [ ] Add `SubmissionState` model
   - [ ] Update `ChatProvider` to track submission state
   - [ ] Add stage progress UI
   - [ ] Test 5-stage property submission


### Phase 2: High Priority Features (Week 3)

**Priority: HIGH - Needed for complete user flows**

1. **Payment Status Polling** (2-3 days)
   - [ ] Create `PaymentPollingService`
   - [ ] Implement status polling with 3-second intervals
   - [ ] Add timeout handling (30 seconds)
   - [ ] Create payment status UI with progress
   - [ ] Add retry button on failure
   - [ ] Test M-Pesa payment flow end-to-end

2. **Remaining Tool Cards** (2-3 days)
   - [ ] Create `PropertyHuntingCard`
   - [ ] Create `CommissionCard`
   - [ ] Create `NeighborhoodCard`
   - [ ] Create `AffordabilityCard`
   - [ ] Create `AuthPromptCard`
   - [ ] Test all tool result rendering

### Phase 3: Medium Priority Features (Week 4)

**Priority: MEDIUM - Improves UX**

1. **Conversation Management** (2-3 days)
   - [ ] Create conversation list drawer
   - [ ] Add conversation switching
   - [ ] Implement conversation search
   - [ ] Add delete conversation
   - [ ] Test conversation navigation

2. **Message Persistence** (2 days)
   - [ ] Create `MessagePersistenceService`
   - [ ] Implement local storage (SQLite)
   - [ ] Add sync with backend
   - [ ] Test offline support

### Phase 4: Polish & Enhancements (Week 5)

**Priority: LOW - Nice to have**

1. **UX Enhancements** (2-3 days)
   - [ ] Add suggested queries
   - [ ] Implement shimmer loading states
   - [ ] Add theme toggle
   - [ ] Improve empty states
   - [ ] Add animations and transitions

2. **Testing & Bug Fixes** (2 days)
   - [ ] End-to-end testing
   - [ ] Fix bugs
   - [ ] Performance optimization
   - [ ] Documentation

---

## PART 5: DETAILED IMPLEMENTATION GUIDE

### 5.1 File Upload Implementation

**Step 1: Create FileUploadWidget**

```dart
// lib/widgets/chat/file_upload_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FileUploadWidget extends StatefulWidget {
  final Function(List<File>) onFilesSelected;
  
  const FileUploadWidget({
    super.key,
    required this.onFilesSelected,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedFiles = [];

  Future<void> _pickFromCamera() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 2),
    );
    
    if (video != null) {
      setState(() {
        _selectedFiles.add(File(video.path));
      });
      widget.onFilesSelected(_selectedFiles);
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> files = await _picker.pickMultipleMedia();
    
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(files.map((f) => File(f.path)));
      });
      widget.onFilesSelected(_selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // File preview
        if (_selectedFiles.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                return _buildFilePreview(_selectedFiles[index], index);
              },
            ),
          ),
        
        // Upload buttons
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilePreview(File file, int index) {
    // Implementation for file preview
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedFiles.removeAt(index);
              });
              widget.onFilesSelected(_selectedFiles);
            },
          ),
        ),
      ],
    );
  }
}
```


**Step 2: Update ApiService for File Upload**

```dart
// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ... existing code ...

  /// Upload files and send message
  Future<dynamic> postWithFiles(
    String endpoint,
    String message,
    List<File> files,
    String? conversationId,
  ) async {
    try {
      final url = Uri.parse('${AppConfig.apiUrl}$endpoint');
      final headers = await _getHeaders();
      
      // Remove Content-Type from headers (multipart will set it)
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      
      // Add message field
      request.fields['message'] = message;
      if (conversationId != null) {
        request.fields['conversationId'] = conversationId;
      }

      // Add files
      for (var file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: AppConfig.requestTimeout));

      if (streamedResponse.statusCode != 200) {
        throw ApiException(
          'Upload failed with status: ${streamedResponse.statusCode}',
          streamedResponse.statusCode,
        );
      }

      // Parse SSE stream
      return streamedResponse.stream.transform(utf8.decoder);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert file to base64 data URL (for AI SDK compatibility)
  Future<String> fileToDataUrl(File file) async {
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    final mimeType = _getMimeType(file.path);
    return 'data:$mimeType;base64,$base64';
  }

  String _getMimeType(String path) {
    if (path.endsWith('.mp4')) return 'video/mp4';
    if (path.endsWith('.mov')) return 'video/quicktime';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }
}
```


**Step 3: Update ChatService for File Upload**

```dart
// lib/services/chat_service.dart
import 'dart:io';

class ChatService {
  // ... existing code ...

  /// Send message with files
  Stream<ChatEvent> sendMessageWithFiles({
    required String message,
    required List<File> files,
    String? conversationId,
  }) async* {
    try {
      // Upload files and stream response
      final stream = await _apiService.postWithFiles(
        AppConfig.chatEndpoint,
        message,
        files,
        conversationId,
      );

      await for (final chunk in stream) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data.isNotEmpty && data != '[DONE]') {
              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                final type = json['type'] as String?;

                if (type == 'text') {
                  yield ChatEvent(
                    type: 'text',
                    content: json['content'] as String?,
                  );
                } else if (type == 'tool') {
                  yield ChatEvent(
                    type: 'tool',
                    toolResult: json['result'] as Map<String, dynamic>?,
                  );
                } else if (type == 'error') {
                  yield ChatEvent(
                    type: 'error',
                    content: json['message'] as String? ?? 'An error occurred',
                  );
                }
              } catch (e) {
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      yield ChatEvent(
        type: 'error',
        content: 'Failed to send message: ${e.toString()}',
      );
    }
  }
}
```

---

### 5.2 Tool Result Rendering Implementation

**Step 1: Create Tool Result Widget Factory**

```dart
// lib/widgets/chat/tool_result_widget.dart
import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'tool_cards/property_card.dart';
import 'tool_cards/payment_status_card.dart';
import 'tool_cards/phone_confirmation_card.dart';
import 'tool_cards/contact_info_card.dart';
// ... import other cards

class ToolResultWidget extends StatelessWidget {
  final ToolResult toolResult;
  final Function(String)? onSendMessage;

  const ToolResultWidget({
    super.key,
    required this.toolResult,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (toolResult.toolName) {
      case 'searchProperties':
        return _buildPropertySearchResults(context);
      
      case 'requestContactInfo':
        return _buildContactInfoResult(context);
      
      case 'submitProperty':
        return _buildPropertySubmissionResult(context);
      
      case 'adminPropertyHunting':
        return _buildPropertyHuntingResult(context);
      
      // ... other tools
      
      default:
        return _buildGenericToolResult(context);
    }
  }

  Widget _buildPropertySearchResults(BuildContext context) {
    final result = toolResult.result;
    
    // Handle no results with property hunting offer
    if (result['canTriggerPropertyHunting'] == true && 
        result['matchCount'] == 0) {
      return NoPropertiesFoundCard(
        searchCriteria: result['searchCriteria'] ?? {},
        suggestions: List<String>.from(result['suggestions'] ?? []),
        onStartPropertyHunting: () {
          onSendMessage?.call('Yes, help me find properties');
        },
        onAdjustSearch: () {
          onSendMessage?.call('Help me adjust my search criteria');
        },
      );
    }
    
    // Handle results found
    if (result['properties'] != null) {
      final properties = List<Map<String, dynamic>>.from(
        result['properties']
      );
      
      return Column(
        children: properties.map((property) {
          return PropertyCard(
            propertyData: property,
            onRequestContact: (propertyId) {
              onSendMessage?.call(
                'I want to contact the owner of property $propertyId'
              );
            },
          );
        }).toList(),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildContactInfoResult(BuildContext context) {
    final result = toolResult.result;
    
    // Payment initiated
    if (result['paymentInitiated'] == true) {
      return PaymentStatusCard(
        paymentId: result['paymentId'],
        propertyTitle: result['propertyTitle'],
        amount: result['amount'],
        message: result['message'],
        checkoutRequestId: result['checkoutRequestId'],
        phoneNumber: result['phoneNumber'],
        isPending: true,
        onTryAgain: () {
          onSendMessage?.call('Please try the payment again');
        },
      );
    }
    
    // Contact info received
    if (result['contactInfo'] != null) {
      return ContactInfoCard(
        contactInfo: result['contactInfo'],
        message: result['message'],
        alreadyPaid: result['alreadyPaid'] ?? false,
      );
    }
    
    // Phone confirmation needed
    if (result['needsPhoneConfirmation'] == true) {
      return PhoneConfirmationCard(
        message: result['message'],
        phoneNumber: result['userPhoneFromProfile'],
        onConfirm: () {
          onSendMessage?.call(
            'Yes, please use ${result['userPhoneFromProfile']} for the payment'
          );
        },
        onDecline: () {
          onSendMessage?.call(
            'No, I\'ll provide a different phone number'
          );
        },
      );
    }
    
    // Error
    if (result['error'] != null) {
      return ErrorCard(
        message: result['error'],
        errorType: result['errorType'],
      );
    }
    
    return const SizedBox.shrink();
  }

  // ... other tool result builders
}
```


**Step 2: Create Individual Tool Cards**

```dart
// lib/widgets/chat/tool_cards/payment_status_card.dart
import 'package:flutter/material.dart';

class PaymentStatusCard extends StatefulWidget {
  final String paymentId;
  final String propertyTitle;
  final int amount;
  final String message;
  final String checkoutRequestId;
  final String phoneNumber;
  final bool isPending;
  final VoidCallback onTryAgain;

  const PaymentStatusCard({
    super.key,
    required this.paymentId,
    required this.propertyTitle,
    required this.amount,
    required this.message,
    required this.checkoutRequestId,
    required this.phoneNumber,
    this.isPending = false,
    required this.onTryAgain,
  });

  @override
  State<PaymentStatusCard> createState() => _PaymentStatusCardState();
}

class _PaymentStatusCardState extends State<PaymentStatusCard> {
  bool _isPolling = false;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.isPending) {
      _startPolling();
    }
  }

  Future<void> _startPolling() async {
    setState(() {
      _isPolling = true;
    });

    // Poll payment status every 3 seconds for 30 seconds
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 3));
      
      // Check payment status
      final status = await _checkPaymentStatus();
      
      setState(() {
        _status = status;
      });

      if (status == 'completed' || status == 'failed') {
        setState(() {
          _isPolling = false;
        });
        break;
      }
    }

    if (_status == 'pending') {
      setState(() {
        _status = 'timeout';
        _isPolling = false;
      });
    }
  }

  Future<String> _checkPaymentStatus() async {
    // Call API to check payment status
    // This would use the PaymentPollingService
    return 'pending'; // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Payment Request',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Property info
            Text(
              widget.propertyTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),

            // Amount
            Text(
              'Amount: KSh ${widget.amount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Phone number
            Text(
              'Phone: ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Status indicator
            _buildStatusIndicator(),

            // Message
            const SizedBox(height: 12),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Retry button (if failed)
            if (_status == 'failed' || _status == 'timeout')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: widget.onTryAgain,
                  child: const Text('Try Again'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    IconData icon;
    Color color;
    String text;

    switch (_status) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        text = 'Waiting for payment...';
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Payment successful!';
        break;
      case 'failed':
        icon = Icons.error;
        color = Colors.red;
        text = 'Payment failed';
        break;
      case 'timeout':
        icon = Icons.access_time;
        color = Colors.grey;
        text = 'Payment verification timed out';
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        text = 'Unknown status';
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (_isPolling) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }
}
```


```dart
// lib/widgets/chat/tool_cards/phone_confirmation_card.dart
import 'package:flutter/material.dart';

class PhoneConfirmationCard extends StatelessWidget {
  final String message;
  final String phoneNumber;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  const PhoneConfirmationCard({
    super.key,
    required this.message,
    required this.phoneNumber,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number Confirmation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Yes, use this number'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Use different number'),
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

---

### 5.3 Multi-Turn Workflow Implementation

**Step 1: Create Submission State Manager**

```dart
// lib/services/submission_state_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SubmissionStateManager {
  static final SubmissionStateManager _instance = 
      SubmissionStateManager._internal();
  factory SubmissionStateManager() => _instance;
  SubmissionStateManager._internal();

  final Map<String, SubmissionState> _states = {};
  final _uuid = const Uuid();

  /// Create new submission state
  SubmissionState createNew(String userId) {
    final state = SubmissionState(
      submissionId: _uuid.v4(),
      userId: userId,
      stage: 'start',
      createdAt: DateTime.now(),
    );
    _states[state.submissionId] = state;
    _saveToStorage();
    return state;
  }

  /// Get submission state by ID
  SubmissionState? getState(String submissionId) {
    return _states[submissionId];
  }

  /// Save submission state
  void saveState(SubmissionState state) {
    _states[state.submissionId] = state;
    _saveToStorage();
  }

  /// Clear submission state
  void clearState(String submissionId) {
    _states.remove(submissionId);
    _saveToStorage();
  }

  /// Persist states to local storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = _states.map(
      (key, value) => MapEntry(key, value.toJson())
    );
    await prefs.setString('submission_states', jsonEncode(statesJson));
  }

  /// Load states from local storage
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = prefs.getString('submission_states');
    if (statesJson != null) {
      final decoded = jsonDecode(statesJson) as Map<String, dynamic>;
      _states.clear();
      decoded.forEach((key, value) {
        _states[key] = SubmissionState.fromJson(value);
      });
    }
  }
}

class SubmissionState {
  final String submissionId;
  final String userId;
  String stage; // 'start', 'video_uploaded', 'confirm_data', etc.
  VideoData? video;
  Map<String, dynamic>? aiExtracted;
  Map<String, dynamic>? userProvided;
  DateTime createdAt;
  DateTime? updatedAt;

  SubmissionState({
    required this.submissionId,
    required this.userId,
    required this.stage,
    this.video,
    this.aiExtracted,
    this.userProvided,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'userId': userId,
      'stage': stage,
      'video': video?.toJson(),
      'aiExtracted': aiExtracted,
      'userProvided': userProvided,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SubmissionState.fromJson(Map<String, dynamic> json) {
    return SubmissionState(
      submissionId: json['submissionId'],
      userId: json['userId'],
      stage: json['stage'],
      video: json['video'] != null 
          ? VideoData.fromJson(json['video']) 
          : null,
      aiExtracted: json['aiExtracted'],
      userProvided: json['userProvided'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}

class VideoData {
  final String url;
  final DateTime uploadedAt;

  VideoData({
    required this.url,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}
```


**Step 2: Update ChatProvider for Workflow Tracking**

```dart
// lib/providers/chat_provider.dart
import '../services/submission_state_manager.dart';

class ChatProvider with ChangeNotifier {
  // ... existing code ...
  
  final SubmissionStateManager _stateManager = SubmissionStateManager();
  String? _currentSubmissionId;

  String? get currentSubmissionId => _currentSubmissionId;

  /// Start property submission workflow
  Future<void> startPropertySubmission() async {
    final state = _stateManager.createNew(/* userId */);
    _currentSubmissionId = state.submissionId;
    notifyListeners();
  }

  /// Update submission state
  void updateSubmissionState(String submissionId, String stage) {
    final state = _stateManager.getState(submissionId);
    if (state != null) {
      state.stage = stage;
      state.updatedAt = DateTime.now();
      _stateManager.saveState(state);
      notifyListeners();
    }
  }

  /// Get current submission state
  SubmissionState? getCurrentSubmissionState() {
    if (_currentSubmissionId == null) return null;
    return _stateManager.getState(_currentSubmissionId!);
  }

  /// Clear submission state
  void clearSubmissionState() {
    if (_currentSubmissionId != null) {
      _stateManager.clearState(_currentSubmissionId!);
      _currentSubmissionId = null;
      notifyListeners();
    }
  }
}
```

---

## PART 6: TESTING CHECKLIST

### 6.1 File Upload Testing

- [ ] Camera video recording works
- [ ] Gallery video selection works
- [ ] Multiple file selection works
- [ ] File preview displays correctly
- [ ] File removal works
- [ ] Upload progress shows correctly
- [ ] Large files (>10MB) are rejected
- [ ] Invalid file types are rejected
- [ ] Files upload to Supabase Storage
- [ ] Public URLs are returned

### 6.2 Tool Result Rendering Testing

- [ ] Property cards display correctly
- [ ] Payment status card shows pending state
- [ ] Payment status card polls and updates
- [ ] Phone confirmation buttons work
- [ ] Contact info card displays after payment
- [ ] Property submission stages progress correctly
- [ ] Missing fields form works
- [ ] Final review shows all data
- [ ] Property hunting card displays
- [ ] Commission card shows earnings
- [ ] All tool cards handle errors gracefully

### 6.3 Multi-Turn Workflow Testing

- [ ] Submission state persists between messages
- [ ] Stage progression works correctly
- [ ] Data carries forward between stages
- [ ] User can go back to previous stage
- [ ] Submission state clears on completion
- [ ] Multiple submissions can run concurrently
- [ ] State persists after app restart

### 6.4 Payment Flow Testing

- [ ] Payment initiation works
- [ ] STK push is received on phone
- [ ] Payment status polls correctly
- [ ] Success state shows contact info
- [ ] Failed state shows retry button
- [ ] Timeout is handled gracefully
- [ ] Cancelled payment is detected
- [ ] Already paid users get contact immediately

### 6.5 End-to-End Testing

- [ ] Complete property search flow
- [ ] Complete property submission flow (5 stages)
- [ ] Complete contact request flow (with payment)
- [ ] Complete property hunting flow
- [ ] Conversation switching works
- [ ] Message persistence works
- [ ] Offline mode works (basic)
- [ ] App doesn't crash on errors

---

## PART 7: SUMMARY & RECOMMENDATIONS

### Critical Gaps Identified:

1. **File Upload System** - BLOCKING property submission
2. **Tool Result Rendering** - BLOCKING user interaction with AI responses
3. **Multi-Turn Workflows** - BLOCKING property submission workflow
4. **Payment Status Polling** - BLOCKING contact request completion

### Estimated Implementation Time:

- **Phase 1 (Critical):** 10-13 days
- **Phase 2 (High Priority):** 4-6 days
- **Phase 3 (Medium Priority):** 4-5 days
- **Phase 4 (Polish):** 4-5 days

**Total:** 22-29 days (4-6 weeks)

### Recommended Approach:

1. **Start with Phase 1** - Get core features working
2. **Test thoroughly** - Each feature should be tested before moving on
3. **Iterate based on feedback** - User testing will reveal issues
4. **Don't skip Phase 2** - Payment flow is critical for revenue
5. **Phase 3 & 4 can be done in parallel** - Split team if possible

### Success Metrics:

- ✅ Users can upload property videos
- ✅ Users can complete 5-stage property submission
- ✅ Users can request contact info and pay via M-Pesa
- ✅ Users can see all tool results with proper UI
- ✅ Users can switch between conversations
- ✅ Messages persist after app restart
- ✅ 90%+ feature parity with web app

---

## CONCLUSION

The mobile app has a solid foundation but is missing **70% of the web app's features**. The most critical gaps are:

1. File upload system
2. Tool result rendering
3. Multi-turn workflow support
4. Payment status polling

These features are **BLOCKING** core user flows like property submission and contact requests. Without them, the mobile app cannot provide the same value as the web app.

The good news: The architecture is sound, and the implementation is straightforward. With focused effort over 4-6 weeks, the mobile app can achieve feature parity with the web app.

**Next Steps:**
1. Review this analysis with the team
2. Prioritize features based on business impact
3. Start Phase 1 implementation
4. Set up testing environment
5. Begin user testing as features are completed

---

**Document Version:** 1.0  
**Last Updated:** October 17, 2025  
**Status:** Complete Analysis - Ready for Implementation
