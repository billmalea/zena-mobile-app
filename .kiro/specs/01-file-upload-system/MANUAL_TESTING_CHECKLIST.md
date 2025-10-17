# File Upload System - Manual Testing Checklist

## Overview
This document provides a comprehensive checklist for manually testing the file upload system on Android and iOS devices. Complete each test case and mark it as ✅ Pass, ❌ Fail, or ⚠️ Partial.

**Testing Date:** _____________  
**Tester Name:** _____________  
**App Version:** _____________

---

## Pre-Testing Setup

### Android Device Setup
- [ ] Device running Android 8.0 or higher
- [ ] Developer mode enabled
- [ ] USB debugging enabled
- [ ] Device connected and recognized by `flutter devices`
- [ ] App installed via `flutter run` or `flutter install`

### iOS Device Setup
- [ ] Device running iOS 12.0 or higher
- [ ] Device registered in Apple Developer account
- [ ] Provisioning profile configured
- [ ] Device connected and recognized by `flutter devices`
- [ ] App installed via `flutter run` or `flutter install`

### Test Data Preparation
- [ ] Prepare 3-5 test videos in different formats (mp4, mov, webm)
- [ ] Prepare videos of different sizes:
  - Small: < 5MB
  - Medium: 10-20MB
  - Large: 40-50MB
  - Oversized: > 50MB
- [ ] Prepare unsupported file format (e.g., .txt, .pdf)
- [ ] Ensure device has camera access
- [ ] Ensure device has gallery with existing videos

---

## Test Cases

### 1. Camera Video Recording

#### Android Camera Recording
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 1.1 Open camera | 1. Open chat screen<br>2. Tap attach button (paperclip)<br>3. Tap "Record Video" | Camera opens successfully | ⬜ | |
| 1.2 Record short video | 1. Record 10-second video<br>2. Stop recording | Video captured and preview shown | ⬜ | |
| 1.3 Record 2-minute video | 1. Record video for 2 minutes<br>2. Check if recording stops | Recording stops at 2 minutes | ⬜ | |
| 1.4 Cancel recording | 1. Start recording<br>2. Cancel/back button | Returns to bottom sheet without file | ⬜ | |
| 1.5 Permission denied | 1. Deny camera permission<br>2. Try to record | Error message shown with settings option | ⬜ | |

#### iOS Camera Recording
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 1.6 Open camera | 1. Open chat screen<br>2. Tap attach button<br>3. Tap "Record Video" | Camera opens successfully | ⬜ | |
| 1.7 Record short video | 1. Record 10-second video<br>2. Stop recording | Video captured and preview shown | ⬜ | |
| 1.8 Record 2-minute video | 1. Record video for 2 minutes<br>2. Check if recording stops | Recording stops at 2 minutes | ⬜ | |
| 1.9 Cancel recording | 1. Start recording<br>2. Cancel/back button | Returns to bottom sheet without file | ⬜ | |
| 1.10 Permission denied | 1. Deny camera permission<br>2. Try to record | Error message shown with settings option | ⬜ | |

---

### 2. Gallery Video Selection

#### Android Gallery Selection
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 2.1 Open gallery | 1. Tap attach button<br>2. Tap "Choose from Gallery" | Gallery opens successfully | ⬜ | |
| 2.2 Select video | 1. Select a video from gallery<br>2. Confirm selection | Video preview shown in bottom sheet | ⬜ | |
| 2.3 Select multiple videos | 1. Select 2-3 videos<br>2. Confirm each | All videos shown in preview list | ⬜ | |
| 2.4 Cancel selection | 1. Open gallery<br>2. Press back without selecting | Returns to bottom sheet without file | ⬜ | |
| 2.5 Permission denied | 1. Deny storage permission<br>2. Try to open gallery | Error message shown with settings option | ⬜ | |

#### iOS Gallery Selection
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 2.6 Open photo library | 1. Tap attach button<br>2. Tap "Choose from Gallery" | Photo library opens successfully | ⬜ | |
| 2.7 Select video | 1. Select a video from library<br>2. Confirm selection | Video preview shown in bottom sheet | ⬜ | |
| 2.8 Select multiple videos | 1. Select 2-3 videos<br>2. Confirm each | All videos shown in preview list | ⬜ | |
| 2.9 Cancel selection | 1. Open library<br>2. Press cancel | Returns to bottom sheet without file | ⬜ | |
| 2.10 Permission denied | 1. Deny photo library permission<br>2. Try to open library | Error message shown with settings option | ⬜ | |

---

### 3. File Size Validation

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 3.1 Small file (< 5MB) | 1. Select video < 5MB<br>2. Check preview | File accepted, size shown correctly | ⬜ | |
| 3.2 Medium file (10-20MB) | 1. Select video 10-20MB<br>2. Check preview | File accepted, size shown correctly | ⬜ | |
| 3.3 Large file (40-50MB) | 1. Select video 40-50MB<br>2. Check preview | File accepted, size shown correctly | ⬜ | |
| 3.4 Oversized file (> 50MB) | 1. Select video > 50MB<br>2. Check error | Error message: "Video must be less than 50MB" | ⬜ | |
| 3.5 File size display | 1. Select any video<br>2. Check preview | File size displayed in MB (e.g., "12.5MB") | ⬜ | |

---

### 4. File Format Validation

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 4.1 MP4 format | 1. Select .mp4 video | File accepted | ⬜ | |
| 4.2 MOV format | 1. Select .mov video | File accepted | ⬜ | |
| 4.3 WEBM format | 1. Select .webm video | File accepted | ⬜ | |
| 4.4 AVI format | 1. Select .avi video | File accepted | ⬜ | |
| 4.5 Unsupported format | 1. Try to select .txt or .pdf file | File not selectable or error shown | ⬜ | |

---

### 5. File Preview and Management

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 5.1 Single file preview | 1. Select one video<br>2. Check preview | Video icon, file size shown | ⬜ | |
| 5.2 Multiple file preview | 1. Select 3 videos<br>2. Check preview | All 3 videos shown in horizontal list | ⬜ | |
| 5.3 Remove file from preview | 1. Select video<br>2. Tap X button on preview | File removed from selection | ⬜ | |
| 5.4 Remove from multiple files | 1. Select 3 videos<br>2. Remove middle one | Correct file removed, others remain | ⬜ | |
| 5.5 File count display | 1. Select 2 videos<br>2. Check upload button | Button shows "Upload 2 Videos" | ⬜ | |

---

### 6. Upload Progress and Status

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 6.1 Upload single file | 1. Select video<br>2. Tap upload<br>3. Watch progress | Progress indicator shows 0-100% | ⬜ | |
| 6.2 Upload multiple files | 1. Select 3 videos<br>2. Tap upload<br>3. Watch progress | Progress updates for each file | ⬜ | |
| 6.3 Upload button disabled | 1. Start upload<br>2. Try to tap send | Send button disabled during upload | ⬜ | |
| 6.4 Upload completion | 1. Complete upload<br>2. Check UI | Files appear in message input preview | ⬜ | |
| 6.5 Upload time estimate | 1. Upload large file<br>2. Check progress | Progress indicator updates smoothly | ⬜ | |

---

### 7. Message Sending with Files

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 7.1 Send with text and file | 1. Type message<br>2. Attach video<br>3. Send | Message sent with text and file URL | ⬜ | |
| 7.2 Send file only | 1. Attach video (no text)<br>2. Send | Message sent with default text and file URL | ⬜ | |
| 7.3 Send multiple files | 1. Attach 3 videos<br>2. Send | All file URLs appended to message | ⬜ | |
| 7.4 File URL format | 1. Send file<br>2. Check message text | URLs in format: "[Uploaded files: url1, url2]" | ⬜ | |
| 7.5 Message cleared after send | 1. Send message with files<br>2. Check input | Text and file previews cleared | ⬜ | |

---

### 8. Error Handling

#### Network Errors
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 8.1 No internet - upload | 1. Disable internet<br>2. Try to upload | Error: "No internet connection" | ⬜ | |
| 8.2 Slow connection | 1. Enable slow network<br>2. Upload file | Progress indicator shows slow progress | ⬜ | |
| 8.3 Connection lost mid-upload | 1. Start upload<br>2. Disable internet mid-way | Error message with retry option | ⬜ | |

#### Permission Errors
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 8.4 Camera permission denied | 1. Deny camera permission<br>2. Try to record | Error with "Open Settings" option | ⬜ | |
| 8.5 Storage permission denied | 1. Deny storage permission<br>2. Try to select from gallery | Error with "Open Settings" option | ⬜ | |
| 8.6 Permission granted after denial | 1. Grant permission in settings<br>2. Return to app<br>3. Try again | Feature works correctly | ⬜ | |

#### Upload Errors
| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 8.7 Supabase error | 1. (Simulate backend error)<br>2. Try to upload | Error message displayed | ⬜ | |
| 8.8 Retry after error | 1. Encounter upload error<br>2. Tap retry | Upload attempted again | ⬜ | |

---

### 9. AI Processing Verification

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| 9.1 AI receives file URL | 1. Send message with video<br>2. Check AI response | AI acknowledges receiving video | ⬜ | |
| 9.2 AI processes video | 1. Send property video<br>2. Wait for AI response | AI provides relevant response about video | ⬜ | |
| 9.3 Multiple files to AI | 1. Send 2-3 videos<br>2. Check AI response | AI acknowledges all videos | ⬜ | |
| 9.4 File URL accessibility | 1. Send video<br>2. Copy URL from message<br>3. Open in browser | Video accessible via public URL | ⬜ | |

---

### 10. Cross-Platform Consistency

| Test Case | Android Result | iOS Result | Notes |
|-----------|----------------|------------|-------|
| 10.1 UI appearance | ⬜ | ⬜ | Bottom sheet looks consistent |
| 10.2 File preview style | ⬜ | ⬜ | Preview chips look consistent |
| 10.3 Error messages | ⬜ | ⬜ | Same error messages shown |
| 10.4 Upload progress | ⬜ | ⬜ | Progress indicator works same |
| 10.5 Permission flow | ⬜ | ⬜ | Permission requests work correctly |

---

## Performance Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| P1. Memory usage | 1. Upload 5 large videos<br>2. Check memory | No memory leaks or crashes | ⬜ | |
| P2. Battery impact | 1. Record and upload videos for 10 min<br>2. Check battery | Reasonable battery consumption | ⬜ | |
| P3. App responsiveness | 1. Upload large file<br>2. Try to interact with UI | UI remains responsive | ⬜ | |
| P4. Background upload | 1. Start upload<br>2. Switch to another app | Upload continues in background | ⬜ | |

---

## Edge Cases

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| E1. Low storage space | 1. Fill device storage<br>2. Try to record video | Error message about storage | ⬜ | |
| E2. Low battery | 1. Reduce battery to < 10%<br>2. Try to record | Warning or feature works | ⬜ | |
| E3. App backgrounded during upload | 1. Start upload<br>2. Background app<br>3. Return | Upload completes or resumes | ⬜ | |
| E4. App killed during upload | 1. Start upload<br>2. Force kill app<br>3. Reopen | Graceful handling, no corruption | ⬜ | |
| E5. Rapid file selection | 1. Quickly select/deselect files<br>2. Check state | UI state remains consistent | ⬜ | |

---

## Regression Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| R1. Text-only messages | 1. Send message without files | Works as before | ⬜ | |
| R2. Chat history | 1. Load previous conversation | Messages load correctly | ⬜ | |
| R3. Streaming responses | 1. Send message<br>2. Watch AI response | Streaming works correctly | ⬜ | |
| R4. Authentication | 1. Logout and login<br>2. Try file upload | Upload works after re-auth | ⬜ | |

---

## Test Summary

### Overall Results
- **Total Test Cases:** _____ / _____
- **Passed:** _____ ✅
- **Failed:** _____ ❌
- **Partial:** _____ ⚠️
- **Not Tested:** _____ ⬜

### Critical Issues Found
1. _____________________________________
2. _____________________________________
3. _____________________________________

### Minor Issues Found
1. _____________________________________
2. _____________________________________
3. _____________________________________

### Recommendations
1. _____________________________________
2. _____________________________________
3. _____________________________________

### Sign-off
- [ ] All critical test cases passed
- [ ] All blocking issues resolved
- [ ] Feature ready for production

**Tester Signature:** _____________  
**Date:** _____________

---

## Notes and Observations

### Android-Specific Notes
_____________________________________
_____________________________________
_____________________________________

### iOS-Specific Notes
_____________________________________
_____________________________________
_____________________________________

### General Notes
_____________________________________
_____________________________________
_____________________________________
