# Requirements Document

## Introduction

The File Upload System enables users to upload property videos for submission through the mobile app. This is a critical feature that blocks property submission functionality. Users need the ability to record videos using their device camera or select existing videos from their gallery, with the system handling upload to Supabase Storage and providing public URLs for AI processing.

**Implementation Status:** Core functionality is implemented. Requires minor fix to append file URLs to message text for backend compatibility.

## Requirements

### Requirement 1: Video Capture and Selection

**User Story:** As a property owner, I want to record or select property videos from my device, so that I can submit my property listing with visual documentation.

#### Acceptance Criteria

1. WHEN the user taps the attach file button THEN the system SHALL display a bottom sheet with camera and gallery options
2. WHEN the user selects the camera option THEN the system SHALL open the device camera for video recording
3. WHEN the user selects the gallery option THEN the system SHALL open the device gallery for video selection
4. WHEN the user records a video THEN the system SHALL limit recording duration to 2 minutes maximum
5. IF the video file size exceeds 50MB THEN the system SHALL display a validation error message
6. WHEN a video is selected THEN the system SHALL display a preview thumbnail with file information

### Requirement 2: File Upload to Storage

**User Story:** As a property owner, I want my videos to upload reliably to cloud storage, so that the AI can process them and I can reference them later.

#### Acceptance Criteria

1. WHEN the user confirms file upload THEN the system SHALL upload the file to Supabase Storage in the property-media bucket
2. WHEN uploading a file THEN the system SHALL generate a unique filename using the format {userId}/{timestamp}.{extension}
3. WHEN the upload is in progress THEN the system SHALL display a progress indicator showing upload percentage
4. WHEN the upload completes successfully THEN the system SHALL return the public URL of the uploaded file
5. IF the upload fails THEN the system SHALL display an error message with a retry option
6. WHEN the upload completes THEN the system SHALL convert the file to a base64 data URL for AI SDK compatibility

### Requirement 3: Multiple File Management

**User Story:** As a property owner, I want to attach multiple videos to my submission, so that I can provide comprehensive property documentation.

#### Acceptance Criteria

1. WHEN files are selected THEN the system SHALL display preview chips above the message input
2. WHEN multiple files are attached THEN the system SHALL display a file count badge
3. WHEN the user taps the remove button on a preview chip THEN the system SHALL remove that file from the upload queue
4. WHEN files are attached without message text THEN the system SHALL enable the send button
5. WHEN the upload is in progress THEN the system SHALL disable the send button and show upload state

### Requirement 4: Supported File Formats

**User Story:** As a property owner, I want to upload videos in common formats, so that I'm not restricted by technical limitations.

#### Acceptance Criteria

1. WHEN a user selects a file THEN the system SHALL accept mp4, mov, avi, and webm formats
2. IF a user selects an unsupported format THEN the system SHALL display a validation error message
3. WHEN uploading a file THEN the system SHALL detect and set the correct MIME type based on file extension

### Requirement 5: Cross-Platform Compatibility

**User Story:** As a mobile user, I want the file upload to work on both Android and iOS devices, so that I have a consistent experience regardless of my device.

#### Acceptance Criteria

1. WHEN using an Android device THEN the system SHALL request and handle camera and storage permissions
2. WHEN using an iOS device THEN the system SHALL request and handle camera and photo library permissions
3. WHEN permissions are denied THEN the system SHALL display a message explaining why permissions are needed
4. WHEN the camera is accessed THEN the system SHALL work correctly on both Android and iOS devices
5. WHEN the gallery is accessed THEN the system SHALL work correctly on both Android and iOS devices
