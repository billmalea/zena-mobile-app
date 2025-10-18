import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'property_card.dart';
import 'tool_cards/phone_confirmation_card.dart';
import 'tool_cards/phone_input_card.dart';
import 'tool_cards/contact_info_card.dart';
import 'tool_cards/payment_error_card.dart';
import 'tool_cards/property_submission_card.dart';
import 'tool_cards/property_hunting_card.dart';
import 'tool_cards/commission_card.dart';
import 'tool_cards/neighborhood_info_card.dart';
import 'tool_cards/affordability_card.dart';
import 'tool_cards/auth_prompt_card.dart';

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
    final phoneNumber = toolResult.result['userPhoneFromProfile'] as String? ?? 
                        toolResult.result['phoneNumber'] as String? ?? 
                        '';
    final message = toolResult.result['message'] as String? ?? '';
    final property =
        toolResult.result['property'] as Map<String, dynamic>? ?? {};

    return PhoneConfirmationCard(
      phoneNumber: phoneNumber,
      message: message,
      property: property,
      onConfirm: () {
        if (onSendMessage != null) {
          onSendMessage!('Yes, please use $phoneNumber for the payment');
        }
      },
      onDecline: () {
        if (onSendMessage != null) {
          onSendMessage!('No, I\'ll provide a different phone number');
        }
      },
    );
  }

  /// Build phone input card
  Widget _buildPhoneInputCard(BuildContext context) {
    final message = toolResult.result['message'] as String? ?? '';
    final property =
        toolResult.result['property'] as Map<String, dynamic>? ?? {};

    return PhoneInputCard(
      message: message,
      property: property,
      onSubmit: (phone) {
        if (onSendMessage != null) {
          onSendMessage!('My phone number is $phone');
        }
      },
    );
  }

  /// Build contact info card
  Widget _buildContactInfoCard(BuildContext context) {
    final contactInfo =
        toolResult.result['contactInfo'] as Map<String, dynamic>? ?? {};
    final paymentInfo =
        toolResult.result['paymentInfo'] as Map<String, dynamic>?;
    final message = toolResult.result['message'] as String? ?? '';
    final alreadyPaid = toolResult.result['alreadyPaid'] as bool? ?? false;

    return ContactInfoCard(
      contactInfo: contactInfo,
      paymentInfo: paymentInfo,
      message: message,
      alreadyPaid: alreadyPaid,
    );
  }

  /// Build payment error card
  Widget _buildPaymentErrorCard(BuildContext context) {
    final error = toolResult.result['error'] as String? ?? '';
    final errorType = toolResult.result['errorType'] as String?;
    final property =
        toolResult.result['property'] as Map<String, dynamic>? ?? {};
    final paymentInfo =
        toolResult.result['paymentInfo'] as Map<String, dynamic>?;

    return PaymentErrorCard(
      error: error,
      errorType: errorType,
      property: property,
      paymentInfo: paymentInfo,
      onRetry: () {
        if (onSendMessage != null) {
          onSendMessage!('Try again');
        }
      },
    );
  }

  /// Build contact info result (payment flow)
  Widget _buildContactInfoResult(BuildContext context) {
    // Route based on flags in the tool result
    
    // Phone confirmation needed
    if (toolResult.result['needsPhoneConfirmation'] == true) {
      return _buildPhoneConfirmationCard(context);
    }
    
    // Phone number needed
    if (toolResult.result['needsPhoneNumber'] == true) {
      return _buildPhoneInputCard(context);
    }
    
    // Success - show contact info
    if (toolResult.result['success'] == true && 
        toolResult.result['contactInfo'] != null) {
      return _buildContactInfoCard(context);
    }
    
    // Error - show error card
    if (toolResult.result['success'] == false && 
        toolResult.result['error'] != null) {
      return _buildPaymentErrorCard(context);
    }
    
    // Fallback for unknown state
    return _buildUnknownToolResult(context);
  }

  /// Build property submission result
  Widget _buildPropertySubmissionResult(BuildContext context) {
    final stage = toolResult.result['stage'] as String? ?? 'start';
    final submissionId = toolResult.result['submissionId'] as String? ?? 
                         toolResult.result['id'] as String? ?? 
                         'unknown';
    final message = toolResult.result['message'] as String? ?? '';
    final data = toolResult.result['data'] as Map<String, dynamic>?;

    return PropertySubmissionCard(
      submissionId: submissionId,
      stage: stage,
      message: message,
      data: data,
      onSendMessage: onSendMessage,
    );
  }

  /// Build property hunting result
  Widget _buildPropertyHuntingResult(BuildContext context) {
    final requestId = toolResult.result['requestId'] as String? ?? 
                      toolResult.result['id'] as String? ?? 
                      'unknown';
    final status = toolResult.result['status'] as String? ?? 'pending';
    final searchCriteria = toolResult.result['searchCriteria'] as Map<String, dynamic>? ?? 
                           toolResult.result['criteria'] as Map<String, dynamic>? ?? 
                           {};

    return PropertyHuntingCard(
      requestId: requestId,
      status: status,
      searchCriteria: searchCriteria,
      onCheckStatus: onSendMessage,
    );
  }

  /// Build neighborhood info result
  Widget _buildNeighborhoodInfoResult(BuildContext context) {
    final name = toolResult.result['name'] as String? ?? 
                 toolResult.result['neighborhood'] as String? ?? 
                 'Unknown Area';
    final description = toolResult.result['description'] as String? ?? '';
    final keyFeatures = (toolResult.result['keyFeatures'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ?? 
                        (toolResult.result['features'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ?? 
                        [];
    final safetyRating = (toolResult.result['safetyRating'] as num?)?.toDouble();
    final averageRent = toolResult.result['averageRent'] as Map<String, dynamic>?;
    
    // Convert averageRent to Map<String, double> if present
    Map<String, double>? rentMap;
    if (averageRent != null) {
      rentMap = {};
      averageRent.forEach((key, value) {
        if (value is num) {
          rentMap![key] = value.toDouble();
        }
      });
    }

    return NeighborhoodInfoCard(
      name: name,
      description: description,
      keyFeatures: keyFeatures,
      safetyRating: safetyRating,
      averageRent: rentMap,
    );
  }

  /// Build affordability result
  Widget _buildAffordabilityResult(BuildContext context) {
    final monthlyIncome = (toolResult.result['monthlyIncome'] as num?)?.toDouble() ?? 
                          (toolResult.result['income'] as num?)?.toDouble() ?? 
                          0.0;
    
    // Extract recommended range
    final recommendedRangeData = toolResult.result['recommendedRange'] as Map<String, dynamic>? ?? 
                                  toolResult.result['range'] as Map<String, dynamic>? ?? 
                                  {};
    final recommendedRange = <String, double>{};
    recommendedRangeData.forEach((key, value) {
      if (value is num) {
        recommendedRange[key] = value.toDouble();
      }
    });
    
    final affordabilityPercentage = (toolResult.result['affordabilityPercentage'] as num?)?.toDouble() ?? 
                                    (toolResult.result['percentage'] as num?)?.toDouble() ?? 
                                    30.0;
    
    // Extract budget breakdown
    final budgetBreakdownData = toolResult.result['budgetBreakdown'] as Map<String, dynamic>? ?? 
                                 toolResult.result['breakdown'] as Map<String, dynamic>? ?? 
                                 {};
    final budgetBreakdown = <String, double>{};
    budgetBreakdownData.forEach((key, value) {
      if (value is num) {
        budgetBreakdown[key] = value.toDouble();
      }
    });
    
    final tips = (toolResult.result['tips'] as List?)
                     ?.map((e) => e.toString())
                     .toList() ?? 
                 (toolResult.result['recommendations'] as List?)
                     ?.map((e) => e.toString())
                     .toList() ?? 
                 [];

    return AffordabilityCard(
      monthlyIncome: monthlyIncome,
      recommendedRange: recommendedRange,
      affordabilityPercentage: affordabilityPercentage,
      budgetBreakdown: budgetBreakdown,
      tips: tips,
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
    final amount = (toolResult.result['amount'] as num?)?.toDouble() ?? 
                   (toolResult.result['commission'] as num?)?.toDouble() ?? 
                   0.0;
    final propertyReference = toolResult.result['propertyReference'] as String? ?? 
                              toolResult.result['property'] as String? ?? 
                              toolResult.result['propertyTitle'] as String? ?? 
                              'Unknown Property';
    
    // Parse date earned
    DateTime dateEarned;
    final dateStr = toolResult.result['dateEarned'] as String? ?? 
                    toolResult.result['date'] as String?;
    if (dateStr != null) {
      try {
        dateEarned = DateTime.parse(dateStr);
      } catch (e) {
        dateEarned = DateTime.now();
      }
    } else {
      dateEarned = DateTime.now();
    }
    
    final status = toolResult.result['status'] as String? ?? 'pending';
    final totalEarnings = (toolResult.result['totalEarnings'] as num?)?.toDouble() ?? 
                          (toolResult.result['total'] as num?)?.toDouble() ?? 
                          amount;

    return CommissionCard(
      amount: amount,
      propertyReference: propertyReference,
      dateEarned: dateEarned,
      status: status,
      totalEarnings: totalEarnings,
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
    final message = toolResult.result['message'] as String? ?? 
                    toolResult.result['reason'] as String? ?? 
                    'Please sign in or create an account to continue.';
    final allowGuest = toolResult.result['allowGuest'] as bool? ?? false;

    return AuthPromptCard(
      message: message,
      onSignIn: () {
        if (onSendMessage != null) {
          onSendMessage!('Sign in');
        }
      },
      onSignUp: () {
        if (onSendMessage != null) {
          onSendMessage!('Create account');
        }
      },
      onContinueAsGuest: allowGuest
          ? () {
              if (onSendMessage != null) {
                onSendMessage!('Continue as guest');
              }
            }
          : null,
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
