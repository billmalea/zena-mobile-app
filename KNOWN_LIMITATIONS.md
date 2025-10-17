# Known Limitations - Mobile App

## AI Tool Authentication (Potential Issue)

### Status
⚠️ **Potential issue** - Not yet encountered in testing, but theoretically possible

### Description
AI tools (like `requestContactInfo`, `submitProperty`, etc.) create their own Supabase clients internally and call `auth.getUser()` to verify authentication. These tools use `createClient()` from `@/lib/supabase/server`, which is cookie-based and won't work with mobile Bearer token authentication.

### Affected Tools
- `enhancedRequestContactInfoTool` - Request property contact info
- `submitPropertyToolRefactored` - Submit property listings  
- `completePropertySubmissionTool` - Complete property submission
- `confirmRentalSuccessTool` - Confirm rental success
- `getCommissionStatusTool` - Get commission status
- `getUserBalanceTool` - Get user balance
- `adminPropertyHuntingTool` - Create property hunting requests
- `propertyHuntingStatusTool` - Check hunting status

### Why This Might Not Be an Issue Yet
1. Tools are only called when the AI decides to use them
2. Simple chat messages don't trigger tools
3. The conversation creation (which we fixed) happens before tools are called
4. If a tool fails, the AI can respond with text instead

### When This Would Become an Issue
- User asks to "find properties" → AI calls search tool → Tool needs auth → Would fail for mobile
- User asks to "submit a property" → AI calls submit tool → Tool needs auth → Would fail for mobile
- User asks for "contact info" → AI calls contact tool → Tool needs auth → Would fail for mobile

### Potential Solutions

#### Option 1: Use Service Role in Tools (Recommended)
Modify tools to use service role client for database operations, but verify user ID is passed from chat context.

**Pros:**
- Works for both web and mobile
- No changes to AI SDK usage
- Tools remain secure (verify user ID)

**Cons:**
- Tools can't call `auth.getUser()` directly
- Need to pass user ID through tool parameters or global context

#### Option 2: AsyncLocalStorage Context
Use Node.js AsyncLocalStorage to store authenticated client in request context.

**Pros:**
- Tools can access authenticated client without parameter passing
- Maintains RLS protection

**Cons:**
- More complex implementation
- Requires wrapping streamText execution
- Potential issues with async boundaries

#### Option 3: Modify AI SDK Tool Execution
Fork or extend AI SDK to support passing context to tools.

**Pros:**
- Clean solution
- Tools receive authenticated client as parameter

**Cons:**
- Requires maintaining fork or waiting for upstream support
- Most complex solution

### Recommended Action
**Wait and see approach:**
1. Monitor for tool-related errors in mobile app
2. If errors occur, implement Option 1 (service role with user ID verification)
3. Document any workarounds needed

### Testing
To test if this is an issue:
1. Open mobile app
2. Send message: "I want to find a 2-bedroom apartment in Nairobi"
3. AI should call search tool
4. Check if it works or returns auth error

### Related Files
- `zena/lib/tools/**/*.ts` - All AI tool implementations
- `zena/lib/supabase/server.ts` - Cookie-based client creation
- `zena/lib/supabase/auth-helper.ts` - Dual auth helper (API routes only)

### Notes
- The conversation operations fix (passing authenticated client) solved the immediate issue
- Tools are a separate concern because they're called by the AI SDK framework
- This limitation only affects mobile app, web app works fine
- Most chat interactions don't require tools, so impact may be minimal
