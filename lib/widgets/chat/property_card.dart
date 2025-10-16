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
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
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
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'per month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build detail chip for property attributes
  Widget _buildDetailChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
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
