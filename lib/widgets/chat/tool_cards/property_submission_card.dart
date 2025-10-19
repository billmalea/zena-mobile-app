import 'package:flutter/material.dart';

/// PropertySubmissionCard displays property submission status
/// Matches web implementation with simple stage-based UI
class PropertySubmissionCard extends StatelessWidget {
  final bool success;
  final String message;
  final String? propertyId;
  final double? estimatedCommission;
  final String? error;
  final bool requiresAuth;
  final String? stage;
  final Map<String, dynamic>? instructions;
  final Map<String, dynamic>? rejection;

  const PropertySubmissionCard({
    super.key,
    required this.success,
    required this.message,
    this.propertyId,
    this.estimatedCommission,
    this.error,
    this.requiresAuth = false,
    this.stage,
    this.instructions,
    this.rejection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auth required
    if (requiresAuth) {
      return _buildAuthRequired(context, theme, colorScheme);
    }

    // Determine stage type
    final isVideoStage = stage == 'video_upload' || stage == 'video_analysis';
    final isRejection = stage == 'video_rejected' || (!success && !isVideoStage);
    final isCompleted = success && !isVideoStage && !isRejection;

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
            colors: _getGradientColors(isRejection, isVideoStage),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getIconBgColor(isRejection, isVideoStage),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(isRejection, isVideoStage),
                      size: 24,
                      color: _getIconColor(isRejection, isVideoStage),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Property Submission',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildStatusBadge(
                              context,
                              isRejection,
                              isVideoStage,
                              isCompleted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),

              // Instructions
              if (instructions != null) ...[
                const SizedBox(height: 16),
                _buildInstructions(context, theme, colorScheme),
              ],

              // Upload button for video_upload stage
              if (stage == 'video_upload') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Trigger file upload via message input
                      // User should use the attachment button in message input
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Tap the attachment button below to upload your video'),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam, size: 20),
                    label: const Text('Upload Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              // Rejection details
              if (rejection != null) ...[
                const SizedBox(height: 16),
                _buildRejection(context, theme, colorScheme),
              ],

              // Completed with commission
              if (isCompleted && estimatedCommission != null) ...[
                const SizedBox(height: 16),
                _buildCommissionInfo(context, theme, colorScheme),
              ],

              // Property ID
              if (isCompleted && propertyId != null) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline.withOpacity(0.2)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Property ID: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        propertyId!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Error message
              if (isRejection && error != null) ...[
                const SizedBox(height: 16),
                Text(
                  error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthRequired(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
              Colors.yellow.shade50.withOpacity(0.5),
              Colors.orange.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.apartment,
                  size: 24,
                  color: Colors.yellow.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Required',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error ?? 'Please sign in to continue',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to auth
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Sign Up / Log In'),
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

  Widget _buildStatusBadge(
    BuildContext context,
    bool isRejection,
    bool isVideoStage,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;
    String label;
    IconData? icon;

    if (isRejection) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      label = 'Action Needed';
      icon = null;
    } else if (isVideoStage) {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
      label = 'Awaiting Video';
      icon = Icons.schedule;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      label = 'Under Review';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final List<Widget> children = [];

    if (instructions!['title'] != null) {
      children.add(Text(
        instructions!['title'],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ));
      children.add(const SizedBox(height: 8));
    }

    if (instructions!['description'] != null) {
      children.add(Text(
        instructions!['description'],
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ));
      children.add(const SizedBox(height: 12));
    }

    if (instructions!['checklist'] != null) {
      children.add(Text(
        'Checklist',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ));
      children.add(const SizedBox(height: 8));
      for (var item in (instructions!['checklist'] as List)) {
        children.add(Padding(
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
                  item.toString(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ));
      }
    }

    if (instructions!['actions'] != null) {
      children.add(const SizedBox(height: 12));
      children.add(Text(
        'You can say',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ));
      children.add(const SizedBox(height: 8));
      for (var item in (instructions!['actions'] as List)) {
        children.add(Padding(
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
                  item.toString(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ));
      }
    }

    if (instructions!['reminders'] != null) {
      children.add(const SizedBox(height: 12));
      children.add(Text(
        'Reminders',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ));
      children.add(const SizedBox(height: 8));
      for (var item in (instructions!['reminders'] as List)) {
        children.add(Padding(
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
                  item.toString(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRejection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade200.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why the video was rejected',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rejection!['reason'] ?? 'Video did not meet requirements',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          if (rejection!['details']?['issues'] != null) ...[
            const SizedBox(height: 12),
            ...(rejection!['details']['issues'] as List).map((issue) {
              final message = issue is Map ? issue['message'] : issue.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.red)),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (rejection!['details']?['detectedItems'] != null) ...[
            const SizedBox(height: 12),
            ...(rejection!['details']['detectedItems'] as List).map((item) {
              final value = item is Map
                  ? (item['type'] != null
                      ? '${item['type']}: ${item['value']}'
                      : item['value'])
                  : item.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.red)),
                    Expanded(
                      child: Text(
                        value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCommissionInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                size: 16,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                'Estimated Commission',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'KSh ${estimatedCommission!.toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ll earn this when someone successfully rents your property through Zena',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(bool isRejection, bool isVideoStage) {
    if (isRejection) {
      return [
        Colors.red.shade50.withOpacity(0.6),
        Colors.pink.shade50.withOpacity(0.6),
      ];
    } else if (isVideoStage) {
      return [
        Colors.blue.shade50.withOpacity(0.6),
        Colors.cyan.shade50.withOpacity(0.6),
      ];
    } else {
      return [
        Colors.green.shade50.withOpacity(0.6),
        const Color(0xFF10B981).withOpacity(0.1),
      ];
    }
  }

  Color _getIconBgColor(bool isRejection, bool isVideoStage) {
    if (isRejection) return Colors.red.shade100;
    if (isVideoStage) return Colors.blue.shade100;
    return Colors.green.shade100;
  }

  Color _getIconColor(bool isRejection, bool isVideoStage) {
    if (isRejection) return Colors.red.shade600;
    if (isVideoStage) return Colors.blue.shade600;
    return Colors.green.shade600;
  }

  IconData _getIcon(bool isRejection, bool isVideoStage) {
    if (isRejection) return Icons.error;
    if (isVideoStage) return Icons.apartment;
    return Icons.check_circle;
  }
}
