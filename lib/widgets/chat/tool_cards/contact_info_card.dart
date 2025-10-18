import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ContactInfoCard displays property owner/agent contact details after successful payment.
///
/// This card is shown when the user has successfully paid the commission fee
/// and can now access the property owner's contact information.
class ContactInfoCard extends StatelessWidget {
  /// Contact information including name, phone, email, etc.
  final Map<String, dynamic> contactInfo;

  /// Payment information including receipt, amount, etc.
  final Map<String, dynamic>? paymentInfo;

  /// Success message to display
  final String message;

  /// Whether the user has already paid for this property
  final bool alreadyPaid;

  const ContactInfoCard({
    super.key,
    required this.contactInfo,
    this.paymentInfo,
    required this.message,
    this.alreadyPaid = false,
  });

  /// Launch phone dialer with the provided phone number
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// Launch WhatsApp with the provided phone number
  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters and ensure proper format
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure number starts with country code
    if (!cleanNumber.startsWith('+')) {
      // Assume Kenyan number if no country code
      if (cleanNumber.startsWith('0')) {
        cleanNumber = '+254${cleanNumber.substring(1)}';
      } else if (cleanNumber.startsWith('254')) {
        cleanNumber = '+$cleanNumber';
      } else {
        cleanNumber = '+254$cleanNumber';
      }
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch video link in browser
  Future<void> _openVideoLink(String videoUrl) async {
    final Uri videoUri = Uri.parse(videoUrl);
    if (await canLaunchUrl(videoUri)) {
      await launchUrl(videoUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract contact details
    final ownerName = contactInfo['name'] as String? ?? 
                      contactInfo['ownerName'] as String? ?? 
                      contactInfo['agentName'] as String? ?? 
                      'Property Owner';
    final phoneNumber = contactInfo['phone'] as String? ?? 
                        contactInfo['phoneNumber'] as String? ?? 
                        '';
    final email = contactInfo['email'] as String?;
    final propertyTitle = contactInfo['propertyTitle'] as String? ?? 
                          contactInfo['title'] as String? ?? 
                          'Property';
    final videoLink = contactInfo['videoLink'] as String? ?? 
                      contactInfo['video'] as String?;

    // Extract payment details
    final paymentAmount = paymentInfo?['amount'] as num? ?? 
                          paymentInfo?['commission'] as num?;
    final receiptNumber = paymentInfo?['receiptNumber'] as String? ?? 
                          paymentInfo?['receipt'] as String? ?? 
                          paymentInfo?['transactionId'] as String?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header with checkmark
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
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
                          alreadyPaid ? 'Contact Info Retrieved' : 'Payment Successful!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        if (message.isNotEmpty)
                          Text(
                            message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
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
              child: Row(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
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
            ),
            const SizedBox(height: 16),

            // Contact information section
            Text(
              'Contact Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Owner/Agent name
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ownerName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Phone number with action buttons
            if (phoneNumber.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            phoneNumber,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(phoneNumber),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openWhatsApp(phoneNumber),
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: const Color(0xFF25D366), // WhatsApp green
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Email if available
            if (email != null && email.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Payment receipt information
            if (paymentInfo != null && !alreadyPaid) ...[
              const Divider(height: 24),
              Text(
                'Payment Receipt',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (paymentAmount != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'KES ${paymentAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    if (receiptNumber != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Receipt:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            receiptNumber,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Video link button if available
            if (videoLink != null && videoLink.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openVideoLink(videoLink),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Watch Property Video'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
