import 'package:flutter/material.dart';
import '../../models/message.dart';

/// Widget to display loading state for active tool calls
/// Shows different UI based on tool state (streaming vs available)
class ToolLoadingCard extends StatelessWidget {
  final ActiveToolCall toolCall;

  const ToolLoadingCard({
    super.key,
    required this.toolCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get friendly tool name
    final friendlyName = _getFriendlyToolName(toolCall.name);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Loading indicator
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            
            // Tool name and state
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toolCall.state == 'input-streaming'
                        ? '$friendlyName...'
                        : '$friendlyName: Processing request...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get user-friendly tool name
  String _getFriendlyToolName(String toolName) {
    const friendlyNames = {
      'searchProperties': 'Searching Properties',
      'requestContactInfo': 'Getting Contact Information',
      'submitProperty': 'Submitting Property',
      'completePropertySubmission': 'Completing Property Listing',
      'getNeighborhoodInfo': 'Getting Neighborhood Information',
      'calculateAffordability': 'Calculating Affordability',
      'checkPaymentStatus': 'Checking Payment Status',
      'confirmRentalSuccess': 'Confirming Rental Success',
      'getCommissionStatus': 'Checking Commission Status',
      'getUserBalance': 'Checking Account Balance',
      'adminPropertyHunting': 'Creating Property Hunt Request',
      'propertyHuntingStatus': 'Checking Hunt Status',
    };

    return friendlyNames[toolName] ?? toolName;
  }
}
