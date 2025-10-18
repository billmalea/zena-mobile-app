import 'package:flutter/material.dart';
import 'card_styles.dart';

/// NoPropertiesFoundCard widget displays a helpful message when no properties match the search
/// Provides suggestions and action buttons to help users adjust their search
class NoPropertiesFoundCard extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  final Function(String)? onSendMessage;

  const NoPropertiesFoundCard({
    super.key,
    required this.searchCriteria,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 32,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No Properties Found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              'We couldn\'t find any properties matching your search criteria.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Search Criteria Used
            if (searchCriteria.isNotEmpty) ...[
              Text(
                'Your search criteria:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildSearchCriteria(context),
              const SizedBox(height: 16),
            ],

            // Suggestions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: CardStyles.secondaryContainer(context).copyWith(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Suggestions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestion(context, 'Try expanding your budget range'),
                  _buildSuggestion(context, 'Consider nearby neighborhoods'),
                  _buildSuggestion(context, 'Adjust the number of bedrooms'),
                  _buildSuggestion(context, 'Remove some amenity filters'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleAdjustSearch,
                    icon: const Icon(Icons.tune),
                    label: const Text('Adjust Search'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleStartHunting,
                    icon: const Icon(Icons.search),
                    label: const Text('Start Hunting'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build search criteria display
  Widget _buildSearchCriteria(BuildContext context) {
    final theme = Theme.of(context);
    final criteria = <Widget>[];

    // Extract and display relevant search criteria
    if (searchCriteria['location'] != null) {
      criteria.add(_buildCriteriaChip(
        context,
        Icons.location_on,
        'Location: ${searchCriteria['location']}',
      ));
    }

    if (searchCriteria['minRent'] != null || searchCriteria['maxRent'] != null) {
      final minRent = searchCriteria['minRent'];
      final maxRent = searchCriteria['maxRent'];
      String rentText = 'Budget: ';
      if (minRent != null && maxRent != null) {
        rentText += 'KES ${_formatNumber(minRent)} - ${_formatNumber(maxRent)}';
      } else if (minRent != null) {
        rentText += 'From KES ${_formatNumber(minRent)}';
      } else if (maxRent != null) {
        rentText += 'Up to KES ${_formatNumber(maxRent)}';
      }
      criteria.add(_buildCriteriaChip(context, Icons.payments, rentText));
    }

    if (searchCriteria['bedrooms'] != null) {
      criteria.add(_buildCriteriaChip(
        context,
        Icons.bed_outlined,
        '${searchCriteria['bedrooms']} Bedrooms',
      ));
    }

    if (searchCriteria['bathrooms'] != null) {
      criteria.add(_buildCriteriaChip(
        context,
        Icons.bathroom_outlined,
        '${searchCriteria['bathrooms']} Bathrooms',
      ));
    }

    if (searchCriteria['propertyType'] != null) {
      criteria.add(_buildCriteriaChip(
        context,
        Icons.home_outlined,
        searchCriteria['propertyType'],
      ));
    }

    if (searchCriteria['amenities'] != null) {
      final amenities = searchCriteria['amenities'] as List?;
      if (amenities != null && amenities.isNotEmpty) {
        criteria.add(_buildCriteriaChip(
          context,
          Icons.check_circle_outline,
          'Amenities: ${amenities.join(", ")}',
        ));
      }
    }

    // If no criteria found, show a generic message
    if (criteria.isEmpty) {
      return Text(
        'No specific criteria provided',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: criteria,
    );
  }

  /// Build a single criteria chip
  Widget _buildCriteriaChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single suggestion item
  Widget _buildSuggestion(BuildContext context, String suggestion) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.arrow_right,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              suggestion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format number with thousand separators
  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final num = number is int ? number : int.tryParse(number.toString()) ?? 0;
    return num.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Handle adjust search button press
  void _handleAdjustSearch() {
    if (onSendMessage != null) {
      onSendMessage!('I want to adjust my search criteria');
    }
  }

  /// Handle start property hunting button press
  void _handleStartHunting() {
    if (onSendMessage != null) {
      onSendMessage!('I want to start property hunting');
    }
  }
}
