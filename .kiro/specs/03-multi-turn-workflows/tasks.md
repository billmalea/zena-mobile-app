# Implementation Plan

- [x] 1. Create Submission State Model





  - Create `lib/models/submission_state.dart` with SubmissionState class
  - Define SubmissionStage enum (start, videoUploaded, confirmData, provideInfo, finalConfirm)
  - Create VideoData class for video information
  - Add fields for submissionId, userId, stage, video, aiExtracted, userProvided, missingFields, timestamps
  - Implement toJson() and fromJson() methods for serialization
  - Implement copyWith() method for immutable updates
  - Add computed properties (progress, isComplete, allData)
  - Test serialization and deserialization
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Create Submission State Manager Service





  - Create `lib/services/submission_state_manager.dart`
  - Initialize SharedPreferences for local storage
  - Implement createNew() method to create new submission with unique ID
  - Implement getState() method to retrieve submission by ID
  - Implement saveState() method to persist submission state
  - Implement updateStage() method to update workflow stage
  - Implement updateVideoData() method to store video information
  - Implement updateAIExtracted() method to store AI-extracted data
  - Implement updateUserProvided() method to store user-provided data
  - Implement updateMissingFields() method to store missing field list
  - Implement clearState() method to remove completed submission
  - Implement getAllActiveStates() method to get all active submissions
  - Add helper methods for loading/saving all states from SharedPreferences
  - Test all CRUD operations
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Update Chat Provider with Submission Tracking





  - Update `lib/providers/chat_provider.dart` to integrate SubmissionStateManager
  - Add _currentSubmissionId state variable
  - Add currentSubmissionId and currentSubmissionState getters
  - Implement startSubmission() method to create new submission
  - Implement updateSubmissionStage() method to update stage
  - Implement updateSubmissionVideo() method to store video data
  - Implement updateSubmissionAIData() method to store extracted data
  - Implement updateSubmissionUserData() method to store user data
  - Implement completeSubmission() method to clear state
  - Implement cancelSubmission() method to cancel workflow
  - Test submission lifecycle methods
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Add Submission Context to Messages





  - Update `lib/models/message.dart` to add metadata field
  - Add convenience getters (submissionId, workflowStage, isPartOfWorkflow)
  - Update Message.toJson() and fromJson() to handle metadata
  - Test metadata serialization
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 5. Update Message Sending with Submission Context





  - Update sendMessage() in ChatProvider to include submission context in metadata
  - Add submissionId and workflowStage to message metadata when in workflow
  - Test messages include correct submission context
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 6. Implement Tool Result Handling for Submission Workflow





  - Update _handleChatEvent() in ChatProvider to detect submitProperty tool results
  - Create _handleSubmissionToolResult() method to process submission tool results
  - Handle stage transitions based on tool result (start → video_uploaded → confirm_data → provide_info → final_confirm → complete)
  - Update submission state when video is uploaded
  - Update submission state when AI extracts data
  - Update submission state when missing fields are identified
  - Update submission state when user provides data
  - Clear submission state when workflow completes
  - Test all stage transitions
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 7. Create Stage Progress Indicator Widget





  - Create `lib/widgets/chat/workflow/stage_progress_indicator.dart`
  - Display current stage number (1/5, 2/5, etc.)
  - Show linear progress bar
  - Add stage names
  - Show checkmarks for completed stages
  - Highlight current stage
  - Test with different stages
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 8. Create Workflow Navigation Widget





  - Create `lib/widgets/chat/workflow/workflow_navigation.dart`
  - Add back button (if applicable for stage)
  - Add cancel workflow button
  - Display stage-specific help text
  - Add workflow status badge
  - Handle navigation callbacks
  - Test navigation controls
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 9. Integrate Workflow UI into Submission Cards





  - Update PropertySubmissionCard to use StageProgressIndicator
  - Update PropertySubmissionCard to use WorkflowNavigation
  - Display stage-appropriate instructions
  - Show submission ID reference
  - Test UI integration
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 10. Implement State Persistence on App Restart





  - Load active submission states when ChatProvider initializes
  - Restore currentSubmissionId if active submission exists
  - Prompt user to continue or cancel incomplete submission
  - Test state restoration after app restart
  - _Requirements: 1.3, 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 11. Implement Error Recovery





  - Preserve submission state when errors occur
  - Add retry capability from last successful stage
  - Implement confirmation dialog for canceling submission
  - Queue state updates when network fails
  - Detect and handle state corruption
  - Test error recovery scenarios
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 12. Test Complete 5-Stage Workflow






  - Test Stage 1: Start submission and show video upload instructions
  - Test Stage 2: Upload video and store video data
  - Test Stage 3: Display extracted data and confirm/correct
  - Test Stage 4: Provide missing information
  - Test Stage 5: Final review and confirmation
  - Test state persists between stages
  - Test state persists after app restart
  - Test multiple concurrent submissions
  - Test canceling submission
  - Test error recovery
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 5.5_
