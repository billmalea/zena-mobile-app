# Implementation Plan

## ✅ Completed Tasks

The following tasks have already been implemented:

- [x] 1. Create File Upload Service - COMPLETED
  - ✅ Implemented `lib/services/file_upload_service.dart` with Supabase Storage integration
  - ✅ Upload files to `property-media` bucket with unique filename generation
  - ✅ Convert files to base64 data URLs for AI SDK compatibility
  - ✅ MIME type detection based on file extension
  - ✅ File size validation method (max 10MB)
  - ✅ File format validation method (mp4, mov, avi, webm)

- [x] 2. Create File Upload Bottom Sheet - COMPLETED
  - ✅ Created `lib/widgets/chat/file_upload_bottom_sheet.dart`
  - ✅ Camera button opens device camera for video recording
  - ✅ Gallery button opens device gallery for video selection
  - ✅ Integrated image_picker package
  - ✅ File preview with video icon and file size
  - ✅ Upload button to confirm file selection
  - ✅ File size validation with error messages
  - ✅ File format validation with error messages
  - ✅ Video recording duration limit (2 minutes)
  - ✅ Remove file functionality

- [x] 3. Update Message Input Widget - COMPLETED
  - ✅ Updated `lib/widgets/chat/message_input.dart`
  - ✅ Attach file button (paperclip icon) added
  - ✅ FileUploadBottomSheet opens on attach button tap
  - ✅ File preview chips display above text input
  - ✅ Remove file functionality from preview chips
  - ✅ Send button enables when files are attached
  - ✅ Send button disabled during upload

- [x] 4. Update Chat Provider with File Upload Support - PARTIALLY COMPLETED
  - ✅ Updated `lib/providers/chat_provider.dart`
  - ✅ Added `_isUploadingFiles` and `_uploadProgress` state variables
  - ✅ Integrated FileUploadService
  - ✅ Updated `sendMessage` method to accept List<File> parameter
  - ✅ Upload files to Supabase Storage and get public URLs
  - ✅ Track upload progress
  - ✅ Handle file upload errors
  - ⚠️ NEEDS FIX: Append file URLs to message text (not separate field)

## 🔧 Remaining Tasks

- [ ] 1. Fix File URL Handling in Chat Provider
  - Update `lib/providers/chat_provider.dart` to append file URLs to message text
  - Modify message text to include uploaded file URLs in format: `\n\n[Uploaded files: url1, url2]`
  - Remove `fileUrls` parameter from ChatService.sendMessage call
  - Test that backend receives and processes file URLs correctly
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [ ] 2. Update Chat Service
  - Update `lib/services/chat_service.dart` to remove `fileUrls` parameter from sendMessage method
  - Remove `fileUrls` from request body (URLs now in message text)
  - _Requirements: 2.1, 2.6_

- [ ] 3. Configure Platform Permissions
  - Verify `android/app/src/main/AndroidManifest.xml` has camera and storage permissions
  - Verify `ios/Runner/Info.plist` has camera and photo library usage descriptions
  - Test permission request flow on Android
  - Test permission request flow on iOS
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 4. Configure Supabase Storage Bucket
  - Verify `property-media` bucket exists in Supabase Storage
  - Configure bucket policies to allow authenticated uploads to user folders
  - Configure bucket policies to allow public read access
  - Test bucket access with sample file upload
  - _Requirements: 2.1, 2.2_

- [ ] 5. End-to-End Integration Testing
  - Test complete file upload flow from chat screen
  - Test camera video recording on Android device
  - Test camera video recording on iOS device
  - Test gallery video selection on Android device
  - Test gallery video selection on iOS device
  - Test file size validation with files over 10MB
  - Test file format validation with unsupported formats
  - Test upload progress indicator updates correctly
  - Test multiple file uploads (2-3 files)
  - Test file removal from preview
  - Test message sending with files and text
  - Test message sending with files only
  - Test error handling for network failures
  - Test error handling for permission denials
  - Verify AI receives and processes uploaded videos correctly from URLs in message text
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 5.4, 5.5_
