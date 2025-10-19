import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'tool_result_widget.dart';
import 'tool_loading_card.dart';
import 'tool_error_card.dart';

/// Message bubble widget for displaying chat messages
/// Handles both user and assistant messages with appropriate styling
/// Also renders active tool calls (loading) and tool results
class MessageBubble extends StatelessWidget {
  final Message message;
  
  /// Callback for sending messages from interactive tool cards
  final Function(String)? onSendMessage;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Message content bubble
        if (message.content.isNotEmpty)
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: isUser
                    ? []
                    : [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show file attachment indicator if files are attached
                  if (message.metadata != null && 
                      message.metadata!['attachedFiles'] != null &&
                      (message.metadata!['attachedFiles'] as List).isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isUser
                            ? theme.colorScheme.onPrimary.withOpacity(0.2)
                            : theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 16,
                            color: isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(message.metadata!['attachedFiles'] as List).length} video${(message.metadata!['attachedFiles'] as List).length > 1 ? 's' : ''} attached',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isUser
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Message text
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Active tool calls (loading indicators)
        if (message.hasActiveToolCalls)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: message.activeToolCalls!.map((toolCall) {
                return ToolLoadingCard(toolCall: toolCall);
              }).toList(),
            ),
          ),
        
        // Tool results (rendered after message content)
        if (message.hasToolResults)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: message.toolResults!.map((toolResult) {
                // Show error card for failed tools
                if (toolResult.isError) {
                  return ToolErrorCard(
                    toolName: toolResult.toolName,
                    error: toolResult.result['error']?.toString() ?? 'Unknown error',
                  );
                }
                
                // Show normal result card for successful tools
                return ToolResultWidget(
                  toolResult: toolResult,
                  onSendMessage: onSendMessage,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
