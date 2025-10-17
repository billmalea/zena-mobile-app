---
title: Multi-Turn Workflow State Management
priority: CRITICAL
estimated_effort: 3-4 days
status: pending
dependencies: [01-file-upload-system, 02-tool-result-rendering]
---

# Multi-Turn Workflow State Management

## Overview
Implement state tracking for multi-turn AI workflows, specifically the 5-stage property submission process. This is CRITICAL - property submission requires maintaining state across multiple user interactions.

## Current State
- ❌ No submission state tracking
- ❌ No workflow stage management
- ❌ No state persistence between messages
- ❌ No submission ID linking

## Requirements

### 1. Submission State Model
Create `lib/models/submission_state.dart`

**Features:**
- Track submission ID (unique identifier)
- Track user ID
- Track current stage (start, video_uploaded, confirm_data, provide_info, final_confirm)
- Store video data (URL, analysis results)
- Store AI extracted data
- Store user provided data
- Store missing fields list
- Track timestamps

**Model Structure:**
```dart
class SubmissionState {
  final String submissionId;
  final String userId;
  final String stage;
  final VideoData? video;
  final Map<String, dynamic>? aiExtracted;
  final Map<String, dynamic>? userProvided;
  final List<String>? missingFields;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class VideoData {
  final String url;
  final String? publicUrl;
  final Map<String, dynamic>? analysisResults;
  final int? duration;
  final String? quality;
}
```

### 2. Submission State Manager
Create `lib/services/submission_state_manager.dart`

**Features:**
- Create new submission state
- Get submission state by ID
- Update submission state
- Clear submission state on completion
- Persist state locally (SharedPreferences)
- Sync state with backend (optional)

**Methods:**
```dart
SubmissionState createNew(String userId)
SubmissionState? getState(String submissionId)
Future<void> saveState(SubmissionState state)
Future<void> updateStage(String submissionId, String stage)
Future<void> updateVideoData(String submissionId, VideoData video)
Future<void> updateAIExtracted(String submissionId, Map<String, dynamic> data)
Future<void> updateUserProvided(String submissionId, Map<String, dynamic> data)
Future<void> clearState(String submissionId)
List<SubmissionState> getAllActiveStates()
```

### 3. Chat Provider Enhancement
Update `lib/providers/chat_provider.dart`

**Features:**
- Track current submission ID
- Start new submission workflow
- Update submission state on each stage
- Pass submission ID in tool calls
- Clear submission on completion
- Handle submission errors

**State Management:**
```dart
final SubmissionStateManager _stateManager = SubmissionStateManager();
String? _currentSubmissionId;

String? get currentSubmissionId => _currentSubmissionId;
SubmissionState? get currentSubmissionState => 
  _currentSubmissionId != null 
    ? _stateManager.getState(_currentSubmissionId!) 
    : null;

void startSubmission() {
  final state = _stateManager.createNew(userId);
  _currentSubmissionId = state.submissionId;
  notifyListeners();
}

void updateSubmissionStage(String stage) {
  if (_currentSubmissionId != null) {
    _stateManager.updateStage(_currentSubmissionId!, stage);
    notifyListeners();
  }
}

void completeSubmission() {
  if (_currentSubmissionId != null) {
    _stateManager.clearState(_currentSubmissionId!);
    _currentSubmissionId = null;
    notifyListeners();
  }
}
```

### 4. Workflow UI Components

#### A. Stage Progress Indicator
Create `lib/widgets/chat/workflow/stage_progress_indicator.dart`

**Features:**
- Show current stage (1/5, 2/5, etc.)
- Visual progress bar
- Stage names
- Completed stages checkmarks
- Current stage highlight

#### B. Workflow Navigation
Create `lib/widgets/chat/workflow/workflow_navigation.dart`

**Features:**
- Back button (if applicable)
- Cancel workflow button
- Stage-specific help text
- Workflow status badge

### 5. Property Submission Workflow Integration

**5-Stage Process:**

#### Stage 1: Start
- User initiates property submission
- Create submission state with unique ID
- Show video upload instructions
- Display upload button

#### Stage 2: Video Uploaded
- User uploads video
- Update state with video data
- AI analyzes video (backend)
- Show "Analyzing..." indicator
- Display extracted data for confirmation

#### Stage 3: Confirm Data
- Show extracted property data
- User confirms or makes corrections
- Update state with user corrections
- Identify missing required fields
- Show missing fields list

#### Stage 4: Provide Info
- Show missing fields form
- User provides missing information
- Update state with user provided data
- AI generates title and description
- Show final review

#### Stage 5: Final Confirm
- Show complete property summary
- User confirms final listing
- Call `completePropertySubmission` tool
- Clear submission state
- Show success message

### 6. Message Context Tracking
Update `lib/models/message.dart`

**Features:**
- Add `submissionId` field to message metadata
- Link related messages visually
- Show workflow context in message

**Model Update:**
```dart
class Message {
  // ... existing fields ...
  final Map<String, dynamic>? metadata;
  
  String? get submissionId => metadata?['submissionId'];
  String? get workflowStage => metadata?['workflowStage'];
}
```

## Implementation Tasks

### Phase 1: State Models & Manager (Day 1)
- [ ] Create `submission_state.dart` model
- [ ] Create `submission_state_manager.dart`
- [ ] Implement state CRUD operations
- [ ] Add local persistence (SharedPreferences)
- [ ] Test state management

### Phase 2: Chat Provider Integration (Day 2)
- [ ] Update ChatProvider with submission tracking
- [ ] Add submission lifecycle methods
- [ ] Update message sending with submission context
- [ ] Test state updates during workflow

### Phase 3: Workflow UI Components (Day 3)
- [ ] Create stage progress indicator
- [ ] Create workflow navigation
- [ ] Update property submission cards with workflow UI
- [ ] Test workflow UI

### Phase 4: End-to-End Integration (Day 4)
- [ ] Integrate all 5 stages
- [ ] Test complete property submission flow
- [ ] Handle errors and edge cases
- [ ] Test state persistence
- [ ] Test multiple concurrent submissions

## Testing Checklist

### Unit Tests
- [ ] Submission state creation
- [ ] State updates
- [ ] State persistence
- [ ] State retrieval
- [ ] State clearing

### Widget Tests
- [ ] Stage progress indicator displays correctly
- [ ] Workflow navigation works
- [ ] Stage-specific UI renders

### Integration Tests
- [ ] Complete 5-stage workflow
- [ ] State persists between messages
- [ ] State clears on completion
- [ ] Multiple submissions don't interfere
- [ ] Error handling works

### Manual Tests
- [ ] Start property submission
- [ ] Upload video (Stage 1 → 2)
- [ ] Confirm extracted data (Stage 2 → 3)
- [ ] Provide missing info (Stage 3 → 4)
- [ ] Final confirmation (Stage 4 → 5)
- [ ] State persists after app restart
- [ ] Cancel workflow works
- [ ] Error recovery works

## Success Criteria
- ✅ Submission state tracks across all 5 stages
- ✅ State persists between messages
- ✅ State persists after app restart
- ✅ Users can complete full property submission
- ✅ Multiple submissions can be tracked simultaneously
- ✅ Errors are handled gracefully
- ✅ State clears on completion

## Dependencies
- File upload system (for video upload)
- Tool result rendering (for stage-specific UI)
- Message model with metadata support
- SharedPreferences for local persistence

## Notes
- This is CRITICAL for property submission workflow
- State must persist even if app is closed
- Each submission needs unique ID
- Backend must support submission ID in tool calls
- Consider syncing state with backend for reliability

## Reference Files
- Web implementation: `zena/lib/tools/submit-property.ts` (5-stage workflow)
- State management: `zena/lib/tools/submission-state-store.ts`
- Code examples: `zena_mobile_app/MISSING MD/MOBILE_APP_CRITICAL_CODE_EXAMPLES.md`
