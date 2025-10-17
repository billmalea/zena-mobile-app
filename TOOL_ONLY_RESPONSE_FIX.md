# Tool-Only Response Issue

## Problem Identified

When you sent "Hello", the AI:
1. ✅ Called `searchProperties` tool
2. ✅ Got tool results
3. ❌ **Did NOT generate any text response**

## Log Analysis

```
📦 Chunk #3: tool-input-start (searchProperties)
📦 Chunk #4: tool-output-available (results)
📦 Chunk #6: finish-step
📦 Chunk #7: [DONE]
```

**Missing:** No `text-delta` or `0:"text"` events!

## Root Cause

The backend AI is calling tools but not generating text to explain the results. This happens when:

1. **Tool-only mode** - AI thinks it should only call tools
2. **Missing text generation** - AI doesn't synthesize results into text
3. **System prompt issue** - Prompt might be too tool-focused

## Solutions

### Solution 1: Update System Prompt (Backend)

The system prompt should encourage text responses:

```typescript
const systemInstructions = `You are Zena, an AI assistant.

CRITICAL: Always provide a text response to the user, even when using tools.

When using tools:
1. Call the tool
2. Wait for results
3. ALWAYS explain the results in natural language

Example:
User: "Hello"
Response: "Hello! Welcome to Zena. How can I help you today?"
(No tools needed for greetings)

User: "Find properties in Nairobi"
1. Call searchProperties
2. Get results
3. Response: "I found 5 properties in Nairobi. Here are the details..."
`;
```

### Solution 2: Handle Tool-Only Responses (Mobile)

Update the mobile app to show tool results even without text:

```dart
// In ChatProvider
if (event.isToolResult) {
  // If we have tool results but no text, generate a message
  if (currentMessage.content.isEmpty) {
    final toolName = event.toolResult!['toolName'] as String?;
    _messages[messageIndex] = currentMessage.copyWith(
      content: 'I found some results for you:',
      toolResults: updatedToolResults,
    );
  }
}
```

### Solution 3: Force Text Generation (Backend)

Modify the AI SDK call to require text:

```typescript
const result = streamText({
  model: google("gemini-2.5-flash-lite"),
  system: systemInstructions,
  messages: modelMessages,
  tools: allTools,
  toolChoice: "auto", // Let AI decide, but encourage text
  maxOutputTokens: 2000,
  temperature: 0.7, // Increase for more natural responses
});
```

## Immediate Fix

For now, let's update the mobile app to handle tool-only responses gracefully.

### Update ChatProvider

```dart
void _handleChatEvent(ChatEvent event, String assistantMessageId) {
  final messageIndex = _messages.indexWhere((m) => m.id == assistantMessageId);
  if (messageIndex == -1) return;

  final currentMessage = _messages[messageIndex];

  if (event.isToolResult && event.toolResult != null) {
    // Add tool result
    final toolResult = ToolResult(
      toolName: event.toolResult!['toolName'] as String? ?? 'unknown',
      result: event.toolResult!,
    );

    final updatedToolResults = List<ToolResult>.from(
      currentMessage.toolResults ?? [],
    )..add(toolResult);

    // If no text content yet, add a default message
    String content = currentMessage.content;
    if (content.isEmpty && updatedToolResults.isNotEmpty) {
      content = 'Here are the results:';
    }

    _messages[messageIndex] = currentMessage.copyWith(
      content: content,
      toolResults: updatedToolResults,
    );
    notifyListeners();
  }
}
```

## Testing

After applying the fix:

1. Send "Hello" again
2. You should see:
   - Tool results displayed
   - Default message if no text
   - UI updates properly

## Long-term Solution

Update the backend system prompt to always generate text responses, not just tool calls.

---

**Status:** Issue identified  
**Cause:** AI generating tool calls without text  
**Fix:** Handle tool-only responses in mobile app  
**Long-term:** Update backend prompt
