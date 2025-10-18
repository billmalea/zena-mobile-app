import 'package:flutter/material.dart';
import 'card_styles.dart';

/// PropertySubmissionCard displays the property submission workflow progress.
///
/// This card guides users through the 5-stage property submission process:
/// 1. start - Upload video instructions
/// 2. video_uploaded - Analyzing video
/// 3. confirm_data - Review extracted data
/// 4. provide_info - Fill missing fields
/// 5. final_confirm - Review before listing
class PropertySubmissionCard extends StatelessWidget {
  /// Unique submission ID for tracking
  final String submissionId;

  /// Current stage in the workflow
  final String stage;

  /// Message or instructions for the current stage
  final String message;

  /// Additional data for the current stage
  final Map<String, dynamic>? data;

  /// Callback to send messages back to chat
  final Function(String)? onSendMessage;

  const PropertySubmissionCard({
    super.key,
    required this.submissionId,
    required this.stage,
    required this.message,
    this.data,
    this.onSendMessage,
  });

  /// Get stage number (1-5) from stage name
  int _getStageNumber() {
    switch (stage.toLowerCase()) {
      case 'start':
        return 1;
      case 'video_uploaded':
        return 2;
      case 'confirm_data':
        return 3;
      case 'provide_info':
        return 4;
      case 'final_confirm':
        return 5;
      default:
        return 1;
    }
  }

  /// Get stage title from stage name
  String _getStageTitle() {
    switch (stage.toLowerCase()) {
      case 'start':
        return 'Upload Property Video';
      case 'video_uploaded':
        return 'Analyzing Video';
      case 'confirm_data':
        return 'Review Property Data';
      case 'provide_info':
        return 'Complete Missing Information';
      case 'final_confirm':
        return 'Final Review';
      default:
        return 'Property Submission';
    }
  }

  /// Get stage icon from stage name
  IconData _getStageIcon() {
    switch (stage.toLowerCase()) {
      case 'start':
        return Icons.videocam_outlined;
      case 'video_uploaded':
        return Icons.analytics_outlined;
      case 'confirm_data':
        return Icons.fact_check_outlined;
      case 'provide_info':
        return Icons.edit_note_outlined;
      case 'final_confirm':
        return Icons.check_circle_outline;
      default:
        return Icons.home_work_outlined;
    }
  }

  /// Check if back button should be shown
  bool _shouldShowBackButton() {
    final stageNum = _getStageNumber();
    return stageNum > 1 && stageNum < 5;
  }

  /// Get stage-specific action buttons
  List<Widget> _getStageActions(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (stage.toLowerCase()) {
      case 'start':
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                onSendMessage?.call('I want to upload a property video');
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ];

      case 'video_uploaded':
        return [
          Container(
            padding: CardStyles.cardPadding,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Analyzing your video...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];

      case 'confirm_data':
        return [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    onSendMessage?.call('I need to edit the property data');
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Data'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    onSendMessage?.call('The data looks correct, proceed');
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];

      case 'provide_info':
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                onSendMessage?.call('I have provided the missing information');
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Information'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ];

      case 'final_confirm':
        return [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    onSendMessage?.call('I want to make changes');
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onSendMessage?.call('Confirm and list my property');
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Confirm & List'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stageNum = _getStageNumber();
    final stageTitle = _getStageTitle();
    final stageIcon = _getStageIcon();

    return Card(
      elevation: 2,
      margin: CardStyles.cardMargin,
      clipBehavior: Clip.antiAlias,
      shape: CardStyles.cardShape(context),
      child: Padding(
        padding: CardStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stage progress
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stageIcon,
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
                        'Property Submission',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stageTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step $stageNum of 5',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(stageNum / 5 * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stageNum / 5,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submission ID reference
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tag,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ID: $submissionId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message/Instructions
            if (message.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stage-specific action buttons
            ..._getStageActions(context, theme),

            // Back button if applicable
            if (_shouldShowBackButton()) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    onSendMessage?.call('Go back to previous step');
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
