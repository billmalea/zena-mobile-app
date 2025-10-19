import 'package:flutter/material.dart';

/// Widget to display tool execution errors
class ToolErrorCard extends StatelessWidget {
  final String toolName;
  final String error;

  const ToolErrorCard({
    super.key,
    required this.toolName,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get friendly tool name
    final friendlyName = _getFriendlyToolName(toolName);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: colorScheme.errorContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$friendlyName Error',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Error message
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
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
      'searchProperties': 'Property Search',
      'requestContactInfo': 'Contact Request',
      'submitProperty': 'Property Submission',
      'completePropertySubmission': 'Property Listing',
      'getNeighborhoodInfo': 'Neighborhood Info',
      'calculateAffordability': 'Affordability Calculator',
      'checkPaymentStatus': 'Payment Status',
      'confirmRentalSuccess': 'Rental Confirmation',
      'getCommissionStatus': 'Commission Status',
      'getUserBalance': 'Account Balance',
      'adminPropertyHunting': 'Property Hunt',
      'propertyHuntingStatus': 'Hunt Status',
    };

    return friendlyNames[toolName] ?? toolName;
  }
}
