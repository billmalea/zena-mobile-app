# Manual Testing Guide: Contact Info Request Flow with Real M-Pesa

This guide provides step-by-step instructions for manually testing the complete contact info request flow with real M-Pesa payments on a physical device.

## Prerequisites

- Physical Android or iOS device
- Active M-Pesa account with sufficient balance (at least KES 5,000 for testing)
- Test property in the database with contact info request enabled
- Backend server running and accessible
- Mobile app installed on device

## Test Environment Setup

1. **Backend Configuration**
   - Ensure backend is running and accessible
   - Verify M-Pesa API credentials are configured
   - Confirm test properties exist in database

2. **Mobile App Setup**
   - Install latest build on physical device
   - Configure API endpoint to point to backend
   - Sign in with test account
   - Verify phone number is in user profile (or not, depending on test scenario)

## Test Scenarios

### Scenario 1: Complete Successful Flow

**Objective:** Test the complete happy path from request to contact info display

**Steps:**
1. Open the app and navigate to a property listing
2. Request contact information for the property
3. Observe phone confirmation card appears
4. Verify your phone number is displayed correctly
5. Tap "Yes, use this number"
6. Wait for M-Pesa STK push prompt on your phone
7. Enter M-Pesa PIN on your phone
8. Wait for backend to process payment (up to 30 seconds)
9. Observe contact info card appears with success message
10. Verify all contact details are displayed:
    - Agent/owner name
    - Phone number
    - Email (if available)
    - Property details
    - Payment receipt information

**Expected Results:**
- ✅ Phone confirmation card displays correctly
- ✅ M-Pesa prompt appears on phone
- ✅ Payment processes successfully
- ✅ Contact info card displays with all details
- ✅ Payment receipt shows correct amount and receipt number

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 2: Phone Confirmation - Yes Button

**Objective:** Verify phone confirmation with existing profile phone number

**Steps:**
1. Ensure your profile has a phone number set
2. Request contact info for a property
3. Observe phone confirmation card
4. Verify phone number matches your profile
5. Tap "Yes, use this number"
6. Verify message is sent to backend

**Expected Results:**
- ✅ Phone number from profile is displayed
- ✅ "Yes" button is clearly visible and tappable
- ✅ Tapping "Yes" sends confirmation message
- ✅ Flow proceeds to payment

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 3: Phone Confirmation - No Button

**Objective:** Verify user can provide different phone number

**Steps:**
1. Request contact info for a property
2. Observe phone confirmation card
3. Tap "No, use different number"
4. Observe phone input card appears
5. Enter a different valid Kenyan phone number (e.g., 0798765432)
6. Tap "Submit Phone Number"
7. Verify normalized phone number is sent (+254798765432)
8. Proceed with payment on the new number

**Expected Results:**
- ✅ "No" button triggers phone input card
- ✅ Phone input card accepts Kenyan formats
- ✅ Phone number is normalized to +254 format
- ✅ M-Pesa prompt goes to the new number

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 4: Successful Payment Flow

**Objective:** Complete M-Pesa payment successfully

**Steps:**
1. Request contact info and confirm phone number
2. Wait for M-Pesa STK push prompt
3. Enter correct M-Pesa PIN
4. Wait for payment processing (backend polls status)
5. Observe contact info card appears

**Expected Results:**
- ✅ M-Pesa prompt appears within 5 seconds
- ✅ Payment processes successfully
- ✅ Contact info card shows success message
- ✅ All contact details are displayed
- ✅ Payment receipt information is shown

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 5: Cancelled Payment Flow

**Objective:** Test payment cancellation handling

**Steps:**
1. Request contact info and confirm phone number
2. Wait for M-Pesa STK push prompt
3. **Cancel the M-Pesa prompt** (tap Cancel or dismiss)
4. Wait for backend to detect cancellation
5. Observe payment error card appears

**Expected Results:**
- ✅ Error card displays "Payment Cancelled" title
- ✅ Orange cancel icon is shown
- ✅ User-friendly message explains cancellation
- ✅ Property details are still visible
- ✅ "Try Again" button is available
- ✅ No charges were made

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 6: Timeout Scenario

**Objective:** Test payment timeout handling

**Steps:**
1. Request contact info and confirm phone number
2. Wait for M-Pesa STK push prompt
3. **Do NOT respond to the prompt** (let it time out)
4. Wait for 30+ seconds
5. Observe payment error card appears

**Expected Results:**
- ✅ Error card displays "Payment Timeout" title
- ✅ Amber/yellow time icon is shown
- ✅ Message explains timeout occurred
- ✅ Helpful tip about 60-second limit is shown
- ✅ "Try Again" button is available

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 7: Failed Payment Scenario

**Objective:** Test payment failure handling (insufficient balance)

**Steps:**
1. Ensure M-Pesa account has insufficient balance
2. Request contact info and confirm phone number
3. Wait for M-Pesa STK push prompt
4. Enter M-Pesa PIN
5. Wait for payment to fail
6. Observe payment error card appears

**Expected Results:**
- ✅ Error card displays "Payment Failed" title
- ✅ Red error icon is shown
- ✅ Message explains insufficient balance
- ✅ Helpful tip about checking balance is shown
- ✅ "Try Again" button is available

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 8: Retry After Error

**Objective:** Test retry functionality after payment errors

**Steps:**
1. Trigger any payment error (cancel, timeout, or failure)
2. Observe error card with "Try Again" button
3. Tap "Try Again" button
4. Verify retry message is sent
5. Complete payment successfully this time
6. Observe contact info card appears

**Expected Results:**
- ✅ "Try Again" button is clearly visible
- ✅ Tapping button sends retry message
- ✅ New payment flow starts
- ✅ Successful payment shows contact info

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 9: Call Button Functionality

**Objective:** Test phone call functionality

**Steps:**
1. Complete payment successfully to get contact info
2. Observe contact info card with phone number
3. Locate "Call" button
4. Tap "Call" button
5. Verify phone dialer opens with correct number

**Expected Results:**
- ✅ "Call" button is visible and styled correctly
- ✅ Phone icon is displayed on button
- ✅ Tapping button opens phone dialer
- ✅ Correct phone number is pre-filled in dialer
- ✅ User can make call from dialer

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 10: WhatsApp Button Functionality

**Objective:** Test WhatsApp integration

**Steps:**
1. Complete payment successfully to get contact info
2. Observe contact info card with phone number
3. Locate "WhatsApp" button
4. Tap "WhatsApp" button
5. Verify WhatsApp opens with correct number

**Expected Results:**
- ✅ "WhatsApp" button is visible with green styling
- ✅ Chat icon is displayed on button
- ✅ Tapping button opens WhatsApp app
- ✅ Correct phone number is pre-filled
- ✅ User can start chat from WhatsApp

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

### Scenario 11: Backend Polling Verification

**Objective:** Verify mobile app doesn't poll, backend handles it

**Steps:**
1. Enable network monitoring on device (e.g., Charles Proxy)
2. Request contact info and confirm phone number
3. Complete M-Pesa payment
4. Monitor network requests during payment processing
5. Verify mobile app makes NO polling requests

**Expected Results:**
- ✅ Mobile app sends initial request
- ✅ Mobile app waits for response (no polling)
- ✅ Backend returns final result after internal polling
- ✅ Mobile app displays result immediately
- ✅ No repeated API calls from mobile app

**Pass/Fail:** ___________

**Notes:** ___________________________________________

---

## Edge Cases

### Edge Case 1: Already Paid Property

**Steps:**
1. Request contact info for a property you've already paid for
2. Observe contact info card appears immediately
3. Verify "Contact Info Retrieved" message (not "Payment Successful")
4. Verify payment receipt section is NOT shown

**Expected Results:**
- ✅ No payment flow triggered
- ✅ Contact info displayed immediately
- ✅ Different message for already paid
- ✅ No payment details shown

**Pass/Fail:** ___________

---

### Edge Case 2: Property with Video Link

**Steps:**
1. Complete payment for property with video
2. Observe contact info card
3. Locate "Watch Property Video" button
4. Tap button
5. Verify video opens in browser/player

**Expected Results:**
- ✅ Video button is visible
- ✅ Play icon is shown
- ✅ Tapping opens video link
- ✅ Video plays correctly

**Pass/Fail:** ___________

---

### Edge Case 3: Phone Number Validation

**Steps:**
1. Trigger phone input card
2. Test various phone formats:
   - Valid: +254712345678, 254712345678, 0712345678, 0112345678
   - Invalid: 12345, +1234567890, abcdefghij, 0812345678
3. Verify validation messages
4. Verify submit button enable/disable

**Expected Results:**
- ✅ Valid formats enable submit button
- ✅ Invalid formats show error message
- ✅ Submit button disabled for invalid input
- ✅ Clear button works correctly

**Pass/Fail:** ___________

---

### Edge Case 4: Network Interruption

**Steps:**
1. Start payment flow
2. Disable network during payment processing
3. Re-enable network
4. Observe error handling

**Expected Results:**
- ✅ Appropriate error message shown
- ✅ Retry option available
- ✅ No app crash

**Pass/Fail:** ___________

---

## Performance Checks

### Check 1: Payment Processing Time

**Measurement:**
- Time from phone confirmation to M-Pesa prompt: _______ seconds
- Time from M-Pesa completion to contact info display: _______ seconds
- Total flow time: _______ seconds

**Expected:** < 5 seconds for prompt, < 35 seconds total

**Pass/Fail:** ___________

---

### Check 2: UI Responsiveness

**Observations:**
- Cards render smoothly: Yes / No
- Buttons respond immediately: Yes / No
- No UI freezing during payment: Yes / No
- Animations are smooth: Yes / No

**Pass/Fail:** ___________

---

## Platform-Specific Tests

### Android-Specific

1. **M-Pesa Prompt Display**
   - Prompt appears as overlay: ___________
   - Can switch back to app: ___________
   - Prompt persists correctly: ___________

2. **URL Launcher Permissions**
   - Call button works: ___________
   - WhatsApp button works: ___________
   - No permission errors: ___________

### iOS-Specific

1. **M-Pesa Prompt Display**
   - Prompt appears correctly: ___________
   - Can switch back to app: ___________
   - Prompt persists correctly: ___________

2. **URL Launcher Permissions**
   - Call button works: ___________
   - WhatsApp button works: ___________
   - No permission errors: ___________

---

## Test Summary

**Date:** ___________
**Tester:** ___________
**Device:** ___________
**OS Version:** ___________
**App Version:** ___________

**Total Scenarios:** 11
**Passed:** ___________
**Failed:** ___________
**Blocked:** ___________

**Critical Issues Found:**
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

**Minor Issues Found:**
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

**Overall Assessment:** Pass / Fail / Needs Rework

**Sign-off:** ___________________________________________

---

## Troubleshooting Guide

### Issue: M-Pesa prompt doesn't appear

**Possible Causes:**
- Phone number not registered with M-Pesa
- Backend M-Pesa API credentials incorrect
- Network connectivity issues

**Solutions:**
- Verify phone number is M-Pesa registered
- Check backend logs for API errors
- Test network connectivity

---

### Issue: Payment succeeds but contact info doesn't show

**Possible Causes:**
- Backend polling timeout
- Contact info not in database
- Network interruption

**Solutions:**
- Check backend logs for polling status
- Verify property has contact info in database
- Retry the request

---

### Issue: Call/WhatsApp buttons don't work

**Possible Causes:**
- Missing platform permissions
- URL launcher not configured
- App not installed (WhatsApp)

**Solutions:**
- Check AndroidManifest.xml / Info.plist
- Verify url_launcher package installed
- Install WhatsApp for WhatsApp test

---

## Notes

- Always test with real M-Pesa to verify end-to-end flow
- Test on both Android and iOS if possible
- Document any unexpected behavior
- Take screenshots of errors for bug reports
- Test with different network conditions (WiFi, 4G, 3G)
- Test with different M-Pesa account states (sufficient/insufficient balance)

---

## Appendix: Test Data

### Test Properties

| Property ID | Title | Commission | Has Video | Notes |
|------------|-------|------------|-----------|-------|
| prop_001 | 2BR Westlands | 5000 | No | Standard test |
| prop_002 | 3BR Karen | 7500 | Yes | With video |
| prop_003 | 1BR CBD | 3000 | No | Low commission |

### Test Phone Numbers

| Number | Format | Valid | Notes |
|--------|--------|-------|-------|
| +254712345678 | International | Yes | Primary test |
| 0712345678 | Local | Yes | Alternative format |
| 254712345678 | No prefix | Yes | No + prefix |
| 0812345678 | Wrong prefix | No | Invalid prefix |

---

**End of Manual Testing Guide**
