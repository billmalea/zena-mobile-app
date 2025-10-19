import 'package:flutter/material.dart';

/// FinalReviewCard displays the complete property data for final review
/// Matches web implementation with all property details and confirmation prompt
class FinalReviewCard extends StatelessWidget {
  /// Complete property data
  final Map<String, dynamic> data;

  /// Video URL
  final String? videoUrl;

  /// Message to display
  final String? message;

  const FinalReviewCard({
    super.key,
    required this.data,
    this.videoUrl,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              Colors.blue.shade50.withOpacity(0.5),
              Colors.indigo.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message ?? '🎉 Ready to List Your Property!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Title
              if (data['title'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  data['title'].toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              // Description
              if (data['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  data['description'].toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],

              // Video Preview
              if (videoUrl != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.videocam,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Property Video',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              // Property Details Grid
              const SizedBox(height: 16),
              Divider(color: colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 16),
              _buildDetailsGrid(context),

              // Amenities
              if (data['amenities'] != null &&
                  (data['amenities'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
                _buildAmenities(context),
              ],

              // Action Prompt
              const SizedBox(height: 16),
              Divider(color: colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    'Should I create this listing?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Say "Yes" to confirm, or make any final changes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (data['propertyType'] != null)
          _buildDetailItem(
            context,
            Icons.apartment,
            'Type',
            _formatPropertyType(data['propertyType']),
          ),
        if (data['bedrooms'] != null)
          _buildDetailItem(
            context,
            Icons.bed,
            'Bedrooms',
            data['bedrooms'].toString(),
          ),
        if (data['bathrooms'] != null)
          _buildDetailItem(
            context,
            Icons.bathtub,
            'Bathrooms',
            data['bathrooms'].toString(),
          ),
        if (data['rentAmount'] != null)
          _buildDetailItem(
            context,
            Icons.attach_money,
            'Monthly Rent',
            'KSh ${(data['rentAmount'] as num).toStringAsFixed(0)}',
          ),
        if (data['location'] != null)
          _buildDetailItem(
            context,
            Icons.location_on,
            'Location',
            data['location'].toString(),
          ),
        if (data['commissionAmount'] != null)
          _buildDetailItem(
            context,
            Icons.attach_money,
            'Finder\'s Fee',
            'KSh ${(data['commissionAmount'] as num).toStringAsFixed(0)}',
          ),
        if (data['contactPhone'] != null)
          _buildDetailItem(
            context,
            Icons.phone,
            'Contact',
            data['contactPhone'].toString(),
          ),
        if (data['depositAmount'] != null)
          _buildDetailItem(
            context,
            Icons.account_balance_wallet,
            'Deposit',
            'KSh ${(data['depositAmount'] as num).toStringAsFixed(0)}',
            fullWidth: true,
          ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: fullWidth ? double.infinity : null,
      constraints: fullWidth ? null : const BoxConstraints(minWidth: 150),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final amenities = data['amenities'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                amenity.toString(),
                style: theme.textTheme.bodySmall,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatPropertyType(dynamic type) {
    final typeMap = {
      'bedsitter': 'Bedsitter',
      'studio': 'Studio',
      'oneBedroom': 'One Bedroom',
      'twoBedroom': 'Two Bedroom',
      'threeBedroom': 'Three Bedroom',
    };
    return typeMap[type.toString()] ?? type.toString();
  }
}
