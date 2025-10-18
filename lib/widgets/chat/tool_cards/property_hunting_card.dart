import 'package:flutter/material.dart';

/// PropertyHuntingCard displays property hunting request status and details.
///
/// This card is shown when a user requests property hunting services
/// or checks the status of an existing hunting request.
class PropertyHuntingCard extends StatelessWidget {
  /// Unique identifier for the hunting request
  final String requestId;

  /// Current status of the hunting request
  final String status;

  /// Search criteria for the property hunt
  final Map<String, dynamic> searchCriteria;

  /// Callback to check status of the hunting request
  final Function(String)? onCheckStatus;

  const PropertyHuntingCard({
    super.key,
    required this.requestId,
    required this.status,
    required this.searchCriteria,
    this.onCheckStatus,
  });

  /// Get status color based on status value
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'searching':
        return Colors.blue;
      case 'completed':
      case 'found':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon based on status value
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'searching':
        return Icons.search;
      case 'completed':
      case 'found':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(status);

    // Extract search criteria
    final location = searchCriteria['location'] as String? ?? 'Any location';
    final minRent = searchCriteria['minRent'] as num?;
    final maxRent = searchCriteria['maxRent'] as num?;
    final bedrooms = searchCriteria['bedrooms'] as num?;
    final propertyType = searchCriteria['propertyType'] as String?;

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
            // Header with status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    size: 24,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Hunting Request',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Request ID
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Request ID: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      requestId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search criteria section
            Text(
              'Search Criteria',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Location
            _buildCriteriaRow(
              context,
              Icons.location_on_outlined,
              'Location',
              location,
            ),
            const SizedBox(height: 8),

            // Rent range
            if (minRent != null || maxRent != null)
              _buildCriteriaRow(
                context,
                Icons.monetization_on_outlined,
                'Rent Range',
                _formatRentRange(minRent, maxRent),
              ),
            if (minRent != null || maxRent != null) const SizedBox(height: 8),

            // Bedrooms
            if (bedrooms != null)
              _buildCriteriaRow(
                context,
                Icons.bed_outlined,
                'Bedrooms',
                '$bedrooms',
              ),
            if (bedrooms != null) const SizedBox(height: 8),

            // Property type
            if (propertyType != null)
              _buildCriteriaRow(
                context,
                Icons.home_outlined,
                'Property Type',
                propertyType,
              ),

            const SizedBox(height: 16),

            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getStatusMessage(status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Check status button
            if (onCheckStatus != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onCheckStatus!('Check status of request $requestId'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a criteria row with icon, label, and value
  Widget _buildCriteriaRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Format rent range for display
  String _formatRentRange(num? minRent, num? maxRent) {
    if (minRent != null && maxRent != null) {
      return 'KES ${minRent.toStringAsFixed(0)} - ${maxRent.toStringAsFixed(0)}';
    } else if (minRent != null) {
      return 'From KES ${minRent.toStringAsFixed(0)}';
    } else if (maxRent != null) {
      return 'Up to KES ${maxRent.toStringAsFixed(0)}';
    }
    return 'Any budget';
  }

  /// Get status message based on status
  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'searching':
        return 'Our team is actively searching for properties matching your criteria. We\'ll notify you when we find suitable options.';
      case 'completed':
      case 'found':
        return 'We\'ve found properties matching your criteria! Check your messages for details.';
      case 'pending':
        return 'Your request is pending review. We\'ll start searching soon.';
      case 'cancelled':
        return 'This hunting request has been cancelled.';
      case 'expired':
        return 'This hunting request has expired. You can create a new request.';
      default:
        return 'Request status: $status';
    }
  }
}
