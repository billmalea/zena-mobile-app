# Authentication Fix - Mobile App Support

## Problem
After fixing the 307 redirect issue, the mobile app was getting **401 Unauthorized** errors when trying to send chat messages.

## Root Cause
The Next.js API was only supporting **cookie-based authentication** (used by the web app), but the Flutter mobile app sends authentication tokens via the **Authorization header** (Bearer token).

### How Web vs Mobile Authentication Works

**Web App (Browser)**:
- Uses Supabase SSR (Server-Side Rendering)
- Authentication stored in HTTP-only cookies
- Next.js reads cookies automatically via `createClient()` from `@/lib/supabase/server`

**Mobile App (Flutter)**:
- Uses Supabase Flutter SDK
- Authentication stored in device secure storage
- Sends access token in `Authorization: Bearer <token>` header

## Solution
Modified the API routes to support **both authentication methods**:

### Files Updated

1. **`zena/lib/supabase/auth-helper.ts`** - NEW: Reusable authentication helper
2. **`zena/app/api/chat/route.ts`** - Main chat endpoint
3. **`zena/app/api/chat/conversation/route.ts`** - Conversation management

### Implementation

Created a reusable authentication helper (`auth-helper.ts`) that supports both methods:

```typescript
// zena/lib/supabase/auth-helper.ts
export async function getAuthenticatedClient(req: NextRequest) {
  const authHeader = req.headers.get('authorization')
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    // Mobile app authentication
    const token = authHeader.substring(7)
    const supabase = createSupabaseClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        global: {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      }
    )
    
    const { data: { user }, error } = await supabase.auth.getUser()
    return { supabase, user, error: error?.message || null }
  } else {
    // Web app authentication using cookies
    const supabase = await createClient()
    const { data: { user }, error } = await supabase.auth.getUser()
    return { supabase, user, error: error?.message || null }
  }
}
```

Then updated API routes to use this helper:

```typescript
// In API routes (e.g., chat/route.ts)
const authResult = await getAuthenticatedClient(req)

if (!authResult.user || !authResult.supabase) {
  return new Response(JSON.stringify({ 
    error: "Authentication required",
    details: authResult.error 
  }), {
    status: 401,
    headers: { 'Content-Type': 'application/json' }
  })
}

const supabase = authResult.supabase
const user = authResult.user
```

## How It Works

1. **Request arrives** at the API endpoint
2. **Check for Authorization header**:
   - If present → Mobile app authentication flow
   - If absent → Web app authentication flow (cookies)
3. **Mobile flow**:
   - Extract Bearer token from header
   - Create Supabase client with token in headers
   - Verify user with `auth.getUser()`
4. **Web flow**:
   - Use existing cookie-based client
   - Verify user with `auth.getUser()`
5. **Both flows** end up with authenticated user object

## Flutter API Service

The Flutter app already sends the token correctly:

```dart
// From api_service.dart
Future<Map<String, String>> _getHeaders() async {
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add authentication token if available
  final token = await AuthService().getAccessToken();
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  return headers;
}
```

## Testing

After this fix:
1. **Web app** continues to work with cookie-based auth
2. **Mobile app** now works with Bearer token auth
3. Both can use the same API endpoints

## Benefits

- ✅ Single API codebase supports both web and mobile
- ✅ No breaking changes to existing web app
- ✅ Proper separation of concerns (cookies for web, tokens for mobile)
- ✅ Follows Supabase best practices for each platform

## Related Files

- `zena/app/api/chat/route.ts` - Chat API with dual auth
- `zena/app/api/chat/conversation/route.ts` - Conversation API with dual auth
- `zena_mobile_app/lib/services/api_service.dart` - Flutter API client
- `zena_mobile_app/lib/services/auth_service.dart` - Flutter auth service
- `zena/lib/supabase/server.ts` - Web app Supabase client (cookie-based)
