# Chat 307 Error Fix

## Problem
When sending a message in the Flutter mobile app, users were getting a **307 Temporary Redirect** error.

## Root Cause
The Flutter app was calling `https://zena.live/api/chat` but the domain redirects to `https://www.zena.live/api/chat` (with www subdomain). The Flutter HTTP client doesn't automatically follow 307 redirects for POST requests with a body.

### Technical Details
1. **Domain Redirect**:
   - `https://zena.live` → `https://www.zena.live` (307 redirect)
   - This is a server-level redirect (likely configured in Vercel/DNS)

2. **Flutter HTTP Client Behavior**:
   - Doesn't automatically follow 307 redirects for POST requests
   - The request body is lost during the redirect
   - This causes the chat API call to fail

3. **Testing Results**:
   ```bash
   # Without www - Gets 307 redirect
   POST https://zena.live/api/chat → 307 → https://www.zena.live/api/chat
   
   # With www - Works correctly
   POST https://www.zena.live/api/chat → 401 (expected, needs auth)
   ```

## Solution
Updated the BASE_URL in `.env.local` to use the www subdomain:

```bash
# Before
BASE_URL=https://zena.live

# After
BASE_URL=https://www.zena.live
```

This ensures the Flutter app calls the correct URL directly without any redirects.

## Testing
After this fix:
1. Restart the Flutter app (hot restart may not be enough for config changes)
2. Try sending a simple message like "hello"
3. The message should now be sent successfully without 307 errors

## Why This Matters
- 307 redirects indicate the resource has temporarily moved
- HTTP clients typically don't follow 307 redirects for POST requests automatically
- The request body gets lost during the redirect
- This caused the chat functionality to completely fail
- Using the correct URL (with www) avoids the redirect entirely

## Additional Notes
- The trailing slash issue mentioned earlier was a red herring
- The real issue was the domain redirect from non-www to www
- You may want to configure your DNS/Vercel to avoid this redirect, or always use www in your configs

## Related Files
- `zena_mobile_app/.env.local` - **FIXED** - Updated BASE_URL to use www subdomain
- `zena_mobile_app/lib/config/app_config.dart` - Reads BASE_URL from .env
- `zena_mobile_app/lib/services/api_service.dart` - Handles API requests
- `zena_mobile_app/lib/services/chat_service.dart` - Uses the endpoints
- `zena/app/api/chat/route.ts` - Next.js API route
