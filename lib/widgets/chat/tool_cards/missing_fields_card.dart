import 'package:flutter/material.dart';

/// MissingFieldsCard displays what fields are still needed
/// Matches web implementation - shows confirmed data and missing fields list
class MissingFieldsCard extends StatelessWidget {
  /// Current data that has been collected
  final Map<String, dynamic> currentData;

  /// List of missing fields with their details
  final List<Map<String, dynamic>> missingFields;

  /// Message to display
  final String? message;

  /// Instructions object
  final Map<String, dynamic>? instructions;

  const MissingFieldsCard({
    super.key,
    required this.currentData,
    required this.missingFields,
    this.message,
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
              Colors.blue.shade50.withOpacity(0.5),
              Colors.indigo.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message ?? '✅ Confirmed! Here\'s what I have:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 16),

              // Missing fields section
              if (missingFields.isNotEmpty) ...[
                Text(
                  instructions?['title'] ?? 'Please provide:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (instructions?['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    instructions!['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ...missingFields.map((field) {
                  final required = field['required'] as bool? ?? true;
                  final label = field['label'] as String? ??
                      field['field'] as String? ??
                      '';
                  final hint = field['hint'] as String? ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: required
                                ? Colors.red.shade600
                                : colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            required ? 'Required' : 'Optional',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: required
                                  ? Colors.white
                                  : colorScheme.onSecondaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (hint.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  hint,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Action prompt
              const SizedBox(height: 16),
              Divider(color: colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(
                'Please provide the missing information to continue.',
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
}
