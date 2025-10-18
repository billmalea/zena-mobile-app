import 'package:flutter/material.dart';
import '../../../models/submission_state.dart';

/// Visual indicator showing progress through the 5-stage property submission workflow
///
/// Displays:
/// - Current stage number (e.g., "2/5")
/// - Linear progress bar
/// - Stage names with checkmarks for completed stages
/// - Highlighted current stage
///
/// Example:
/// ```dart
/// StageProgressIndicator(
///   currentStage: SubmissionStage.confirmData,
/// )
/// ```
class StageProgressIndicator extends StatelessWidget {
  /// The current stage in the submission workflow
  final SubmissionStage currentStage;

  /// Total number of stages in the workflow (default: 5)
  final int totalStages;

  const StageProgressIndicator({
    super.key,
    required this.currentStage,
    this.totalStages = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentIndex = _getStageIndex(currentStage);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stage counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submission Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stage ${currentIndex + 1}/$totalStages',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / totalStages,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stage list with checkmarks
            ...SubmissionStage.values.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;

              return _buildStageItem(
                context,
                stage: stage,
                stageNumber: index + 1,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build individual stage item with icon and name
  Widget _buildStageItem(
    BuildContext context, {
    required SubmissionStage stage,
    required int stageNumber,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on state
    Color textColor;
    Color backgroundColor;

    if (isCompleted) {
      textColor = colorScheme.onSurface;
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.3);
    } else if (isCurrent) {
      textColor = colorScheme.onSurface;
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.5);
    } else {
      textColor = colorScheme.onSurface.withOpacity(0.5);
      backgroundColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border.all(
                color: colorScheme.primary.withOpacity(0.5),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Stage icon (checkmark or number)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.primary
                  : isCurrent
                      ? colorScheme.primary.withOpacity(0.2)
                      : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: colorScheme.onPrimary,
                    )
                  : Text(
                      '$stageNumber',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Stage name
          Expanded(
            child: Text(
              _getStageName(stage),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),

          // Current indicator
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Get the index of the current stage (0-based)
  int _getStageIndex(SubmissionStage stage) {
    return SubmissionStage.values.indexOf(stage);
  }

  /// Get human-readable name for each stage
  String _getStageName(SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return 'Start Submission';
      case SubmissionStage.videoUploaded:
        return 'Video Uploaded';
      case SubmissionStage.confirmData:
        return 'Confirm Data';
      case SubmissionStage.provideInfo:
        return 'Provide Info';
      case SubmissionStage.finalConfirm:
        return 'Final Confirmation';
    }
  }
}
