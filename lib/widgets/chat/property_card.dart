import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../config/theme.dart';

/// Property card widget for displaying property information in chat
/// Shows property image, details, and contact button
class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;

  const PropertyCard({
    super.key,
    required this.propertyData,
  });

  @override
  Widget build(BuildContext context) {
    final property = Property.fromJson(propertyData);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            _buildPropertyImage(property),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Property Details Row
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.bed,
                        '${property.bedrooms} Bed',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.bathroom,
                        '${property.bathrooms} Bath',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.home,
                        property.propertyType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rent Amount
                  Text(
                    property.formattedRent,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Text(
                    'per month',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement contact functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact feature coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact Agent'),
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

  /// Build property image with loading and error states
  Widget _buildPropertyImage(Property property) {
    if (!property.hasImages) {
      return _buildImagePlaceholder(Icons.home, 'No image available');
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: property.primaryImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(
          Icons.image,
          'Loading...',
          showProgress: true,
        ),
        errorWidget: (context, url, error) => _buildImagePlaceholder(
          Icons.broken_image,
          'Failed to load image',
        ),
      ),
    );
  }

  /// Build image placeholder for loading and error states
  Widget _buildImagePlaceholder(
    IconData icon,
    String message, {
    bool showProgress = false,
  }) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppTheme.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build detail chip (bedrooms, bathrooms, type)
  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
