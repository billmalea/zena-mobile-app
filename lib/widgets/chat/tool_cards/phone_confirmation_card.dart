import 'package:flutter/material.dart';
import 'card_styles.dart';

/// PhoneConfirmationCard displays a confirmation dialog for the user's phone number
/// before proceeding with the payment flow for requesting contact information.
///
/// This card is shown when the system needs to confirm the user's phone number
/// from their profile before initiating an M-Pesa payment request.
class PhoneConfirmationCard extends StatelessWidget {
  /// The phone number from the user's profile
  final String phoneNumber;

  /// The message explaining why phone confirmation is needed
  final String message;

  /// Property data for context (title, commission amount, etc.)
  final Map<String, dynamic> property;

  /// Callback when user confirms to use the displayed phone number
  final VoidCallback onConfirm;

  /// Callback when user wants to use a different phone number
  final VoidCallback onDecline;

  const PhoneConfirmationCard({
    super.key,
    required this.phoneNumber,
    required this.message,
    required this.property,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract property details
    final propertyTitle = property['title'] as String? ?? 'Property';
    final commission = property['commission'] as num? ?? 0;
    final formattedCommission = 'KES ${commission.toStringAsFixed(0)}';

    return Card(
      elevation: 2,
      margin: CardStyles.cardMargin,
      clipBehavior: Clip.antiAlias,
      shape: CardStyles.cardShape(context),
      child: Padding(
        padding: CardStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Phone Number',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Property context
            Container(
              padding: const EdgeInsets.all(12),
              decoration: CardStyles.secondaryContainer(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          propertyTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Commission: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        formattedCommission,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Explanation text
            Text(
              message.isNotEmpty
                  ? message
                  : 'We need to confirm your phone number to send the M-Pesa payment request.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Phone number display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: CardStyles.primaryContainer(context),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    phoneNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary button - Confirm
                ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Yes, use this number'),
                  style: CardStyles.primaryButton(context),
                ),
                const SizedBox(height: CardStyles.smallSpacing),

                // Secondary button - Use different number
                OutlinedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('No, use different number'),
                  style: CardStyles.secondaryButton(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
