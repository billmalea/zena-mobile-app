import 'package:flutter/material.dart';
import 'card_styles.dart';

/// NeighborhoodInfoCard displays information about a neighborhood or location.
///
/// This card is shown when providing details about a specific area,
/// including key features, safety ratings, and average rent prices.
class NeighborhoodInfoCard extends StatelessWidget {
  /// Name of the neighborhood
  final String name;

  /// Description of the neighborhood
  final String description;

  /// List of key features or highlights
  final List<String> keyFeatures;

  /// Safety rating (0-5 scale)
  final double? safetyRating;

  /// Average rent prices by property type
  final Map<String, double>? averageRent;

  const NeighborhoodInfoCard({
    super.key,
    required this.name,
    required this.description,
    required this.keyFeatures,
    this.safetyRating,
    this.averageRent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            // Header with location icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_city,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Neighborhood Info',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Safety rating
            if (safetyRating != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSafetyColor(safetyRating!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSafetyColor(safetyRating!).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: _getSafetyColor(safetyRating!),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Safety Rating: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < safetyRating!.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 18,
                              color: _getSafetyColor(safetyRating!),
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${safetyRating!.toStringAsFixed(1)}/5',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getSafetyColor(safetyRating!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Key features
            if (keyFeatures.isNotEmpty) ...[
              Text(
                'Key Features',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...keyFeatures.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // Average rent prices
            if (averageRent != null && averageRent!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Average Rent Prices',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
                  children: averageRent!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getPropertyTypeIcon(entry.key),
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            'KES ${entry.value.toStringAsFixed(0)}/mo',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Info footer
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Information based on recent data and user reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get safety color based on rating
  Color _getSafetyColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green;
    } else if (rating >= 3.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get icon for property type
  IconData _getPropertyTypeIcon(String propertyType) {
    final type = propertyType.toLowerCase();
    if (type.contains('apartment') || type.contains('flat')) {
      return Icons.apartment;
    } else if (type.contains('house') || type.contains('bungalow')) {
      return Icons.house;
    } else if (type.contains('studio')) {
      return Icons.meeting_room;
    } else if (type.contains('bedsitter')) {
      return Icons.bed;
    } else {
      return Icons.home;
    }
  }
}
