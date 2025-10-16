import 'package:intl/intl.dart';

/// Property model for rental properties
/// Represents property data with formatting methods for display
class Property {
  final String id;
  final String title;
  final String description;
  final String location;
  final int rentAmount;
  final int commissionAmount;
  final int bedrooms;
  final int bathrooms;
  final String propertyType;
  final List<String> amenities;
  final List<String> images;
  final List<String> videos;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.rentAmount,
    required this.commissionAmount,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyType,
    required this.amenities,
    required this.images,
    required this.videos,
  });

  /// Format rent amount as Kenyan currency (KSh 80,000)
  String get formattedRent {
    final formatter = NumberFormat('#,###', 'en_US');
    return 'KSh ${formatter.format(rentAmount)}';
  }

  /// Format commission amount as Kenyan currency (KSh 5,000)
  String get formattedCommission {
    final formatter = NumberFormat('#,###', 'en_US');
    return 'KSh ${formatter.format(commissionAmount)}';
  }

  /// Get primary image URL or empty string
  String get primaryImage => images.isNotEmpty ? images.first : '';

  /// Check if property has images
  bool get hasImages => images.isNotEmpty;

  /// Check if property has videos
  bool get hasVideos => videos.isNotEmpty;

  /// Create Property from JSON
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String,
      rentAmount: json['rentAmount'] as int? ?? json['rent_amount'] as int? ?? 0,
      commissionAmount: json['commissionAmount'] as int? ?? json['commission_amount'] as int? ?? 0,
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      propertyType: json['propertyType'] as String? ?? json['property_type'] as String? ?? '',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : [],
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      videos: json['videos'] != null
          ? List<String>.from(json['videos'] as List)
          : [],
    );
  }

  /// Convert Property to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'rentAmount': rentAmount,
      'commissionAmount': commissionAmount,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'propertyType': propertyType,
      'amenities': amenities,
      'images': images,
      'videos': videos,
    };
  }
}
