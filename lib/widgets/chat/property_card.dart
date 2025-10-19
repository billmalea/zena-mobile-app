import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../models/property.dart';

/// PropertyCard widget displays property information in a card format
/// Matches web implementation exactly with video support, like button, and styling
class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  final Function(String)? onRequestContact;
  final bool showContactInfo;

  const PropertyCard({
    super.key,
    required this.propertyData,
    this.onRequestContact,
    this.showContactInfo = false,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isLiked = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    final videos = widget.propertyData['videos'] as List?;
    if (videos != null && videos.isNotEmpty) {
      final videoUrl = videos[0] as String;
      try {
        final decodedUrl = Uri.decodeFull(videoUrl);
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(decodedUrl))
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {
                    _isVideoInitialized = true;
                  });
                }
              }).catchError((error) {
                print('Video initialization error: $error');
                if (mounted) {
                  setState(() {
                    _videoError = true;
                  });
                }
              });
        _videoController!.setLooping(true);
      } catch (e) {
        print('Video URL decode error: $e');
        setState(() {
          _videoError = true;
        });
      }
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = Property.fromJson(widget.propertyData);
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Section (Video or Image) - Matches web aspect ratio 4:3
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Media content (video or image)
                    Positioned.fill(
                      child: _buildMediaContent(property),
                    ),

                    // Video play/pause overlay (only show when video is paused)
                    if (_videoController != null &&
                        _isVideoInitialized &&
                        !_videoController!.value.isPlaying)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _toggleVideoPlayback,
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Like Button - Top Right (matches web)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: _isLiked
                            ? Colors.red
                            : Colors.white.withOpacity(0.9),
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: InkWell(
                          onTap: () => setState(() => _isLiked = !_isLiked),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: _isLiked
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Property Type Badge - Top Left (matches web)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getPropertyTypeLabel(property.propertyType),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Property Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          property.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            property.formattedRent,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'per month',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Description (if available)
                  if (property.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      property.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Location
                  const SizedBox(height: 12),
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
                          property.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Bedrooms and Bathrooms
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bed,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${property.bedrooms} bed${property.bedrooms != 1 ? 's' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.bathtub,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${property.bathrooms} bath${property.bathrooms != 1 ? 's' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Amenities
                  if (property.amenities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...property.amenities
                            .take(3)
                            .map((amenity) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 11,
                                    ),
                                  ),
                                )),
                        if (property.amenities.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${property.amenities.length - 3} more',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // Action Buttons
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // View Details Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to property details
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Contact/Request Button
                      if (widget.showContactInfo &&
                          widget.propertyData['contact_phone'] != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Show contact info
                            },
                            icon: const Icon(Icons.phone, size: 16),
                            label: Text(
                              widget.propertyData['contact_phone'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleRequestContact(property),
                            icon: const Icon(Icons.lock, size: 16),
                            label: const Text('Request Viewing'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                              side: BorderSide(color: Colors.orange.shade200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
          ],
        ),
      ),
    );
  }

  /// Build media content (video or image) - matches web implementation
  Widget _buildMediaContent(Property property) {
    final theme = Theme.of(context);
    final videos = widget.propertyData['videos'] as List?;

    // Show video if available and initialized
    if (videos != null && videos.isNotEmpty && !_videoError) {
      if (_videoController != null && _isVideoInitialized) {
        return GestureDetector(
          onTap: _toggleVideoPlayback,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        );
      } else {
        // Video is loading
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading video...',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }
    }

    // Fallback to image
    final images = widget.propertyData['images'] as List?;
    if (images != null && images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: images[0] as String,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade400,
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // No media available
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.home,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Get property type label - matches web implementation
  String _getPropertyTypeLabel(String type) {
    const typeMap = {
      'apartment': 'Apartment',
      'house': 'House',
      'studio': 'Studio',
      'room': 'Room',
      'commercial': 'Commercial',
    };
    return typeMap[type.toLowerCase()] ?? type;
  }

  /// Handle request contact button press
  void _handleRequestContact(Property property) {
    if (widget.onRequestContact != null) {
      // Send message to request contact info for this property
      widget.onRequestContact!(
          'I want to request contact info for ${property.title}');
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
