import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// ContactInfoCard displays property owner/agent contact details after successful payment.
/// Matches web implementation exactly with gradient background and copy functionality.
class ContactInfoCard extends StatefulWidget {
  /// Contact information including phone, property details
  final Map<String, dynamic> contactInfo;

  /// Success message to display
  final String message;

  /// Whether the user has already paid for this property
  final bool alreadyPaid;

  /// Whether payment was confirmed
  final bool paymentConfirmed;

  const ContactInfoCard({
    super.key,
    required this.contactInfo,
    required this.message,
    this.alreadyPaid = false,
    this.paymentConfirmed = false,
  });

  @override
  State<ContactInfoCard> createState() => _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {
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

  /// Launch phone dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract contact details - matches web structure
    final phoneNumber = widget.contactInfo['phone'] as String? ?? '';
    final propertyTitle =
        widget.contactInfo['propertyTitle'] as String? ?? 'Property';
    final propertyLocation =
        widget.contactInfo['propertyLocation'] as String? ?? '';
    final rentAmount = widget.contactInfo['rentAmount'] as num? ?? 0;

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
              Colors.green.shade50.withOpacity(0.5),
              Colors.green.shade100.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with checkmark icon
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 24,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.paymentConfirmed)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Payment Confirmed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
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

              // Message
              Text(
                widget.message,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Property details section
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
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
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
                    if (propertyLocation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        propertyLocation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (rentAmount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Rent: KSh ${rentAmount.toStringAsFixed(0)}/month',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Phone number with copy button
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.blue.shade500,
                          ),
                          const SizedBox(width: 12),
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
                                  'Agent Phone Number',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _copyToClipboard(phoneNumber, 'phone'),
                            icon: Icon(
                              _copiedField == 'phone'
                                  ? Icons.check
                                  : Icons.copy,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                            tooltip:
                                _copiedField == 'phone' ? 'Copied!' : 'Copy',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Important notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Important: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text:
                                        'The agent will be contacting you shortly to arrange a viewing. You can also reach them directly at the number above. Do not make any additional finder\'s fee payments outside Zena. If an agent requests this, contact support at 0700200200.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
