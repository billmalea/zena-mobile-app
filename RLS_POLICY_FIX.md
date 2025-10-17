# RLS Policy Fix - Mobile App Database Access

## Problem
After fixing authentication, the mobile app was getting **500 Internal Server Error** with this message:
```
Error creating conversation: {
  code: '42501',
  details: null,
  hint: null,
  message: 'new row violates row-level security policy for table "chat_conversations"'
}
```

## Root Cause
The `conversation-operations.ts` functions were creating their own Supabase client internally using `createClient()` from `@/lib/supabase/server`, which is cookie-based and doesn't have the authenticated user context when called from mobile app requests.

### The Issue Flow
1. Mobile app sends request with `Authorization: Bearer <token>`
2. API route creates authenticated Supabase client with the token
3. API route calls `getOrCreateConversation(userId)`
4. **Problem**: `getOrCreateConversation()` creates a NEW Supabase client internally (cookie-based)
5. This new client doesn't have the Bearer token, so it's unauthenticated
6. Supabase RLS policies reject the unauthenticated request → 500 error

## Solution
Modified all conversation operation functions to accept an optional `supabaseClient` parameter. This allows the API routes to pass their authenticated client down to the database operations.

### Files Changed

**`zena/lib/conversation-operations.ts`**
- Added `SupabaseClient` type import
- Updated all functions to accept optional `supabaseClient` parameter:
  - `createConversation(userId, supabaseClient?)`
  - `getOrCreateConversation(userId, forceNew, supabaseClient?)`
  - `addMessage(conversationId, role, content, metadata?, supabaseClient?)`
  - `getConversationHistory(conversationId, limit, supabaseClient?)`
  - `getUserConversations(userId, limit, supabaseClient?)`
  - `getConversationWithMessages(conversationId, supabaseClient?)`
  - `deleteConversation(conversationId, supabaseClient?)`
  - `updateMessageMetadata(messageId, metadata, supabaseClient?)`

**`zena/app/api/chat/route.ts`**
- Updated all calls to pass the authenticated `supabase` client:
  ```typescript
  const conversation = await getOrCreateConversation(userId, false, supabase)
  await addMessage(conversationId, 'user', content, metadata, supabase)
  const history = await getConversationHistory(conversationId, 50, supabase)
  ```

**`zena/app/api/chat/conversation/route.ts`**
- Updated all calls to pass the authenticated `supabase` client:
  ```typescript
  const conversation = await getOrCreateConversation(user.id, false, supabase)
  const { conversation, messages } = await getConversationWithMessages(conversationId, supabase)
  ```

## How It Works Now

### Before (Broken)
```typescript
// API Route
const supabase = getAuthenticatedClient(req) // Has Bearer token ✅
const conversation = await getOrCreateConversation(userId)

// Inside getOrCreateConversation
const supabase = await createClient() // Creates NEW client without token ❌
await supabase.from('chat_conversations').insert(...) // RLS rejects ❌
```

### After (Fixed)
```typescript
// API Route
const supabase = getAuthenticatedClient(req) // Has Bearer token ✅
const conversation = await getOrCreateConversation(userId, false, supabase)

// Inside getOrCreateConversation
const supabase = supabaseClient || await createClient() // Uses passed client ✅
await supabase.from('chat_conversations').insert(...) // RLS accepts ✅
```

## Benefits

✅ **Maintains authentication context** - Bearer token flows through all operations  
✅ **RLS policies work correctly** - Database operations use authenticated client  
✅ **Backward compatible** - Functions still work without passing client (for web)  
✅ **No breaking changes** - Web app continues to work as before  
✅ **Consistent pattern** - All database operations follow same approach  

## Testing

After this fix:
1. Mobile app can create conversations
2. Mobile app can send messages
3. Mobile app can retrieve conversation history
4. All operations respect RLS policies
5. Web app continues to work normally

## Related Issues

This fix addresses the RLS policy violation that occurred after implementing Bearer token authentication. The authentication was working (no more 401 errors), but the database operations were failing because they weren't using the authenticated client.

## Related Files

- `zena/lib/conversation-operations.ts` - Database operations (updated)
- `zena/app/api/chat/route.ts` - Chat API (updated)
- `zena/app/api/chat/conversation/route.ts` - Conversation API (updated)
- `zena/lib/supabase/auth-helper.ts` - Authentication helper (from previous fix)

## Key Takeaway

When working with Supabase RLS policies and multiple authentication methods (cookies + Bearer tokens), always pass the authenticated client through the call chain rather than creating new clients in helper functions. This ensures the authentication context is preserved throughout the request lifecycle.
