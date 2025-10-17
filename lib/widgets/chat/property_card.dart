import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';

/// PropertyCard widget displays property information in a card format
/// Used to show property search results in chat messages
class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  final Function(String)? onRequestContact;

  const PropertyCard({
    super.key,
    required this.propertyData,
    this.onRequestContact,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse property data
    final property = Property.fromJson(widget.propertyData);

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
          // Property Image Carousel with Availability Badge
          Stack(
            children: [
              _buildImageCarousel(property),
              // Availability Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: _buildAvailabilityBadge(context, property),
              ),
            ],
          ),

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
                const SizedBox(height: 12),

                // Property Details Row (Bedrooms, Bathrooms, Type)
                Row(
                  children: [
                    _buildDetailIcon(
                      context,
                      Icons.bed_outlined,
                      '${property.bedrooms}',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailIcon(
                      context,
                      Icons.bathroom_outlined,
                      '${property.bathrooms}',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailIcon(
                      context,
                      Icons.home_outlined,
                      property.propertyType,
                    ),
                  ],
                ),

                // Amenities
                if (property.amenities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildAmenities(context, property.amenities),
                ],

                const SizedBox(height: 16),

                // Request Contact Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleRequestContact(property),
                    icon: const Icon(Icons.phone),
                    label: const Text('Request Contact Info'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  /// Build image carousel with PageView
  Widget _buildImageCarousel(Property property) {
    if (!property.hasImages) {
      return _buildImagePlaceholder(Icons.home, 'No image available');
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: property.images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: property.images[index],
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
              );
            },
          ),
          // Carousel Indicators (dots)
          if (property.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: _buildCarouselIndicators(property.images.length),
            ),
        ],
      ),
    );
  }

  /// Build carousel indicators (dots)
  Widget _buildCarouselIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentImageIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build availability status badge
  Widget _buildAvailabilityBadge(BuildContext context, Property property) {
    // Determine availability status from property data
    final isAvailable = widget.propertyData['available'] ?? true;
    final status = widget.propertyData['status'] as String?;
    
    String badgeText = 'Available';
    Color badgeColor = Colors.green;
    
    if (!isAvailable || status == 'rented' || status == 'unavailable') {
      badgeText = 'Unavailable';
      badgeColor = Colors.red;
    } else if (status == 'pending') {
      badgeText = 'Pending';
      badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

  /// Build detail icon with label for property attributes
  Widget _buildDetailIcon(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  /// Build amenities chips
  Widget _buildAmenities(BuildContext context, List<String> amenities) {
    final theme = Theme.of(context);
    
    // Map amenity names to icons
    final amenityIcons = {
      'wifi': Icons.wifi,
      'parking': Icons.local_parking,
      'security': Icons.security,
      'gym': Icons.fitness_center,
      'pool': Icons.pool,
      'garden': Icons.yard,
      'balcony': Icons.balcony,
      'elevator': Icons.elevator,
      'furnished': Icons.chair,
      'pet-friendly': Icons.pets,
      'laundry': Icons.local_laundry_service,
      'ac': Icons.ac_unit,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.take(6).map((amenity) {
        final amenityLower = amenity.toLowerCase().replaceAll(' ', '-');
        final icon = amenityIcons[amenityLower] ?? Icons.check_circle_outline;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                amenity,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Handle request contact button press
  void _handleRequestContact(Property property) {
    if (widget.onRequestContact != null) {
      // Send message to request contact info for this property
      widget.onRequestContact!('I want to request contact info for ${property.title}');
    } else {
      // Fallback: show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request contact info for ${property.title}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
