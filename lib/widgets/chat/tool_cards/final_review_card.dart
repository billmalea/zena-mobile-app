import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// FinalReviewCard displays complete property summary before listing.
///
/// This card shows all property data in a comprehensive review format,
/// allowing users to confirm and list their property or go back to edit.
class FinalReviewCard extends StatefulWidget {
  /// Complete property data to display
  final Map<String, dynamic> propertyData;

  /// Callback when user confirms and wants to list the property
  final VoidCallback onConfirm;

  /// Callback when user wants to edit the property data
  final VoidCallback onEdit;

  const FinalReviewCard({
    super.key,
    required this.propertyData,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  State<FinalReviewCard> createState() => _FinalReviewCardState();
}

class _FinalReviewCardState extends State<FinalReviewCard> {
  bool _termsAccepted = false;

  /// Format currency values
  String _formatCurrency(dynamic value) {
    if (value == null) return 'Not specified';
    final formatter = NumberFormat('#,###', 'en_US');
    final amount = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return 'KSh ${formatter.format(amount)}';
  }

  /// Get value from property data with fallback
  dynamic _getValue(String key, {dynamic defaultValue = 'Not specified'}) {
    return widget.propertyData[key] ?? defaultValue;
  }

  /// Check if a field has a valid value
  bool _hasValue(String key) {
    final value = widget.propertyData[key];
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    return true;
  }

  /// Build a summary field row
  Widget _buildSummaryField({
    required String label,
    required String value,
    required ThemeData theme,
    IconData? icon,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a section header
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Build list display (amenities, features, etc.)
  Widget _buildListDisplay({
    required String label,
    required List<dynamic> items,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  item.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract data with defaults
    final title = _getValue('title');
    final description = _getValue('description');
    final propertyType = _getValue('propertyType', defaultValue: _getValue('property_type'));
    final bedrooms = _getValue('bedrooms', defaultValue: 0);
    final bathrooms = _getValue('bathrooms', defaultValue: 0);
    final rentAmount = _getValue('rentAmount', defaultValue: _getValue('rent_amount'));
    final commissionAmount = _getValue('commissionAmount', defaultValue: _getValue('commission_amount'));
    final location = _getValue('location');
    final address = _getValue('address', defaultValue: location);
    final neighborhood = _getValue('neighborhood');
    final amenities = _getValue('amenities', defaultValue: []);
    final features = _getValue('features', defaultValue: []);
    final squareFootage = _getValue('squareFootage', defaultValue: _getValue('square_footage'));
    final furnished = _getValue('furnished', defaultValue: false);
    final petsAllowed = _getValue('petsAllowed', defaultValue: _getValue('pets_allowed', defaultValue: false));
    final parkingSpaces = _getValue('parkingSpaces', defaultValue: _getValue('parking_spaces', defaultValue: 0));

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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 24,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Final Review',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review before listing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Generated Title Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.3),
                      colorScheme.primaryContainer.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.title,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Property Title',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Generated Description Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Description',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Basic Information Section
              _buildSectionHeader(
                title: 'Basic Information',
                icon: Icons.home_outlined,
                theme: theme,
              ),
              _buildSummaryField(
                label: 'Property Type',
                value: propertyType.toString(),
                theme: theme,
                icon: Icons.apartment,
              ),
              _buildSummaryField(
                label: 'Bedrooms',
                value: bedrooms.toString(),
                theme: theme,
                icon: Icons.bed_outlined,
              ),
              _buildSummaryField(
                label: 'Bathrooms',
                value: bathrooms.toString(),
                theme: theme,
                icon: Icons.bathroom_outlined,
              ),
              if (_hasValue('squareFootage') || _hasValue('square_footage'))
                _buildSummaryField(
                  label: 'Square Footage',
                  value: '$squareFootage sq ft',
                  theme: theme,
                  icon: Icons.square_foot,
                ),
              _buildSummaryField(
                label: 'Furnished',
                value: furnished.toString() == 'true' ? 'Yes' : 'No',
                theme: theme,
                icon: Icons.chair_outlined,
              ),
              _buildSummaryField(
                label: 'Pets Allowed',
                value: petsAllowed.toString() == 'true' ? 'Yes' : 'No',
                theme: theme,
                icon: Icons.pets_outlined,
              ),
              if (parkingSpaces > 0)
                _buildSummaryField(
                  label: 'Parking Spaces',
                  value: parkingSpaces.toString(),
                  theme: theme,
                  icon: Icons.local_parking_outlined,
                ),

              // Financial Information Section
              _buildSectionHeader(
                title: 'Financial Information',
                icon: Icons.payments_outlined,
                theme: theme,
              ),
              _buildSummaryField(
                label: 'Monthly Rent',
                value: _formatCurrency(rentAmount),
                theme: theme,
                icon: Icons.attach_money,
              ),
              if (_hasValue('commissionAmount') || _hasValue('commission_amount'))
                _buildSummaryField(
                  label: 'Commission',
                  value: _formatCurrency(commissionAmount),
                  theme: theme,
                  icon: Icons.account_balance_wallet_outlined,
                ),

              // Location Information Section
              _buildSectionHeader(
                title: 'Location',
                icon: Icons.location_on_outlined,
                theme: theme,
              ),
              _buildSummaryField(
                label: 'Location',
                value: location.toString(),
                theme: theme,
                icon: Icons.place_outlined,
              ),
              if (_hasValue('address') && address.toString() != location.toString())
                _buildSummaryField(
                  label: 'Address',
                  value: address.toString(),
                  theme: theme,
                  icon: Icons.home_outlined,
                ),
              if (_hasValue('neighborhood'))
                _buildSummaryField(
                  label: 'Neighborhood',
                  value: neighborhood.toString(),
                  theme: theme,
                  icon: Icons.location_city_outlined,
                ),

              // Amenities Section
              if (amenities is List && amenities.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Amenities',
                  icon: Icons.star_outline,
                  theme: theme,
                ),
                _buildListDisplay(
                  label: 'Included amenities',
                  items: amenities,
                  theme: theme,
                ),
              ],

              // Features Section
              if (features is List && features.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Features',
                  icon: Icons.list_alt_outlined,
                  theme: theme,
                ),
                _buildListDisplay(
                  label: 'Property features',
                  items: features,
                  theme: theme,
                ),
              ],

              const SizedBox(height: 20),

              // Terms and Conditions Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _termsAccepted
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'I confirm that all information provided is accurate and I agree to the terms and conditions for listing my property.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _termsAccepted ? widget.onConfirm : null,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Confirm and List'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _termsAccepted ? Colors.green : null,
                        foregroundColor: _termsAccepted ? Colors.white : null,
                        elevation: 0,
                        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Helper text
              if (!_termsAccepted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Please accept the terms and conditions to proceed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
