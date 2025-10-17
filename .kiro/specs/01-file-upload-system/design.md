# Design Document

## Overview

The File Upload System provides a complete solution for capturing, selecting, and uploading property videos in the Zena mobile app. The system integrates with the existing Flutter architecture using Provider for state management, Supabase Storage for file hosting, and follows the established patterns in the codebase.

**Implementation Status:** Core components are implemented. Requires minor fix to append file URLs to message text for backend compatibility (see Implementation Notes section).

## Architecture

### High-Level Architecture

```
┌─────────────────┐
│   Chat Screen   │
│  (User Input)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Chat Provider  │◄────►│ File Upload      │
│  (State Mgmt)   │      │ Service          │
└────────┬────────┘      └────────┬─────────┘
         │                        │
         ▼                        ▼
┌─────────────────┐      ┌──────────────────┐
│  Chat Service   │      │ Supabase Storage │
│  (API Calls)    │      │ (File Storage)   │
└─────────────────┘      └──────────────────┘
```

### Component Interaction Flow

1. User taps attach button → Opens file upload bottom sheet
2. User selects camera/gallery → System captures/selects video
3. File preview displayed → User confirms upload
4. FileUploadService uploads to Supabase → Returns public URL
5. FileUploadService converts to data URL → For AI SDK compatibility
6. ChatProvider sends message with file parts → ChatService streams response

## Components and Interfaces

### 1. File Upload Bottom Sheet Widget

**Location:** `lib/widgets/chat/file_upload_bottom_sheet.dart`

**Purpose:** Modal bottom sheet for file selection and preview

**Interface:**
```dart
class FileUploadBottomSheet extends StatefulWidget {
  final Function(List<File>) onFilesSelected;
  final int maxFiles;
  final int maxSizeInMB;
  
  const FileUploadBottomSheet({
    required this.onFilesSelected,
    this.maxFiles = 5,
    this.maxSizeInMB = 10,
  });
}
```

**UI Components:**
- Camera button with icon
- Gallery button with icon
- File preview list with thumbnails
- Remove file button for each preview
- Upload button (primary action)
- Cancel button
- Progress indicator during upload

**State Management:**
- Selected files list
- Upload progress
- Validation errors
- Loading state

### 2. File Upload Service

**Location:** `lib/services/file_upload_service.dart`

**Purpose:** Handle file uploads to Supabase Storage and data URL conversion

**Interface:**
```dart
class FileUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Upload files to Supabase Storage
  /// Returns list of public URLs
  Future<List<String>> uploadFiles(
    List<File> files,
    String userId, {
    Function(double)? onProgress,
  });
  
  /// Convert file to base64 data URL for AI SDK
  Future<String> fileToDataUrl(File file);
  
  /// Get MIME type from file extension
  String getContentType(String filePath);
  
  /// Validate file size
  bool validateFileSize(File file, int maxSizeInMB);
  
  /// Validate file format
  bool validateFileFormat(File file, List<String> allowedExtensions);
}
```

**Implementation Details:**
- Uses Supabase Storage SDK for uploads
- Generates unique filenames: `{userId}/{timestamp}_{uuid}.{extension}`
- Bucket name: `property-media`
- Supports progress callbacks for UI updates
- Handles errors with descriptive messages
- Converts files to base64 data URLs for AI SDK compatibility

### 3. Message Input Enhancement

**Location:** `lib/widgets/chat/message_input.dart`

**Updates Required:**
- Add attach file button (paperclip icon) next to send button
- Display file preview chips above text input
- Show file count badge on attach button
- Disable send button during upload
- Show upload progress indicator

**New State:**
```dart
List<File> _selectedFiles = [];
bool _isUploadingFiles = false;
double _uploadProgress = 0.0;
```

### 4. Chat Provider Enhancement

**Location:** `lib/providers/chat_provider.dart`

**Updates Required:**
- Add file upload state tracking
- Integrate FileUploadService
- Convert files to data URLs before sending
- Pass file parts to ChatService in AI SDK format

**New Methods:**
```dart
/// Upload files and send message
Future<void> sendMessageWithFiles(String text, List<File> files);

/// Track upload progress
void _updateUploadProgress(double progress);
```

**New State Variables:**
```dart
bool _isUploadingFiles = false;
double _uploadProgress = 0.0;
```

### 5. File Preview Chip Widget

**Location:** `lib/widgets/chat/file_preview_chip.dart`

**Purpose:** Display selected file with thumbnail and remove button

**Interface:**
```dart
class FilePreviewChip extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  
  const FilePreviewChip({
    required this.file,
    required this.onRemove,
  });
}
```

**UI Components:**
- Video thumbnail (generated from first frame)
- File name (truncated)
- File size
- Remove button (X icon)

## Data Models

### File Upload Result

```dart
class FileUploadResult {
  final String publicUrl;
  final String dataUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  
  FileUploadResult({
    required this.publicUrl,
    required this.dataUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
  });
}
```

### File Part (AI SDK Format)

```dart
// Used in message parts array
{
  'type': 'file',
  'mediaType': 'video/mp4',
  'url': 'data:video/mp4;base64,...'
}
```

## Error Handling

### Error Types

1. **File Size Error**
   - Message: "File size exceeds 50MB limit"
   - Action: Show error snackbar, prevent upload

2. **File Format Error**
   - Message: "Unsupported file format. Please use mp4, mov, avi, or webm"
   - Action: Show error snackbar, prevent selection

3. **Upload Error**
   - Message: "Failed to upload file: {error details}"
   - Action: Show error snackbar with retry button

4. **Permission Error**
   - Message: "Camera/Storage permission required"
   - Action: Show dialog with settings button

5. **Network Error**
   - Message: "No internet connection"
   - Action: Show error snackbar, queue for retry

### Error Handling Strategy

```dart
try {
  final urls = await _fileUploadService.uploadFiles(files, userId);
  // Success - proceed with message
} on StorageException catch (e) {
  _error = 'Upload failed: ${e.message}';
  _showRetryOption();
} on NetworkException catch (e) {
  _error = 'No internet connection';
  _queueForRetry(files);
} catch (e) {
  _error = 'Unexpected error: ${e.toString()}';
  _showErrorDialog();
}
```

## Testing Strategy

### Unit Tests

**FileUploadService Tests:**
- Test file to data URL conversion
- Test MIME type detection
- Test file size validation
- Test file format validation
- Test filename generation

**ChatProvider Tests:**
- Test file upload state management
- Test progress tracking
- Test error handling
- Test message sending with files

### Widget Tests

**FileUploadBottomSheet Tests:**
- Test camera button opens camera
- Test gallery button opens gallery
- Test file preview displays
- Test remove file works
- Test upload button enables/disables correctly
- Test validation errors display

**FilePreviewChip Tests:**
- Test thumbnail displays
- Test file info displays
- Test remove button works

### Integration Tests

**End-to-End File Upload:**
1. Open chat screen
2. Tap attach button
3. Select video from gallery
4. Verify preview displays
5. Tap upload
6. Verify progress indicator
7. Verify message sent with file
8. Verify AI receives file

**Error Scenarios:**
1. Test file size validation
2. Test format validation
3. Test upload failure recovery
4. Test network error handling

### Manual Testing Requirements

**Android Testing:**
- Test camera recording
- Test gallery selection
- Test permissions flow
- Test upload progress
- Test error states

**iOS Testing:**
- Test camera recording
- Test photo library selection
- Test permissions flow
- Test upload progress
- Test error states

## Performance Considerations

### Optimization Strategies

1. **File Compression**
   - Consider compressing videos before upload
   - Use `flutter_ffmpeg` for video compression (optional)
   - Balance quality vs file size

2. **Thumbnail Generation**
   - Generate thumbnails asynchronously
   - Cache thumbnails locally
   - Use `video_thumbnail` package

3. **Upload Progress**
   - Update UI every 100ms max
   - Use debouncing for progress updates
   - Show percentage and estimated time

4. **Memory Management**
   - Dispose file streams after upload
   - Clear file cache after successful upload
   - Limit concurrent uploads to 3

## Security Considerations

### Supabase Storage Security

**Bucket Policies:**
```sql
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'property-media' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public read access
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'property-media');
```

**File Validation:**
- Validate file size on client and server
- Validate file format on client and server
- Scan for malware (server-side, optional)
- Generate unique filenames to prevent overwrites

## Dependencies

### Required Packages

```yaml
dependencies:
  image_picker: ^1.0.0  # Already in pubspec.yaml
  supabase_flutter: ^2.0.0  # Already in pubspec.yaml
  video_thumbnail: ^0.5.0  # For thumbnail generation
  path: ^1.8.0  # For file path operations
```

### Platform-Specific Configuration

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to record property videos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select property videos</string>
```

## Implementation Notes

### ✅ Completed Phases

**Phase 1: Core Upload Service - COMPLETED**
- ✅ FileUploadService implemented with Supabase integration
- ✅ File validation methods added
- ✅ Data URL conversion implemented
- ✅ Tested with sample files

**Phase 2: UI Components - COMPLETED**
- ✅ FileUploadBottomSheet created
- ✅ File preview integrated in MessageInput
- ✅ MessageInput updated with attach button
- ✅ UI interactions tested

**Phase 3: Provider Integration - MOSTLY COMPLETED**
- ✅ ChatProvider updated with file upload support
- ✅ Progress tracking added
- ✅ Error handling implemented
- ⚠️ **NEEDS FIX:** File URLs must be appended to message text

### 🔧 Required Fix

**Issue:** Currently, file URLs are sent as a separate `fileUrls` field in the request body, but the backend doesn't read this field. The backend expects file URLs to be embedded in the message text (matching the web app approach).

**Solution:** Update `chat_provider.dart` to append file URLs to the message text:

```dart
// In sendMessage method, after uploading files:
String messageText = text.isNotEmpty ? text : 'I uploaded a property video';
if (fileUrls != null && fileUrls.isNotEmpty) {
  messageText += '\n\n[Uploaded files: ${fileUrls.join(', ')}]';
}

// Then send with modified text (no separate fileUrls parameter)
final stream = _chatService.sendMessage(
  message: messageText,  // URLs already in text
  conversationId: _conversationId,
  // Remove: fileUrls: fileUrls,
);
```

**Also update `chat_service.dart`:**
- Remove `fileUrls` parameter from `sendMessage` method
- Remove `fileUrls` from request body

### Phase 4: Final Testing
- Test complete upload flow
- Test on real Android device
- Test on real iOS device
- Verify backend receives URLs in message text
- Fix any remaining bugs

## Future Enhancements

1. **Video Compression**
   - Compress videos before upload to reduce size
   - Configurable quality settings

2. **Multiple File Types**
   - Support images in addition to videos
   - Support documents (PDFs)

3. **Upload Queue**
   - Queue multiple uploads
   - Retry failed uploads automatically
   - Background upload support

4. **Advanced Preview**
   - Video player in preview
   - Trim video before upload
   - Add filters or effects
