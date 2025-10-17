# File Upload System - Testing Guide

## Quick Start

This guide helps you test the file upload system implementation. The testing is divided into two parts:

1. **Automated Tests** - Run these first to verify core functionality
2. **Manual Tests** - Test on real devices to verify user experience

---

## Part 1: Automated Tests

### Running the Tests

```bash
# Run all tests
flutter test

# Run only file upload integration tests
flutter test test/file_upload_integration_test.dart

# Run with verbose output
flutter test --verbose test/file_upload_integration_test.dart
```

### What the Automated Tests Cover

✅ **File Size Validation**
- Validates files under 50MB limit
- Rejects files over 50MB
- Calculates file size in MB correctly

✅ **File Format Validation**
- Detects MP4, MOV, AVI, WEBM formats
- Handles file paths and extensions
- Case-insensitive format detection
- Returns default for unsupported formats

✅ **Data URL Conversion**
- Converts files to base64 data URLs
- Correct MIME type in data URL
- Handles different video formats

✅ **Error Handling**
- Throws exceptions for non-existent files
- Handles validation errors gracefully

### Expected Test Results

All tests should pass:
```
✓ File Size Validation - should validate file size correctly for small files
✓ File Size Validation - should reject files over size limit
✓ File Size Validation - should calculate file size in MB correctly
✓ File Format Validation - should detect MP4 content type correctly
✓ File Format Validation - should detect MOV content type correctly
... (and more)

All tests passed!
```

---

## Part 2: Manual Device Testing

### Prerequisites

#### For Android Testing
1. **Physical Android device** (Android 8.0+) or emulator
2. **USB debugging enabled** on device
3. **Test videos** prepared (see below)
4. **Camera and storage permissions** ready to test

#### For iOS Testing
1. **Physical iOS device** (iOS 12.0+) or simulator
2. **Device registered** in Apple Developer account
3. **Test videos** prepared (see below)
4. **Camera and photo library permissions** ready to test

### Preparing Test Videos

Create or download these test videos:

1. **Small video** (< 5MB) - Quick test
2. **Medium video** (10-20MB) - Normal use case
3. **Large video** (40-50MB) - Near limit test
4. **Oversized video** (> 50MB) - Validation test
5. **Different formats** - MP4, MOV, WEBM (if possible)

### Running the App on Device

#### Android
```bash
# List connected devices
flutter devices

# Run on connected Android device
flutter run -d <device-id>

# Or simply (if only one device connected)
flutter run
```

#### iOS
```bash
# List connected devices
flutter devices

# Run on connected iOS device
flutter run -d <device-id>

# Or simply (if only one device connected)
flutter run
```

### Manual Testing Checklist

Use the comprehensive checklist in `MANUAL_TESTING_CHECKLIST.md` to test:

#### Priority 1: Core Functionality (Must Test)
- [ ] Camera video recording works
- [ ] Gallery video selection works
- [ ] File size validation (test with >50MB file)
- [ ] File upload to Supabase succeeds
- [ ] Message sent with file URLs
- [ ] AI receives and processes video URLs

#### Priority 2: User Experience (Should Test)
- [ ] Upload progress indicator works
- [ ] Multiple file uploads work
- [ ] File removal from preview works
- [ ] Error messages display correctly
- [ ] Permission requests work properly

#### Priority 3: Edge Cases (Nice to Test)
- [ ] Network error handling
- [ ] Permission denial handling
- [ ] App backgrounding during upload
- [ ] Low storage scenarios

---

## Testing Workflow

### Step 1: Run Automated Tests
```bash
flutter test test/file_upload_integration_test.dart
```
**Expected:** All tests pass ✅

### Step 2: Deploy to Android Device
```bash
flutter run -d android
```

### Step 3: Test Core Android Functionality
1. Open chat screen
2. Tap attach button (paperclip icon)
3. Test "Record Video" - record 10-second video
4. Test "Choose from Gallery" - select existing video
5. Verify file preview shows
6. Tap "Upload" button
7. Verify upload progress shows
8. Send message
9. Verify AI receives video URL

### Step 4: Deploy to iOS Device
```bash
flutter run -d ios
```

### Step 5: Test Core iOS Functionality
Repeat Step 3 on iOS device

### Step 6: Test Validation
1. Try to upload file > 50MB
2. Verify error message: "Video must be less than 50MB"
3. Try to upload unsupported format (if possible)
4. Verify appropriate error

### Step 7: Test Error Scenarios
1. Deny camera permission → Verify error message
2. Deny storage permission → Verify error message
3. Disable internet → Try upload → Verify error
4. Test file removal from preview

### Step 8: Complete Full Checklist
Work through `MANUAL_TESTING_CHECKLIST.md` systematically

---

## Common Issues and Solutions

### Issue: Tests Fail with "File not found"
**Solution:** The test creates temporary files. Ensure write permissions in test directory.

### Issue: Camera doesn't open on device
**Solution:** 
1. Check AndroidManifest.xml has camera permissions
2. Check Info.plist has camera usage description
3. Grant permissions in device settings

### Issue: Upload fails with "User not authenticated"
**Solution:** Ensure you're logged in before testing file upload

### Issue: File size validation not working
**Solution:** Check that maxFileSizeMB is set correctly in FileUploadBottomSheet

### Issue: Progress indicator doesn't update
**Solution:** Check that ChatProvider is notifying listeners during upload

---

## Verification Checklist

After testing, verify these requirements are met:

### Requirement 1: Video Capture and Selection ✅
- [x] Bottom sheet displays with camera and gallery options
- [x] Camera opens for video recording
- [x] Gallery opens for video selection
- [x] Recording limited to 2 minutes
- [x] File size validation (50MB limit)
- [x] Preview thumbnail displays

### Requirement 2: File Upload to Storage ✅
- [x] Files upload to Supabase Storage
- [x] Unique filename generation (userId/timestamp.ext)
- [x] Progress indicator shows upload percentage
- [x] Public URL returned on success
- [x] Error messages on failure
- [x] Base64 data URL conversion

### Requirement 3: Multiple File Management ✅
- [x] Preview chips display above input
- [x] File count badge shows
- [x] Remove button works
- [x] Send button enables with files
- [x] Send button disabled during upload

### Requirement 4: Supported File Formats ✅
- [x] Accepts mp4, mov, avi, webm
- [x] Rejects unsupported formats
- [x] Correct MIME type detection

### Requirement 5: Cross-Platform Compatibility ✅
- [x] Android camera and storage permissions
- [x] iOS camera and photo library permissions
- [x] Permission denial messages
- [x] Works on both Android and iOS

---

## Test Results Template

### Automated Tests
- **Date:** _____________
- **Result:** ✅ Pass / ❌ Fail
- **Notes:** _____________

### Android Device Testing
- **Device:** _____________
- **Android Version:** _____________
- **Date:** _____________
- **Result:** ✅ Pass / ❌ Fail
- **Issues Found:** _____________

### iOS Device Testing
- **Device:** _____________
- **iOS Version:** _____________
- **Date:** _____________
- **Result:** ✅ Pass / ❌ Fail
- **Issues Found:** _____________

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Mark task as complete in tasks.md
2. Document any observations
3. Feature is ready for production

### If Tests Fail ❌
1. Document the failure in detail
2. Create bug report with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Device/OS information
   - Screenshots/videos if possible
3. Fix the issue
4. Re-run tests

---

## Support

If you encounter issues during testing:

1. Check the implementation files:
   - `lib/services/file_upload_service.dart`
   - `lib/widgets/chat/file_upload_bottom_sheet.dart`
   - `lib/widgets/chat/message_input.dart`
   - `lib/providers/chat_provider.dart`

2. Review the design document:
   - `.kiro/specs/01-file-upload-system/design.md`

3. Check Supabase Storage configuration:
   - Verify `property-media` bucket exists
   - Check bucket policies allow uploads
   - Verify public read access enabled

4. Review requirements:
   - `.kiro/specs/01-file-upload-system/requirements.md`
