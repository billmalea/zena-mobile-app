import 'package:flutter/material.dart';

/// Card displayed when property search returns no results
/// Offers options to start property hunting or adjust search criteria
class NoPropertiesFoundCard extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  final List<String> suggestions;
  final VoidCallback? onStartPropertyHunting;
  final VoidCallback? onAdjustSearch;

  const NoPropertiesFoundCard({
    super.key,
    required this.searchCriteria,
    required this.suggestions,
    this.onStartPropertyHunting,
    this.onAdjustSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.errorContainer.withOpacity(0.3),
              colorScheme.errorContainer.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 24,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Properties Found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find any properties matching your exact criteria, but we have options to help!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Search criteria summary
              if (searchCriteria.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Search',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildSearchBadges(context),
                      ),
                    ],
                  ),
                ),
              ],

              // What would you like to do section
              const SizedBox(height: 16),
              Text(
                'What would you like to do?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              // Action buttons
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Property Hunting button
                  if (onStartPropertyHunting != null)
                    ElevatedButton(
                      onPressed: onStartPropertyHunting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Property Hunt',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                Text(
                                  'Find unlisted properties',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onPrimary.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Adjust Search button
                  if (onAdjustSearch != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onAdjustSearch,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adjust Search',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                Text(
                                  'Try different criteria',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700
                                        .withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Quick Suggestions
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade200.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Suggestions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...suggestions.take(3).map((suggestion) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $suggestion',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade800,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              // Agent Help Info
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Agent Help Benefits',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Our agents have access to unlisted properties and can find options that match your exact needs within 2-4 hours.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build search criteria badges
  List<Widget> _buildSearchBadges(BuildContext context) {
    final theme = Theme.of(context);
    final badges = <Widget>[];

    searchCriteria.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        IconData? icon;
        if (key.toLowerCase().contains('location')) {
          icon = Icons.location_on;
        } else if (key.toLowerCase().contains('bedroom')) {
          icon = Icons.bed;
        } else if (key.toLowerCase().contains('rent') ||
            key.toLowerCase().contains('price')) {
          icon = Icons.attach_money;
        }

        badges.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  const SizedBox(width: 4),
                ],
                Text(
                  _formatValue(value),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }
    });

    return badges;
  }

  /// Format key for display
  String _formatKey(String key) {
    // Convert camelCase to Title Case
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  /// Format value for display
  String _formatValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    if (value is num) {
      return 'KSh ${value.toStringAsFixed(0)}';
    }
    return value.toString();
  }
}
