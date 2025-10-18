import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// PropertyDataCard displays extracted property data for review.
///
/// This card organizes property data into sections (Basic, Financial, Location, Details)
/// and allows users to edit individual fields and confirm the data.
class PropertyDataCard extends StatelessWidget {
  /// Extracted property data to display
  final Map<String, dynamic> propertyData;

  /// Callback when user wants to edit a specific field
  final Function(String fieldName, dynamic currentValue)? onEdit;

  /// Callback when user confirms the data
  final VoidCallback? onConfirm;

  const PropertyDataCard({
    super.key,
    required this.propertyData,
    this.onEdit,
    this.onConfirm,
  });

  /// Format currency values
  String _formatCurrency(dynamic value) {
    if (value == null) return 'Not specified';
    final formatter = NumberFormat('#,###', 'en_US');
    final amount = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return 'KSh ${formatter.format(amount)}';
  }

  /// Get value from property data with fallback
  dynamic _getValue(String key, {dynamic defaultValue = 'Not specified'}) {
    return propertyData[key] ?? defaultValue;
  }

  /// Check if a field has a valid value
  bool _hasValue(String key) {
    final value = propertyData[key];
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    return true;
  }

  /// Build a data field row with edit button
  Widget _buildDataField({
    required BuildContext context,
    required String label,
    required String fieldKey,
    required String displayValue,
    required ThemeData theme,
    bool isValid = true,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? colorScheme.outline.withOpacity(0.2)
              : colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Validation indicator
          Container(
            margin: const EdgeInsets.only(top: 2, right: 10),
            child: Icon(
              isValid ? Icons.check_circle : Icons.error_outline,
              size: 18,
              color: isValid ? Colors.green : colorScheme.error,
            ),
          ),
          // Field content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          if (onEdit != null)
            IconButton(
              onPressed: () {
                onEdit?.call(fieldKey, propertyData[fieldKey]);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit $label',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.primary,
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
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
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

  /// Build list field (amenities, features, etc.)
  Widget _buildListField({
    required BuildContext context,
    required String label,
    required String fieldKey,
    required List<dynamic> items,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isValid = items.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? colorScheme.outline.withOpacity(0.2)
              : colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error_outline,
                size: 18,
                color: isValid ? Colors.green : colorScheme.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: () {
                    onEdit?.call(fieldKey, items);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit $label',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'No items specified',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return Chip(
                  label: Text(
                    item.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                  side: BorderSide.none,
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

    // Validation
    final hasTitle = _hasValue('title');
    final hasDescription = _hasValue('description');
    final hasPropertyType = _hasValue('propertyType') || _hasValue('property_type');
    final hasRent = _hasValue('rentAmount') || _hasValue('rent_amount');
    final hasLocation = _hasValue('location') || _hasValue('address');

    final allValid = hasTitle && hasDescription && hasPropertyType && hasRent && hasLocation;

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
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fact_check_outlined,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Property Data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verify extracted information',
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

            // Validation summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: allValid
                    ? Colors.green.withOpacity(0.1)
                    : colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: allValid
                      ? Colors.green.withOpacity(0.3)
                      : colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    allValid ? Icons.check_circle : Icons.warning_amber_rounded,
                    size: 20,
                    color: allValid ? Colors.green : colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      allValid
                          ? 'All required fields are complete'
                          : 'Some required fields need attention',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Basic Information Section
            _buildSectionHeader(
              title: 'Basic Information',
              icon: Icons.home_outlined,
              theme: theme,
            ),
            _buildDataField(
              context: context,
              label: 'PROPERTY TITLE',
              fieldKey: 'title',
              displayValue: title.toString(),
              theme: theme,
              isValid: hasTitle,
            ),
            _buildDataField(
              context: context,
              label: 'DESCRIPTION',
              fieldKey: 'description',
              displayValue: description.toString(),
              theme: theme,
              isValid: hasDescription,
            ),
            _buildDataField(
              context: context,
              label: 'PROPERTY TYPE',
              fieldKey: 'propertyType',
              displayValue: propertyType.toString(),
              theme: theme,
              isValid: hasPropertyType,
            ),
            _buildDataField(
              context: context,
              label: 'BEDROOMS',
              fieldKey: 'bedrooms',
              displayValue: bedrooms.toString(),
              theme: theme,
            ),
            _buildDataField(
              context: context,
              label: 'BATHROOMS',
              fieldKey: 'bathrooms',
              displayValue: bathrooms.toString(),
              theme: theme,
            ),

            const SizedBox(height: 12),

            // Financial Information Section
            _buildSectionHeader(
              title: 'Financial Information',
              icon: Icons.payments_outlined,
              theme: theme,
            ),
            _buildDataField(
              context: context,
              label: 'MONTHLY RENT',
              fieldKey: 'rentAmount',
              displayValue: _formatCurrency(rentAmount),
              theme: theme,
              isValid: hasRent,
            ),
            _buildDataField(
              context: context,
              label: 'COMMISSION',
              fieldKey: 'commissionAmount',
              displayValue: _formatCurrency(commissionAmount),
              theme: theme,
            ),

            const SizedBox(height: 12),

            // Location Information Section
            _buildSectionHeader(
              title: 'Location Information',
              icon: Icons.location_on_outlined,
              theme: theme,
            ),
            _buildDataField(
              context: context,
              label: 'LOCATION',
              fieldKey: 'location',
              displayValue: location.toString(),
              theme: theme,
              isValid: hasLocation,
            ),
            if (_hasValue('address'))
              _buildDataField(
                context: context,
                label: 'ADDRESS',
                fieldKey: 'address',
                displayValue: address.toString(),
                theme: theme,
              ),
            if (_hasValue('neighborhood'))
              _buildDataField(
                context: context,
                label: 'NEIGHBORHOOD',
                fieldKey: 'neighborhood',
                displayValue: neighborhood.toString(),
                theme: theme,
              ),

            const SizedBox(height: 12),

            // Details Section
            _buildSectionHeader(
              title: 'Property Details',
              icon: Icons.list_alt_outlined,
              theme: theme,
            ),
            if (amenities is List)
              _buildListField(
                context: context,
                label: 'AMENITIES',
                fieldKey: 'amenities',
                items: amenities,
                theme: theme,
              ),
            if (features is List)
              _buildListField(
                context: context,
                label: 'FEATURES',
                fieldKey: 'features',
                items: features,
                theme: theme,
              ),

            const SizedBox(height: 20),

            // Action buttons
            if (onConfirm != null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Edit action - could open a dialog or navigate
                        onEdit?.call('all', propertyData);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit All'),
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
                      onPressed: allValid ? onConfirm : null,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Confirm Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: allValid ? Colors.green : null,
                        foregroundColor: allValid ? Colors.white : null,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
