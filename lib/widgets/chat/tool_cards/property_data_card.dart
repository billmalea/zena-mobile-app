import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' show VideoPlayerController, VideoPlayer, VideoProgressIndicator, VideoProgressColors;

/// PropertyDataCard displays extracted property data from video analysis
/// Matches web implementation with visual grid layout and review functionality
class PropertyDataCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? message;
  final String? videoUrl;
  final Map<String, dynamic>? instructions;

  const PropertyDataCard({
    super.key,
    required this.data,
    this.message,
    this.videoUrl,
    this.instructions,
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
              const Color(0xFF10B981).withOpacity(0.1), // emerald-500
              Colors.teal.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              if (message != null || instructions != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.apartment,
                      size: 20,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message ?? 'Review the extracted details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (instructions?['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    instructions!['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                if (instructions?['actions'] != null) ...[
                  const SizedBox(height: 8),
                  ...(instructions!['actions'] as List).map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                action.toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
              ],

              // Video Preview
              if (videoUrl?.isNotEmpty == true) ...[
                Text(
                  'Property Video:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                VideoPlayerWidget(videoUrl: videoUrl!),
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
              ],

              // Property Details Grid
              _buildDetailsGrid(context),

              // Enhanced Details
              if (_hasEnhancedDetails()) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
                _buildEnhancedDetails(context),
              ],

              // Security Features
              if (data['securityFeatures'] != null &&
                  (data['securityFeatures'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
                _buildSecurityFeatures(context),
              ],

              // Nearby Amenities
              if (data['nearbyAmenities'] != null &&
                  (data['nearbyAmenities'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
                _buildNearbyAmenities(context),
              ],

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
              Text(
                'Please review the details above. If everything looks good, just say "looks good" or "correct". Need to make changes? Simply tell me what to update, like "it\'s actually 2 bedrooms" or "change location to Westlands"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
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
        if (data['furnishingStatus'] != null)
          _buildDetailItem(
            context,
            Icons.chair,
            'Furnishing',
            _formatFurnishing(data['furnishingStatus']),
          ),
        if (data['availabilityDate'] != null)
          _buildDetailItem(
            context,
            Icons.calendar_today,
            'Available',
            data['availabilityDate'].toString(),
          ),
        if (data['floorLevel'] != null)
          _buildDetailItem(
            context,
            Icons.layers,
            'Floor',
            data['floorLevel'].toString(),
          ),
        if (data['parkingSpaces'] != null)
          _buildDetailItem(
            context,
            Icons.local_parking,
            'Parking',
            '${data['parkingSpaces']} space${data['parkingSpaces'] != 1 ? 's' : ''}',
          ),
        if (data['depositAmount'] != null)
          _buildDetailItem(
            context,
            Icons.account_balance_wallet,
            'Deposit',
            'KSh ${(data['depositAmount'] as num).toStringAsFixed(0)}',
          ),
        if (data['additionalCosts'] != null)
          _buildDetailItem(
            context,
            Icons.receipt,
            'Additional Costs',
            data['additionalCosts'].toString(),
            fullWidth: true,
          ),
        if (data['condition'] != null)
          _buildDetailItem(
            context,
            Icons.star,
            'Condition',
            _formatCondition(data['condition']),
          ),
        if (data['estimatedSize'] != null)
          _buildDetailItem(
            context,
            Icons.square_foot,
            'Size',
            data['estimatedSize'].toString(),
          ),
        if (data['marketPosition'] != null)
          _buildDetailItem(
            context,
            Icons.trending_up,
            'Market',
            data['marketPosition'].toString().toUpperCase(),
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
            color: const Color(0xFF10B981),
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

  bool _hasEnhancedDetails() {
    return data['viewType'] != null ||
        data['buildingType'] != null ||
        data['waterSupply'] != null ||
        data['transportAccess'] != null ||
        data['electricityBackup'] == true ||
        data['internetAvailable'] == true ||
        data['petsAllowed'] == true ||
        data['hasBalcony'] == true ||
        data['hasGarden'] == true;
  }

  Widget _buildEnhancedDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (data['viewType'] != null)
              _buildEnhancedItem(context, 'View', data['viewType']),
            if (data['buildingType'] != null)
              _buildEnhancedItem(context, 'Building', data['buildingType']),
            if (data['waterSupply'] != null)
              _buildEnhancedItem(context, 'Water', data['waterSupply']),
            if (data['transportAccess'] != null)
              _buildEnhancedItem(context, 'Transport', data['transportAccess']),
            if (data['electricityBackup'] == true)
              _buildEnhancedItem(context, 'Backup Power', 'Yes ✅'),
            if (data['internetAvailable'] == true)
              _buildEnhancedItem(context, 'Internet', 'Available ✅'),
            if (data['petsAllowed'] == true)
              _buildEnhancedItem(context, 'Pets', 'Allowed ✅'),
            if (data['hasBalcony'] == true)
              _buildEnhancedItem(context, 'Balcony', 'Yes ✅'),
            if (data['hasGarden'] == true)
              _buildEnhancedItem(context, 'Garden', 'Yes ✅'),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedItem(BuildContext context, String label, dynamic value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall,
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          TextSpan(
            text: value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeatures(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final features = data['securityFeatures'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Features',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔒 ', style: TextStyle(fontSize: 12)),
                  Text(
                    feature.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNearbyAmenities(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final amenities = data['nearbyAmenities'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby',
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
                border: Border.all(
                  color: Colors.blue.shade600.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍 ', style: TextStyle(fontSize: 12)),
                  Text(
                    amenity.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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

  String _formatFurnishing(dynamic status) {
    final statusMap = {
      'furnished': 'Fully Furnished',
      'semi-furnished': 'Semi-Furnished',
      'unfurnished': 'Unfurnished',
    };
    return statusMap[status.toString()] ?? status.toString();
  }

  String _formatCondition(dynamic condition) {
    final conditionMap = {
      'excellent': 'Excellent ⭐⭐⭐⭐⭐',
      'good': 'Good ⭐⭐⭐⭐',
      'fair': 'Fair ⭐⭐⭐',
      'poor': 'Needs Improvement ⭐⭐',
    };
    return conditionMap[condition.toString()] ?? condition.toString();
  }
}


/// Video Player Widget for displaying property videos
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.white70,
              ),
              SizedBox(height: 8),
              Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video player
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            // Play/Pause button
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            // Progress indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF10B981),
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
