import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'property_card.dart';
import 'tool_cards/phone_confirmation_card.dart';

/// Central factory widget for routing tool results to appropriate specialized cards
///
/// This widget acts as a router that examines the toolName and renders the
/// appropriate card widget for displaying the tool result data.
///
/// Supports 15+ tool types including:
/// - Property search results
/// - Contact info requests
/// - Property submission workflows
/// - Payment flows
/// - And more...
class ToolResultWidget extends StatelessWidget {
  /// The tool result to render
  final ToolResult toolResult;

  /// Callback for sending messages back to chat
  /// Used by interactive buttons in tool cards
  final Function(String)? onSendMessage;

  const ToolResultWidget({
    super.key,
    required this.toolResult,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or missing tool result data gracefully
    if (toolResult.result.isEmpty) {
      return _buildEmptyResultCard(context);
    }

    // Route to appropriate card based on toolName
    try {
      return _routeToCard(context);
    } catch (e) {
      // Handle any errors during card rendering
      debugPrint('Error rendering tool result for ${toolResult.toolName}: $e');
      return _buildErrorCard(context, e.toString());
    }
  }

  /// Route tool result to appropriate card widget
  Widget _routeToCard(BuildContext context) {
    switch (toolResult.toolName) {
      // Property Search Results
      case 'searchProperties':
      case 'smartSearch':
        return _buildPropertySearchResults(context);

      // Contact Info Request Flow
      case 'requestContactInfo':
        return _buildContactInfoResult(context);

      // Property Submission Workflow
      case 'submitProperty':
      case 'completePropertySubmission':
        return _buildPropertySubmissionResult(context);

      // Property Hunting
      case 'adminPropertyHunting':
      case 'propertyHuntingStatus':
        return _buildPropertyHuntingResult(context);

      // Location & Neighborhood Info
      case 'getNeighborhoodInfo':
        return _buildNeighborhoodInfoResult(context);

      // Financial Tools
      case 'calculateAffordability':
        return _buildAffordabilityResult(context);

      // Payment & Commission
      case 'checkPaymentStatus':
        return _buildPaymentStatusResult(context);
      case 'confirmRentalSuccess':
      case 'getCommissionStatus':
        return _buildCommissionResult(context);
      case 'getUserBalance':
        return _buildBalanceResult(context);

      // Authentication
      case 'requiresAuth':
        return _buildAuthPromptResult(context);

      // Unknown tool type - show fallback
      default:
        return _buildUnknownToolResult(context);
    }
  }

  /// Build property search results display
  Widget _buildPropertySearchResults(BuildContext context) {
    final properties = toolResult.result['properties'] as List?;

    if (properties == null || properties.isEmpty) {
      return _buildNoPropertiesFoundCard(context);
    }

    // Display multiple property cards
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: properties.map((propertyData) {
        return PropertyCard(
          propertyData: propertyData as Map<String, dynamic>,
        );
      }).toList(),
    );
  }

  /// Build no properties found card
  Widget _buildNoPropertiesFoundCard(BuildContext context) {
    // TODO: Implement NoPropertiesFoundCard in Task 4
    return _buildPlaceholderCard(
      context,
      icon: Icons.search_off,
      title: 'No Properties Found',
      message:
          'No properties match your search criteria. Try adjusting your filters.',
    );
  }

  /// Build phone confirmation card
  Widget _buildPhoneConfirmationCard(BuildContext context) {
    final phoneNumber = toolResult.result['phoneNumber'] as String? ?? '';
    final message = toolResult.result['message'] as String? ?? '';
    final property = toolResult.result['property'] as Map<String, dynamic>? ?? {};

    return PhoneConfirmationCard(
      phoneNumber: phoneNumber,
      message: message,
      property: property,
      onConfirm: () {
        if (onSendMessage != null) {
          onSendMessage!('Yes, use this number');
        }
      },
      onDecline: () {
        if (onSendMessage != null) {
          onSendMessage!('No, use different number');
        }
      },
    );
  }

  /// Build contact info result (payment flow)
  Widget _buildContactInfoResult(BuildContext context) {
    final stage = toolResult.result['stage'] as String?;

    switch (stage) {
      case 'phone_confirmation':
        return _buildPhoneConfirmationCard(context);

      case 'phone_input':
        // TODO: Implement PhoneInputCard in Task 6
        return _buildPlaceholderCard(
          context,
          icon: Icons.phone_android,
          title: 'Enter Phone Number',
          message: 'Please provide your phone number.',
        );

      case 'contact_info':
        // TODO: Implement ContactInfoCard in Task 7
        return _buildPlaceholderCard(
          context,
          icon: Icons.contact_phone,
          title: 'Contact Information',
          message: 'Here is the contact information you requested.',
        );

      case 'payment_error':
        // TODO: Implement PaymentErrorCard in Task 8
        return _buildPlaceholderCard(
          context,
          icon: Icons.error_outline,
          title: 'Payment Error',
          message: toolResult.result['error'] as String? ??
              'Payment failed. Please try again.',
          isError: true,
        );

      default:
        return _buildUnknownToolResult(context);
    }
  }

  /// Build property submission result
  Widget _buildPropertySubmissionResult(BuildContext context) {
    final stage = toolResult.result['stage'] as String?;

    switch (stage) {
      case 'start':
      case 'video_uploaded':
      case 'confirm_data':
      case 'provide_info':
      case 'final_confirm':
        // TODO: Implement PropertySubmissionCard in Task 9
        return _buildPlaceholderCard(
          context,
          icon: Icons.upload_file,
          title: 'Property Submission',
          message: 'Stage: ${stage ?? "unknown"}',
        );

      default:
        return _buildUnknownToolResult(context);
    }
  }

  /// Build property hunting result
  Widget _buildPropertyHuntingResult(BuildContext context) {
    // TODO: Implement PropertyHuntingCard in Task 13
    return _buildPlaceholderCard(
      context,
      icon: Icons.search,
      title: 'Property Hunting',
      message: 'Your property hunting request has been received.',
    );
  }

  /// Build neighborhood info result
  Widget _buildNeighborhoodInfoResult(BuildContext context) {
    // TODO: Implement NeighborhoodInfoCard in Task 13
    return _buildPlaceholderCard(
      context,
      icon: Icons.location_city,
      title: 'Neighborhood Information',
      message: 'Information about this neighborhood.',
    );
  }

  /// Build affordability result
  Widget _buildAffordabilityResult(BuildContext context) {
    // TODO: Implement AffordabilityCard in Task 13
    return _buildPlaceholderCard(
      context,
      icon: Icons.calculate,
      title: 'Affordability Calculator',
      message: 'Your affordability calculation results.',
    );
  }

  /// Build payment status result
  Widget _buildPaymentStatusResult(BuildContext context) {
    // TODO: Implement payment status card
    return _buildPlaceholderCard(
      context,
      icon: Icons.payment,
      title: 'Payment Status',
      message: 'Checking payment status...',
    );
  }

  /// Build commission result
  Widget _buildCommissionResult(BuildContext context) {
    // TODO: Implement CommissionCard in Task 13
    return _buildPlaceholderCard(
      context,
      icon: Icons.monetization_on,
      title: 'Commission Information',
      message: 'Your commission details.',
    );
  }

  /// Build balance result
  Widget _buildBalanceResult(BuildContext context) {
    // TODO: Implement balance card
    return _buildPlaceholderCard(
      context,
      icon: Icons.account_balance_wallet,
      title: 'Account Balance',
      message: 'Your current balance.',
    );
  }

  /// Build auth prompt result
  Widget _buildAuthPromptResult(BuildContext context) {
    // TODO: Implement AuthPromptCard in Task 13
    return _buildPlaceholderCard(
      context,
      icon: Icons.login,
      title: 'Sign In Required',
      message: 'Please sign in to continue.',
    );
  }

  /// Build fallback card for unknown tool types
  Widget _buildUnknownToolResult(BuildContext context) {
    return _buildPlaceholderCard(
      context,
      icon: Icons.help_outline,
      title: 'Unknown Tool Result',
      message:
          'Tool: ${toolResult.toolName}\n\nThis tool type is not yet supported.',
      showDebugInfo: true,
    );
  }

  /// Build error card when rendering fails
  Widget _buildErrorCard(BuildContext context, String error) {
    return _buildPlaceholderCard(
      context,
      icon: Icons.error_outline,
      title: 'Error Rendering Result',
      message: 'Failed to display tool result.\n\n$error',
      isError: true,
      showDebugInfo: true,
    );
  }

  /// Build empty result card
  Widget _buildEmptyResultCard(BuildContext context) {
    return _buildPlaceholderCard(
      context,
      icon: Icons.info_outline,
      title: 'Empty Result',
      message: 'No data available for this tool result.',
    );
  }

  /// Build a generic placeholder card for tools not yet implemented
  Widget _buildPlaceholderCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    bool showDebugInfo = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isError
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isError ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isError ? colorScheme.error : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),

            // Debug info (only in debug mode)
            if (showDebugInfo && toolResult.result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Info:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tool: ${toolResult.toolName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Keys: ${toolResult.result.keys.join(", ")}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
