import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PaymentStatusCard displays payment information and status
/// Matches web implementation with status indicators and retry functionality
class PaymentStatusCard extends StatefulWidget {
  /// Payment information including ID, amount, status, etc.
  final Map<String, dynamic> paymentInfo;

  /// Callback for retry payment action
  final VoidCallback? onRetryPayment;

  const PaymentStatusCard({
    super.key,
    required this.paymentInfo,
    this.onRetryPayment,
  });

  @override
  State<PaymentStatusCard> createState() => _PaymentStatusCardState();
}

class _PaymentStatusCardState extends State<PaymentStatusCard> {
  String? _copiedField;

  /// Copy text to clipboard
  Future<void> _copyToClipboard(String text, String field) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _copiedField = field;
    });
    
    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedField = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract payment details
    final paymentId = widget.paymentInfo['paymentId'] as String? ?? 
                      widget.paymentInfo['id'] as String? ?? '';
    final propertyTitle = widget.paymentInfo['propertyTitle'] as String? ?? 'Property';
    final amount = widget.paymentInfo['amount'] as num? ?? 0;
    final status = widget.paymentInfo['status'] as String? ?? 'pending';
    final checkoutRequestId = widget.paymentInfo['checkoutRequestId'] as String? ?? 
                              widget.paymentInfo['CheckoutRequestID'] as String? ?? '';
    final phoneNumber = widget.paymentInfo['phoneNumber'] as String? ?? 
                        widget.paymentInfo['phone'] as String? ?? '';
    final createdAt = widget.paymentInfo['createdAt'] as String? ?? 
                      widget.paymentInfo['created_at'] as String? ?? '';

    // Get status info
    final statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusInfo['bgColor'].withOpacity(0.1),
              statusInfo['bgColor'].withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusInfo['bgColor'].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusInfo['icon'],
                      size: 20,
                      color: statusInfo['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment ${_getStatusText(status)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusInfo['bgColor'],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusInfo['label'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property title
                    Row(
                      children: [
                        const Icon(
                          Icons.home,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            propertyTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          'KSh ${amount.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),

                    if (paymentId.isNotEmpty) ...[ 
                      const SizedBox(height: 12),
                      // Payment ID with copy button
                      _buildCopyableField(
                        context,
                        'Payment ID',
                        paymentId,
                        'paymentId',
                        Icons.receipt,
                      ),
                    ],

                    if (checkoutRequestId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Checkout Request ID with copy button
                      _buildCopyableField(
                        context,
                        'Checkout Request ID',
                        checkoutRequestId,
                        'checkoutId',
                        Icons.qr_code,
                      ),
                    ],

                    if (phoneNumber.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Phone number
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.blue.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phoneNumber,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Phone Number',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Created at
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateTime(createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (status == 'failed' && widget.onRetryPayment != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onRetryPayment,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              // Status-specific messages
              if (status == 'pending') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please complete the payment on your phone. You will receive an M-Pesa prompt shortly.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (status == 'success') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment successful! You can now access the property contact information.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade800,
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
      ),
    );
  }

  /// Build copyable field with copy button
  Widget _buildCopyableField(
    BuildContext context,
    String label,
    String value,
    String fieldKey,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(value, fieldKey),
            icon: Icon(
              _copiedField == fieldKey ? Icons.check : Icons.copy,
              size: 16,
              color: Colors.blue.shade600,
            ),
            tooltip: _copiedField == fieldKey ? 'Copied!' : 'Copy',
          ),
        ],
      ),
    );
  }

  /// Get status information (color, icon, etc.)
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return {
          'color': Colors.green.shade600,
          'bgColor': Colors.green.shade600,
          'icon': Icons.check_circle,
          'label': 'SUCCESS',
        };
      case 'failed':
      case 'error':
        return {
          'color': Colors.red.shade600,
          'bgColor': Colors.red.shade600,
          'icon': Icons.error,
          'label': 'FAILED',
        };
      case 'pending':
      case 'processing':
      default:
        return {
          'color': Colors.orange.shade600,
          'bgColor': Colors.orange.shade600,
          'icon': Icons.schedule,
          'label': 'PENDING',
        };
    }
  }

  /// Get status text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return 'Successful';
      case 'failed':
      case 'error':
        return 'Failed';
      case 'pending':
      case 'processing':
      default:
        return 'Pending';
    }
  }

  /// Format date time
  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
