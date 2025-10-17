import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';

/// PropertyCard widget displays property information in a card format
/// Used to show property search results in chat messages
class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;

  const PropertyCard({
    super.key,
    required this.propertyData,
  });

  @override
  Widget build(BuildContext context) {
    // Parse property data
    final property = Property.fromJson(propertyData);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Property Details Row (Bedrooms, Bathrooms, Type)
                Row(
                  children: [
                    _buildDetailChip(
                      context,
                      Icons.bed,
                      '${property.bedrooms} Bed',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      context,
                      Icons.bathroom,
                      '${property.bathrooms} Bath',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      context,
                      Icons.home,
                      property.propertyType,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rent Amount
                Text(
                  property.formattedRent,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'per month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 16),

                // Contact Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleContactPress(context, property),
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact Agent'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build property image with loading and error states
  Widget _buildPropertyImage(Property property) {
    if (!property.hasImages) {
      return _buildImagePlaceholder(Icons.home, 'No image available');
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          height: 200,
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.disabledColor),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Build detail chip for property attributes
  Widget _buildDetailChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  /// Handle contact button press
  void _handleContactPress(BuildContext context, Property property) {
    // Show a dialog or snackbar for contact action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact agent for ${property.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // In a real implementation, this would:
    // - Open a contact form
    // - Initiate a phone call
    // - Send a message to the agent
    // - Navigate to property details screen
  }
}
