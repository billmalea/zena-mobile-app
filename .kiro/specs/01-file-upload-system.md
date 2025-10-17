---
title: File Upload System Implementation
priority: CRITICAL
estimated_effort: 3-4 days
status: pending
dependencies: []
---

# File Upload System Implementation

## Overview
Implement complete file upload functionality for property video submissions. This is a CRITICAL blocking feature - property submission is impossible without it.

## Current State
- ❌ No file upload UI
- ❌ No file picker integration
- ❌ No Supabase Storage integration
- ❌ No multipart/form-data support in API service
- ✅ `image_picker` package already in pubspec.yaml

## Requirements

### 1. File Upload Widget
Create `lib/widgets/chat/file_upload_bottom_sheet.dart`

**Features:**
- Camera video recording (max 2 minutes)
- Gallery video selection
- File preview with thumbnails
- File size validation (max 10MB)
- Upload progress indicator
- Remove file capability
- Multiple file support

**User Flow:**
1. User taps attach button in message input
2. Bottom sheet appears with camera/gallery options
3. User selects video source
4. File preview shows selected video
5. User can add more files or remove files
6. User taps upload button
7. Progress indicator shows upload status
8. On success, files are attached to message

### 2. File Upload Service
Create `lib/services/file_upload_service.dart`

**Features:**
- Upload files to Supabase Storage (`property-media` bucket)
- Generate unique filenames: `{userId}/{timestamp}.{extension}`
- Return public URLs for uploaded files
- Convert files to base64 data URLs (for AI SDK compatibility)
- Handle upload errors gracefully
- Support video formats: mp4, mov, avi, webm

**Methods:**
```dart
Future<List<String>> uploadFiles(List<File> files, String userId)
Future<String> fileToDataUrl(File file)
String _getContentType(String extension)
```

### 3. Enhanced Message Input
Update `lib/widgets/chat/message_input.dart`

**Features:**
- Add attach file button (paperclip icon)
- Show file preview chips above input
- Display file count badge
- Remove file from preview
- Disable send if only files (require text or files)
- Show upload progress state

### 4. API Service Enhancement
Update `lib/services/api_service.dart`

**Features:**
- Add `postWithFiles()` method for multipart uploads
- Support FormData with files + message + conversationId
- Handle file upload progress callbacks
- Convert files to base64 for AI SDK format
- Proper MIME type detection

**Method Signature:**
```dart
Future<Stream<String>> postWithFiles(
  String endpoint,
  String message,
  List<File> files,
  String? conversationId,
)
```

### 5. Chat Provider Integration
Update `lib/providers/chat_provider.dart`

**Features:**
- Add `sendMessageWithFiles()` method
- Track upload state (`_isUploadingFiles`)
- Upload files before sending message
- Pass file URLs to chat service
- Handle upload errors
- Show upload progress to user

**State Management:**
```dart
bool _isUploadingFiles = false;
bool get isUploadingFiles => _isUploadingFiles;

Future<void> sendMessage(String text, [List<File>? files])
```

### 6. Chat Service Enhancement
Update `lib/services/chat_service.dart`

**Features:**
- Accept file URLs in message payload
- Stream response after file upload
- Handle file upload errors in stream

## Implementation Tasks

### Phase 1: File Upload Widget (Day 1-2)
- [ ] Create `file_upload_bottom_sheet.dart`
- [ ] Implement camera video recording
- [ ] Implement gallery video selection
- [ ] Add file preview UI
- [ ] Add file size validation
- [ ] Add upload progress indicator
- [ ] Add remove file functionality
- [ ] Test on Android device
- [ ] Test on iOS device

### Phase 2: File Upload Service (Day 2)
- [ ] Create `file_upload_service.dart`
- [ ] Implement Supabase Storage upload
- [ ] Generate unique filenames
- [ ] Return public URLs
- [ ] Implement file-to-base64 conversion
- [ ] Add MIME type detection
- [ ] Handle upload errors
- [ ] Test with real videos

### Phase 3: Message Input Enhancement (Day 3)
- [ ] Add attach file button to message input
- [ ] Show file upload bottom sheet on tap
- [ ] Display file preview chips
- [ ] Add remove file from preview
- [ ] Update send button state
- [ ] Test user flow

### Phase 4: API & Provider Integration (Day 3-4)
- [ ] Add `postWithFiles()` to ApiService
- [ ] Update ChatProvider with file upload support
- [ ] Update ChatService to accept file URLs
- [ ] Test end-to-end file upload flow
- [ ] Handle errors gracefully
- [ ] Test with multiple files

## Testing Checklist

### Unit Tests
- [ ] File size validation
- [ ] MIME type detection
- [ ] Filename generation
- [ ] Base64 conversion

### Widget Tests
- [ ] File upload bottom sheet renders
- [ ] Camera/gallery buttons work
- [ ] File preview displays
- [ ] Remove file works
- [ ] Upload button enables/disables correctly

### Integration Tests
- [ ] Record video from camera
- [ ] Select video from gallery
- [ ] Upload to Supabase Storage
- [ ] Receive public URL
- [ ] Send message with file URL
- [ ] AI receives and processes video

### Manual Tests (Real Device Required)
- [ ] Camera recording works on Android
- [ ] Camera recording works on iOS
- [ ] Gallery selection works on Android
- [ ] Gallery selection works on iOS
- [ ] Upload progress shows correctly
- [ ] Large files (>5MB) upload successfully
- [ ] Multiple files upload successfully
- [ ] Error handling works (no internet, storage full)

## Success Criteria
- ✅ Users can record property videos from camera
- ✅ Users can select videos from gallery
- ✅ Videos upload to Supabase Storage successfully
- ✅ Public URLs are returned and sent to AI
- ✅ Upload progress is visible to users
- ✅ Errors are handled gracefully with retry option
- ✅ Works on both Android and iOS

## Dependencies
- Supabase Storage bucket `property-media` must exist
- Supabase Storage policies must allow authenticated uploads
- `image_picker` package (already installed)
- Camera and storage permissions configured

## Notes
- This is a BLOCKING feature for property submission
- Must test on real devices (camera/gallery don't work in emulator)
- File size limit: 10MB (configurable)
- Video duration limit: 2 minutes (configurable)
- Supported formats: mp4, mov, avi, webm

## Reference Files
- Web implementation: `zena/app/api/chat/route.ts` (lines 50-120)
- Code examples: `zena_mobile_app/MISSING MD/MOBILE_APP_CRITICAL_CODE_EXAMPLES.md`
