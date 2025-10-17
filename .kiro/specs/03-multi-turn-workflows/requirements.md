# Requirements Document

## Introduction

The Multi-Turn Workflow State Management system enables tracking of complex, multi-stage interactions between the user and AI, specifically the 5-stage property submission process. This is critical because property submission requires maintaining state across multiple user messages and AI responses, ensuring data persistence and workflow continuity.

## Requirements

### Requirement 1: Submission State Tracking

**User Story:** As a property owner, I want my submission progress to be tracked across multiple interactions, so that I don't lose my work if I navigate away or the app restarts.

#### Acceptance Criteria

1. WHEN a property submission starts THEN the system SHALL create a unique submission ID
2. WHEN submission state changes THEN the system SHALL persist the current stage, video data, extracted data, and user-provided data
3. WHEN the app restarts THEN the system SHALL restore active submission states
4. WHEN a submission completes THEN the system SHALL clear the submission state
5. WHEN multiple submissions exist THEN the system SHALL track each independently with unique IDs

### Requirement 2: Workflow Stage Management

**User Story:** As a property owner, I want to see which stage I'm on in the submission process, so that I understand what's expected next.

#### Acceptance Criteria

1. WHEN in a submission workflow THEN the system SHALL display the current stage (start, video_uploaded, confirm_data, provide_info, final_confirm)
2. WHEN moving between stages THEN the system SHALL update the stage indicator
3. WHEN on a specific stage THEN the system SHALL display stage-appropriate UI and instructions
4. WHEN going back is allowed THEN the system SHALL enable back navigation to previous stages
5. WHEN a stage is complete THEN the system SHALL mark it as completed in the progress indicator

### Requirement 3: Data Persistence Across Messages

**User Story:** As a property owner, I want my submission data to persist between messages, so that I don't have to re-enter information.

#### Acceptance Criteria

1. WHEN video is uploaded THEN the system SHALL store the video URL and analysis results
2. WHEN AI extracts property data THEN the system SHALL store the extracted data in submission state
3. WHEN user provides corrections THEN the system SHALL merge corrections with extracted data
4. WHEN user provides missing fields THEN the system SHALL store the provided data
5. WHEN submission state is updated THEN the system SHALL persist changes locally

### Requirement 4: Submission Context in Messages

**User Story:** As a property owner, I want my messages to be linked to my submission, so that the AI understands the context of my responses.

#### Acceptance Criteria

1. WHEN sending a message during submission THEN the system SHALL include the submission ID in message metadata
2. WHEN displaying messages THEN the system SHALL show workflow context indicators
3. WHEN viewing message history THEN the system SHALL group related submission messages
4. WHEN switching conversations THEN the system SHALL maintain separate submission states

### Requirement 5: Workflow Error Recovery

**User Story:** As a property owner, I want to recover from errors during submission, so that I don't lose my progress.

#### Acceptance Criteria

1. IF an error occurs during submission THEN the system SHALL preserve the current state
2. WHEN retrying after an error THEN the system SHALL resume from the last successful stage
3. WHEN canceling a submission THEN the system SHALL prompt for confirmation before clearing state
4. WHEN network fails THEN the system SHALL queue state updates for retry
5. WHEN state corruption is detected THEN the system SHALL offer to restart the submission
