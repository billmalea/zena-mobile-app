import 'package:flutter/material.dart';

/// PaymentErrorCard displays payment errors with appropriate styling and retry options.
///
/// This card is shown when a payment fails, is cancelled, times out, or encounters
/// a processing error. It provides user-friendly error messages and a retry button.
class PaymentErrorCard extends StatelessWidget {
  /// The error message to display
  final String error;

  /// The type of error (PAYMENT_CANCELLED, PAYMENT_TIMEOUT, PAYMENT_FAILED, PAYMENT_PROCESSING_ERROR)
  final String? errorType;

  /// Property data for context (title, commission amount, etc.)
  final Map<String, dynamic> property;

  /// Payment information if available
  final Map<String, dynamic>? paymentInfo;

  /// Callback when user taps the "Try Again" button
  final VoidCallback onRetry;

  const PaymentErrorCard({
    super.key,
    required this.error,
    this.errorType,
    required this.property,
    this.paymentInfo,
    required this.onRetry,
  });

  /// Get error icon based on error type
  IconData _getErrorIcon() {
    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return Icons.cancel_outlined;
      case 'PAYMENT_TIMEOUT':
        return Icons.access_time_outlined;
      case 'PAYMENT_FAILED':
        return Icons.error_outline;
      case 'PAYMENT_PROCESSING_ERROR':
        return Icons.warning_amber_outlined;
      default:
        return Icons.error_outline;
    }
  }

  /// Get error color based on error type
  Color _getErrorColor() {
    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return Colors.orange;
      case 'PAYMENT_TIMEOUT':
        return Colors.amber;
      case 'PAYMENT_FAILED':
        return Colors.red;
      case 'PAYMENT_PROCESSING_ERROR':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  /// Get user-friendly error title based on error type
  String _getErrorTitle() {
    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return 'Payment Cancelled';
      case 'PAYMENT_TIMEOUT':
        return 'Payment Timeout';
      case 'PAYMENT_FAILED':
        return 'Payment Failed';
      case 'PAYMENT_PROCESSING_ERROR':
        return 'Processing Error';
      default:
        return 'Payment Error';
    }
  }

  /// Get darker shade of color for text
  Color _getDarkerColor(Color color, double factor) {
    return Color.fromRGBO(
      (color.red * factor).round(),
      (color.green * factor).round(),
      (color.blue * factor).round(),
      1,
    );
  }

  /// Get user-friendly error message
  String _getUserFriendlyMessage() {
    if (error.isNotEmpty) {
      return error;
    }

    switch (errorType) {
      case 'PAYMENT_CANCELLED':
        return 'You cancelled the payment request. No charges were made.';
      case 'PAYMENT_TIMEOUT':
        return 'The payment request timed out. Please try again and complete the M-Pesa prompt quickly.';
      case 'PAYMENT_FAILED':
        return 'The payment could not be processed. Please check your M-Pesa balance and try again.';
      case 'PAYMENT_PROCESSING_ERROR':
        return 'There was an error processing your payment. Please try again or contact support if the issue persists.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final errorColor = _getErrorColor();

    // Extract property details
    final propertyTitle = property['title'] as String? ?? 'Property';
    final commission = property['commission'] as num? ?? 
                       paymentInfo?['amount'] as num? ?? 
                       0;
    final formattedCommission = 'KES ${commission.toStringAsFixed(0)}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: errorColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header with icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getErrorIcon(),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getErrorTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getDarkerColor(errorColor, 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUserFriendlyMessage(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getDarkerColor(errorColor, 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Property details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
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

            // Payment info if available
            if (paymentInfo != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (paymentInfo!['phoneNumber'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Phone: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            paymentInfo!['phoneNumber'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    if (paymentInfo!['transactionId'] != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Transaction: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              paymentInfo!['transactionId'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Try Again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Help text for specific error types
            if (errorType == 'PAYMENT_TIMEOUT' || errorType == 'PAYMENT_FAILED') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorType == 'PAYMENT_TIMEOUT'
                            ? 'Tip: Make sure to complete the M-Pesa prompt within 60 seconds.'
                            : 'Tip: Ensure you have sufficient M-Pesa balance and your phone is active.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
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
