# iOS Device Testing Checklist

## Device Information
- **Device Model:** _____________
- **iOS Version:** _____________
- **Build:** app.ipa
- **Test Date:** {{ Current Date }}

---

## Prerequisites for iOS Testing

⚠️ **Note:** iOS testing requires:
- macOS machine with Xcode installed
- iOS device or simulator
- Apple Developer account (for device testing)
- Proper code signing configuration

**Current Environment:** Windows 10
**Status:** ❌ iOS testing not available on Windows

---

## Alternative Testing Options

### Option 1: Use macOS Machine
1. Transfer project to macOS
2. Open project in Xcode: `open ios/Runner.xcworkspace`
3. Configure signing in Xcode
4. Build and run on iOS device or simulator

### Option 2: Use CI/CD Service
1. Set up GitHub Actions or similar
2. Configure iOS build workflow
3. Use cloud-based iOS testing

### Option 3: Use Flutter Web for Cross-Platform Testing
1. Test core functionality on web version
2. Verify API integration works
3. Test UI components

---

## Test Scenarios (When iOS Testing Becomes Available)

### ✅ 1. Google Sign In Flow (Requirement 1)

**Test Steps:**
1. Open the app on iOS device
2. Verify welcome screen displays with "Sign in with Google" button
3. Tap "Sign in with Google" button
4. Verify Google account picker appears (iOS native)
5. Select a Google account
6. Verify authentication completes successfully
7. Verify app navigates to chat screen
8. Close and reopen app
9. Verify user remains signed in (auto-login)

**iOS-Specific Checks:**
- [ ] Google Sign In uses iOS native UI
- [ ] Follows iOS design patterns
- [ ] Keychain integration works
- [ ] Face ID/Touch ID integration (if implemented)

**Expected Results:**
- [ ] Welcome screen displays correctly
- [ ] Google Sign In button follows iOS guidelines
- [ ] Authentication succeeds
- [ ] Navigation is smooth
- [ ] Session persists

**Issues Found:**
_Document any issues here_

---

### ✅ 2. Chat Messaging and Streaming (Requirements 2, 4)

**Test Steps:**
1. From chat screen, type a message: "Hello, I'm looking for a 2-bedroom apartment in Nairobi"
2. Tap send button
3. Verify user message appears immediately on the right side
4. Verify typing indicator appears
5. Verify AI response streams in real-time
6. Verify typing indicator disappears when response completes
7. Test with iOS keyboard variations

**iOS-Specific Checks:**
- [ ] iOS keyboard behavior is correct
- [ ] Keyboard dismissal works (swipe down)
- [ ] Input accessory view (if any) works
- [ ] Dark mode support (if implemented)

**Expected Results:**
- [ ] User messages appear instantly
- [ ] Typing indicator shows correctly
- [ ] AI responses stream smoothly
- [ ] Keyboard behavior is native

**Issues Found:**
_Document any issues here_

---

### ✅ 3. Property Card Display (Requirement 3)

**Test Steps:**
1. Send message: "Show me available properties in Westlands"
2. Wait for AI to call searchProperties tool
3. Verify property cards display correctly
4. Check image loading and caching
5. Test scrolling performance

**iOS-Specific Checks:**
- [ ] Images render correctly on Retina displays
- [ ] Smooth scrolling (60 FPS)
- [ ] Proper memory management
- [ ] No image distortion

**Expected Results:**
- [ ] Property cards render beautifully
- [ ] Images are crisp on Retina displays
- [ ] Scrolling is buttery smooth
- [ ] Currency formatting is correct

**Issues Found:**
_Document any issues here_

---

### ✅ 4. File Attachments (Requirement 6)

**Test Steps:**
1. Tap the attach button
2. Verify iOS photo picker appears
3. Test camera access
4. Test photo library access
5. Verify permission dialogs are iOS-native

**iOS-Specific Checks:**
- [ ] Uses iOS native photo picker
- [ ] Camera permission dialog is correct
- [ ] Photo library permission dialog is correct
- [ ] Privacy descriptions in Info.plist are shown
- [ ] Works with iOS 14+ limited photo access

**Expected Results:**
- [ ] Photo picker is native iOS UI
- [ ] Permissions are requested properly
- [ ] Camera works correctly
- [ ] Gallery selection works
- [ ] Upload succeeds

**Issues Found:**
_Document any issues here_

---

### ✅ 5. Error Scenarios (Requirement 8)

**Test Steps:**
1. Test network errors (airplane mode)
2. Test authentication errors
3. Test streaming interruptions
4. Verify error messages are user-friendly

**iOS-Specific Checks:**
- [ ] Error alerts follow iOS guidelines
- [ ] Haptic feedback on errors (if implemented)
- [ ] Network reachability detection works

**Expected Results:**
- [ ] Errors are handled gracefully
- [ ] Messages are clear
- [ ] Retry options work
- [ ] No crashes

**Issues Found:**
_Document any issues here_

---

### ✅ 6. Performance (Requirement 9)

**Test Observations:**
1. App launch time: _____ seconds (should be < 2s)
2. Message send responsiveness: _____ ms
3. Scrolling frame rate: _____ FPS (should be 60)
4. Memory usage: _____ MB (should be < 200MB)
5. Battery impact: Check in iOS Settings

**iOS-Specific Checks:**
- [ ] No memory leaks (use Xcode Instruments)
- [ ] Smooth animations (60 FPS)
- [ ] Low battery impact
- [ ] Efficient network usage

**Expected Results:**
- [ ] Fast launch time
- [ ] Smooth performance
- [ ] Low memory usage
- [ ] Minimal battery drain

**Issues Found:**
_Document any issues here_

---

### ✅ 7. Platform Integration (Requirement 10)

**Test Steps:**
1. Verify app icon displays correctly (all sizes)
2. Verify launch screen shows
3. Test app backgrounding
4. Test app switching
5. Test deep links: `zena://auth-callback`
6. Test universal links (if configured)

**iOS-Specific Checks:**
- [ ] App icon includes all required sizes
- [ ] Launch screen follows iOS guidelines
- [ ] App state restoration works
- [ ] Background modes configured correctly
- [ ] Deep linking works
- [ ] Universal links work (if configured)
- [ ] Follows iOS Human Interface Guidelines

**Expected Results:**
- [ ] App icon is correct
- [ ] Launch screen displays
- [ ] State persists correctly
- [ ] Deep links work
- [ ] Follows iOS design patterns

**Issues Found:**
_Document any issues here_

---

### ✅ 8. UI/UX Design (Requirement 7)

**Visual Inspection:**
1. Verify emerald/teal color scheme
2. Verify Inter font renders correctly
3. Check iOS-specific UI elements
4. Test safe area handling (notch devices)
5. Test on different iOS device sizes
6. Test dark mode (if supported)

**iOS-Specific Checks:**
- [ ] Safe area insets respected
- [ ] Notch/Dynamic Island handled correctly
- [ ] Status bar styling is correct
- [ ] Navigation bar follows iOS patterns
- [ ] Gestures work (swipe back, etc.)
- [ ] Dark mode support (if implemented)

**Expected Results:**
- [ ] Colors match design
- [ ] Typography is correct
- [ ] Safe areas handled properly
- [ ] Responsive to device sizes
- [ ] Follows iOS guidelines

**Issues Found:**
_Document any issues here_

---

### ✅ 9. iOS-Specific Features

**Additional iOS Tests:**
1. Test on iPhone (various sizes)
2. Test on iPad (if supported)
3. Test with VoiceOver (accessibility)
4. Test with Dynamic Type (text sizing)
5. Test with Reduce Motion enabled
6. Test with Low Power Mode

**Expected Results:**
- [ ] Works on all iPhone sizes
- [ ] iPad support (if applicable)
- [ ] Accessibility features work
- [ ] Dynamic Type supported
- [ ] Respects system settings

**Issues Found:**
_Document any issues here_

---

## Overall Test Summary

### Test Results
- **Total Tests:** 9 categories
- **Passed:** ___
- **Failed:** ___
- **Blocked:** ___

### Critical Issues
_List any critical issues that prevent core functionality_

### Minor Issues
_List any minor issues or improvements_

### iOS-Specific Issues
_List any issues specific to iOS platform_

### Recommendations
_Any recommendations for improvements or fixes_

---

## Build Instructions for iOS

### Prerequisites
```bash
# On macOS
flutter doctor
xcode-select --install
sudo gem install cocoapods
```

### Build Steps
```bash
# Navigate to project
cd zena_mobile_app

# Get dependencies
flutter pub get

# Install iOS dependencies
cd ios
pod install
cd ..

# Open in Xcode
open ios/Runner.xcworkspace

# Configure signing in Xcode:
# 1. Select Runner target
# 2. Go to Signing & Capabilities
# 3. Select your team
# 4. Xcode will automatically manage signing

# Build and run
flutter run -d <ios-device-id>

# Or build IPA
flutter build ios --release
```

### Configuration Checklist
- [ ] Bundle identifier configured: com.zena.mobile
- [ ] Team selected in Xcode
- [ ] Provisioning profile configured
- [ ] Info.plist permissions added:
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription
- [ ] Google Sign In iOS client ID added
- [ ] URL schemes configured for deep linking
- [ ] App icons added (all sizes)
- [ ] Launch screen configured

---

## Sign Off

**Tested By:** _______________
**Date:** _______________
**Device:** _______________
**iOS Version:** _______________
**Status:** ✅ Pass / ❌ Fail / ⚠️ Pass with Issues / 🚫 Not Tested

---

## Notes

- iOS testing requires macOS with Xcode
- Current environment (Windows) cannot build or test iOS apps
- All iOS-specific features should be tested on actual iOS devices
- Consider using TestFlight for beta testing
- Document all issues with screenshots
- Test on multiple iOS versions if possible (iOS 12.0+)
