# Design Document

## Overview

The Multi-Turn Workflow State Management system enables tracking of complex, multi-stage interactions, specifically the 5-stage property submission process. The system maintains state across multiple user messages and AI responses, ensuring data persistence and workflow continuity even if the app restarts or the user navigates away.

**Current State:** No workflow state management exists. Need to implement complete state tracking system.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Chat Screen                          │
│                         │                               │
│                         ▼                               │
│                  Chat Provider                          │
│                         │                               │
│         ┌───────────────┼───────────────┐              │
│         ▼               ▼               ▼              │
│   Chat Service   Submission State   File Upload        │
│                     Manager                             │
│                         │                               │
│                         ▼                               │
│              ┌──────────────────────┐                  │
│              │  SharedPreferences   │                  │
│              │  (Local Storage)     │                  │
│              └──────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
```

### State Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                 5-Stage Submission Flow                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. START                                               │
│     ├─ Create submission state                         │
│     ├─ Generate unique submission ID                   │
│     └─ Show video upload instructions                  │
│                    │                                    │
│                    ▼                                    │
│  2. VIDEO_UPLOADED                                      │
│     ├─ Store video URL                                 │
│     ├─ AI analyzes video (backend)                     │
│     └─ Store analysis results                          │
│                    │                                    │
│                    ▼                                    │
│  3. CONFIRM_DATA                                        │
│     ├─ Display extracted data                          │
│     ├─ User confirms or corrects                       │
│     ├─ Store user corrections                          │
│     └─ Identify missing fields                         │
│                    │                                    │
│                    ▼                                    │
│  4. PROVIDE_INFO                                        │
│     ├─ Display missing fields form                     │
│     ├─ User provides missing data                      │
│     ├─ Store provided data                             │
│     └─ AI generates title/description                  │
│                    │                                    │
│                    ▼                                    │
│  5. FINAL_CONFIRM                                       │
│     ├─ Display complete summary                        │
│     ├─ User confirms listing                           │
│     ├─ Call completePropertySubmission                 │
│     └─ Clear submission state                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Submission State Model

**Location:** `lib/models/submission_state.dart`

**Purpose:** Data model for tracking submission workflow state

**Interface:**
```dart
class SubmissionState {
  final String submissionId;
  final String userId;
  final SubmissionStage stage;
  final VideoData? video;
  final Map<String, dynamic>? aiExtracted;
  final Map<String, dynamic>? userProvided;
  final List<String>? missingFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  SubmissionState({
    required this.submissionId,
    required this.userId,
    required this.stage,
    this.video,
    this.aiExtracted,
    this.userProvided,
    this.missingFields,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Serialization
  Map<String, dynamic> toJson();
  factory SubmissionState.fromJson(Map<String, dynamic> json);
  
  // Copy with
  SubmissionState copyWith({...});
  
  // Computed properties
  double get progress => _calculateProgress();
  bool get isComplete => stage == SubmissionStage.finalConfirm;
  Map<String, dynamic> get allData => {...?aiExtracted, ...?userProvided};
}

enum SubmissionStage {
  start,
  videoUploaded,
  confirmData,
  provideInfo,
  finalConfirm,
}

class VideoData {
  final String url;
  final String? publicUrl;
  final Map<String, dynamic>? analysisResults;
  final int? duration;
  final String? quality;
  
  VideoData({
    required this.url,
    this.publicUrl,
    this.analysisResults,
    this.duration,
    this.quality,
  });
  
  Map<String, dynamic> toJson();
  factory VideoData.fromJson(Map<String, dynamic> json);
}
```

### 2. Submission State Manager

**Location:** `lib/services/submission_state_manager.dart`

**Purpose:** Service for managing submission state persistence and retrieval

**Interface:**
```dart
class SubmissionStateManager {
  static const String _storageKey = 'submission_states';
  final SharedPreferences _prefs;
  
  SubmissionStateManager(this._prefs);
  
  /// Create new submission state
  SubmissionState createNew(String userId) {
    final submissionId = _generateSubmissionId();
    final state = SubmissionState(
      submissionId: submissionId,
      userId: userId,
      stage: SubmissionStage.start,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    saveState(state);
    return state;
  }
  
  /// Get submission state by ID
  SubmissionState? getState(String submissionId) {
    final states = _loadAllStates();
    return states[submissionId];
  }
  
  /// Save submission state
  Future<void> saveState(SubmissionState state) async {
    final states = _loadAllStates();
    states[state.submissionId] = state;
    await _saveAllStates(states);
  }
  
  /// Update submission stage
  Future<void> updateStage(
    String submissionId,
    SubmissionStage stage,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        stage: stage,
        updatedAt: DateTime.now(),
      ));
    }
  }
  
  /// Update video data
  Future<void> updateVideoData(
    String submissionId,
    VideoData video,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        video: video,
        updatedAt: DateTime.now(),
      ));
    }
  }
  
  /// Update AI extracted data
  Future<void> updateAIExtracted(
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        aiExtracted: data,
        updatedAt: DateTime.now(),
      ));
    }
  }
  
  /// Update user provided data
  Future<void> updateUserProvided(
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      final merged = {...?state.userProvided, ...data};
      await saveState(state.copyWith(
        userProvided: merged,
        updatedAt: DateTime.now(),
      ));
    }
  }
  
  /// Update missing fields
  Future<void> updateMissingFields(
    String submissionId,
    List<String> fields,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        missingFields: fields,
        updatedAt: DateTime.now(),
      ));
    }
  }
  
  /// Clear submission state
  Future<void> clearState(String submissionId) async {
    final states = _loadAllStates();
    states.remove(submissionId);
    await _saveAllStates(states);
  }
  
  /// Get all active submission states
  List<SubmissionState> getAllActiveStates() {
    final states = _loadAllStates();
    return states.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  /// Private helpers
  String _generateSubmissionId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}_${Uuid().v4().substring(0, 8)}';
  }
  
  Map<String, SubmissionState> _loadAllStates() {
    final json = _prefs.getString(_storageKey);
    if (json == null) return {};
    
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((key, value) =>
      MapEntry(key, SubmissionState.fromJson(value)),
    );
  }
  
  Future<void> _saveAllStates(Map<String, SubmissionState> states) async {
    final data = states.map((key, value) =>
      MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_storageKey, jsonEncode(data));
  }
}
```

### 3. Chat Provider Enhancement

**Location:** `lib/providers/chat_provider.dart` (update existing)

**Updates Required:**
- Add submission state tracking
- Integrate SubmissionStateManager
- Track current submission ID
- Update submission state on tool results
- Pass submission ID in message metadata

**New State Variables:**
```dart
class ChatProvider with ChangeNotifier {
  // ... existing code ...
  
  final SubmissionStateManager _stateManager;
  String? _currentSubmissionId;
  
  String? get currentSubmissionId => _currentSubmissionId;
  
  SubmissionState? get currentSubmissionState =>
    _currentSubmissionId != null
      ? _stateManager.getState(_currentSubmissionId!)
      : null;
}
```

**New Methods:**
```dart
/// Start new property submission
void startSubmission() {
  final userId = _authService.getCurrentUserId();
  if (userId == null) return;
  
  final state = _stateManager.createNew(userId);
  _currentSubmissionId = state.submissionId;
  notifyListeners();
}

/// Update submission stage
Future<void> updateSubmissionStage(SubmissionStage stage) async {
  if (_currentSubmissionId != null) {
    await _stateManager.updateStage(_currentSubmissionId!, stage);
    notifyListeners();
  }
}

/// Update submission with video data
Future<void> updateSubmissionVideo(VideoData video) async {
  if (_currentSubmissionId != null) {
    await _stateManager.updateVideoData(_currentSubmissionId!, video);
    notifyListeners();
  }
}

/// Update submission with AI extracted data
Future<void> updateSubmissionAIData(Map<String, dynamic> data) async {
  if (_currentSubmissionId != null) {
    await _stateManager.updateAIExtracted(_currentSubmissionId!, data);
    notifyListeners();
  }
}

/// Update submission with user provided data
Future<void> updateSubmissionUserData(Map<String, dynamic> data) async {
  if (_currentSubmissionId != null) {
    await _stateManager.updateUserProvided(_currentSubmissionId!, data);
    notifyListeners();
  }
}

/// Complete submission and clear state
Future<void> completeSubmission() async {
  if (_currentSubmissionId != null) {
    await _stateManager.clearState(_currentSubmissionId!);
    _currentSubmissionId = null;
    notifyListeners();
  }
}

/// Cancel submission
Future<void> cancelSubmission() async {
  if (_currentSubmissionId != null) {
    // Optionally keep state for recovery
    _currentSubmissionId = null;
    notifyListeners();
  }
}
```

**Message Sending with Submission Context:**
```dart
Future<void> sendMessage(String text, [List<File>? files]) async {
  // ... existing code ...
  
  // Add submission context to message metadata
  final metadata = <String, dynamic>{};
  if (_currentSubmissionId != null) {
    metadata['submissionId'] = _currentSubmissionId;
    metadata['workflowStage'] = currentSubmissionState?.stage.toString();
  }
  
  final userMessage = Message(
    id: _uuid.v4(),
    role: 'user',
    content: messageText,
    createdAt: DateTime.now(),
    metadata: metadata,
  );
  
  // ... rest of code ...
}
```

**Tool Result Handling:**
```dart
void _handleChatEvent(ChatEvent event, String assistantMessageId) {
  // ... existing code ...
  
  if (event.isTool && event.toolResult != null) {
    final toolName = event.toolResult!['toolName'] as String?;
    
    // Handle submission workflow tool results
    if (toolName == 'submitProperty') {
      _handleSubmissionToolResult(event.toolResult!);
    }
    
    // ... rest of code ...
  }
}

void _handleSubmissionToolResult(Map<String, dynamic> result) {
  final stage = result['stage'] as String?;
  final submissionId = result['submissionId'] as String?;
  
  if (submissionId != null && _currentSubmissionId == null) {
    _currentSubmissionId = submissionId;
  }
  
  // Update state based on stage
  if (stage == 'video_uploaded') {
    final videoData = VideoData.fromJson(result['video']);
    updateSubmissionVideo(videoData);
    updateSubmissionStage(SubmissionStage.videoUploaded);
  } else if (stage == 'confirm_data') {
    final aiData = result['extractedData'] as Map<String, dynamic>?;
    if (aiData != null) {
      updateSubmissionAIData(aiData);
    }
    updateSubmissionStage(SubmissionStage.confirmData);
  } else if (stage == 'provide_info') {
    final missingFields = (result['missingFields'] as List?)?.cast<String>();
    if (missingFields != null) {
      _stateManager.updateMissingFields(_currentSubmissionId!, missingFields);
    }
    updateSubmissionStage(SubmissionStage.provideInfo);
  } else if (stage == 'final_confirm') {
    updateSubmissionStage(SubmissionStage.finalConfirm);
  } else if (stage == 'complete') {
    completeSubmission();
  }
}
```

### 4. Workflow UI Components

#### A. Stage Progress Indicator

**Location:** `lib/widgets/chat/workflow/stage_progress_indicator.dart`

**Purpose:** Visual indicator of current workflow stage

**Interface:**
```dart
class StageProgressIndicator extends StatelessWidget {
  final SubmissionStage currentStage;
  final int totalStages;
  
  const StageProgressIndicator({
    required this.currentStage,
    this.totalStages = 5,
  });
  
  @override
  Widget build(BuildContext context) {
    final currentIndex = _getStageIndex(currentStage);
    
    return Row(
      children: [
        // Progress bar
        Expanded(
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / totalStages,
          ),
        ),
        SizedBox(width: 8),
        // Stage text
        Text('${currentIndex + 1}/$totalStages'),
      ],
    );
  }
  
  int _getStageIndex(SubmissionStage stage) {
    return SubmissionStage.values.indexOf(stage);
  }
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  ████████░░░░░░░░░░░░░░░  2/5  │
└─────────────────────────────────┘
```

#### B. Workflow Navigation

**Location:** `lib/widgets/chat/workflow/workflow_navigation.dart`

**Purpose:** Navigation controls for workflow

**Interface:**
```dart
class WorkflowNavigation extends StatelessWidget {
  final SubmissionStage currentStage;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;
  final String? helpText;
  
  const WorkflowNavigation({
    required this.currentStage,
    this.onBack,
    this.onCancel,
    this.helpText,
  });
}
```

### 5. Message Model Enhancement

**Location:** `lib/models/message.dart` (update existing)

**Updates Required:**
- Add metadata field
- Add convenience getters for submission context

**Updated Model:**
```dart
class Message {
  final String id;
  final String role;
  final String content;
  final List<ToolResult>? toolResults;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  
  Message({
    required this.id,
    required this.role,
    required this.content,
    this.toolResults,
    required this.createdAt,
    this.metadata,
  });
  
  // Convenience getters
  String? get submissionId => metadata?['submissionId'];
  String? get workflowStage => metadata?['workflowStage'];
  bool get isPartOfWorkflow => submissionId != null;
  
  // ... rest of code ...
}
```

## Data Models

### Complete Submission State Example

```json
{
  "submissionId": "sub_1697500000000_a1b2c3d4",
  "userId": "user_123",
  "stage": "confirmData",
  "video": {
    "url": "https://supabase.co/storage/property-media/user_123/1697500000000.mp4",
    "publicUrl": "https://...",
    "analysisResults": {
      "bedrooms": 2,
      "bathrooms": 2,
      "propertyType": "apartment"
    },
    "duration": 120,
    "quality": "1080p"
  },
  "aiExtracted": {
    "title": "2BR Apartment in Westlands",
    "bedrooms": 2,
    "bathrooms": 2,
    "propertyType": "apartment",
    "location": "Westlands"
  },
  "userProvided": {
    "rent": 50000,
    "deposit": 100000
  },
  "missingFields": ["amenities", "availableFrom"],
  "createdAt": "2025-10-17T10:00:00Z",
  "updatedAt": "2025-10-17T10:05:00Z"
}
```

## Error Handling

### Error Scenarios

1. **State Corruption**
   - Detect invalid state data
   - Offer to restart submission
   - Log error for debugging

2. **Network Failure During Submission**
   - Preserve current state
   - Queue state updates for retry
   - Show offline indicator

3. **App Restart During Submission**
   - Restore active submission on startup
   - Prompt user to continue or cancel
   - Show recovery UI

4. **Multiple Concurrent Submissions**
   - Track each with unique ID
   - Allow switching between submissions
   - Prevent state conflicts

### Error Recovery Strategy

```dart
Future<void> recoverSubmission(String submissionId) async {
  try {
    final state = _stateManager.getState(submissionId);
    if (state == null) {
      throw Exception('Submission not found');
    }
    
    // Validate state
    if (!_isValidState(state)) {
      throw Exception('Invalid submission state');
    }
    
    // Restore submission
    _currentSubmissionId = submissionId;
    notifyListeners();
    
    // Show recovery message
    _showRecoveryDialog(state);
  } catch (e) {
    // Offer to restart
    _showRestartDialog();
  }
}
```

## Testing Strategy

### Unit Tests

**SubmissionState Model:**
- Test serialization/deserialization
- Test copyWith method
- Test computed properties

**SubmissionStateManager:**
- Test state creation
- Test state persistence
- Test state retrieval
- Test state updates
- Test state clearing

**ChatProvider:**
- Test submission lifecycle
- Test state updates
- Test message metadata
- Test tool result handling

### Integration Tests

**Complete Workflow:**
1. Start submission
2. Upload video
3. Confirm data
4. Provide missing info
5. Final confirmation
6. Verify state cleared

**State Persistence:**
1. Start submission
2. Update state
3. Restart app
4. Verify state restored

**Error Recovery:**
1. Start submission
2. Simulate error
3. Verify state preserved
4. Recover submission
5. Continue workflow

### Manual Testing

**Happy Path:**
- Complete full 5-stage submission
- Verify state updates at each stage
- Verify state clears on completion

**Error Scenarios:**
- Test app restart during submission
- Test network failure during submission
- Test invalid state data
- Test multiple concurrent submissions

## Performance Considerations

### Optimization Strategies

1. **Efficient Storage**
   - Use JSON compression for large states
   - Clean up old submissions periodically
   - Limit number of stored submissions

2. **State Updates**
   - Debounce frequent updates
   - Batch multiple updates
   - Use async operations

3. **Memory Management**
   - Don't keep all states in memory
   - Load states on demand
   - Clear unused states

## Dependencies

### Required Packages

```yaml
dependencies:
  shared_preferences: ^2.2.0  # For local storage
  uuid: ^4.0.0  # For generating unique IDs
```

## Implementation Notes

### Phase 1: Models and Manager (Day 1)
- Create SubmissionState model
- Create SubmissionStateManager
- Test state persistence

### Phase 2: Provider Integration (Day 2)
- Update ChatProvider with submission tracking
- Add submission lifecycle methods
- Test state updates

### Phase 3: UI Components (Day 3)
- Create StageProgressIndicator
- Create WorkflowNavigation
- Update tool cards with workflow UI

### Phase 4: Integration (Day 4)
- Integrate all components
- Test complete workflow
- Handle edge cases

## Future Enhancements

1. **Cloud Sync**
   - Sync submission state with backend
   - Enable cross-device continuity

2. **Draft Submissions**
   - Save incomplete submissions as drafts
   - Allow resuming drafts later

3. **Submission History**
   - Track completed submissions
   - Allow viewing submission history

4. **Advanced Recovery**
   - Auto-detect and recover from errors
   - Suggest fixes for invalid states
