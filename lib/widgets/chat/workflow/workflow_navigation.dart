import 'package:flutter/material.dart';
import '../../../models/submission_state.dart';

/// Navigation controls for property submission workflow
/// Provides back button, cancel button, help text, and status badge
class WorkflowNavigation extends StatelessWidget {
  final SubmissionStage currentStage;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;
  final String? helpText;

  const WorkflowNavigation({
    super.key,
    required this.currentStage,
    this.onBack,
    this.onCancel,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation buttons and status badge
          Row(
            children: [
              // Back button (if applicable)
              if (_canGoBack(currentStage) && onBack != null) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  tooltip: 'Go back',
                  iconSize: 20,
                ),
                const SizedBox(width: 8),
              ],

              // Workflow status badge
              _buildStatusBadge(context),

              const Spacer(),

              // Cancel button
              if (onCancel != null)
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancel'),
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),

          // Stage-specific help text
          if (helpText != null ||
              _getDefaultHelpText(currentStage) != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    helpText ?? _getDefaultHelpText(currentStage)!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build workflow status badge
  Widget _buildStatusBadge(BuildContext context) {
    final stageName = _getStageName(currentStage);
    final stageColor = _getStageColor(context, currentStage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stageColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStageIcon(currentStage),
            size: 14,
            color: stageColor,
          ),
          const SizedBox(width: 6),
          Text(
            stageName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: stageColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Check if back navigation is allowed for current stage
  bool _canGoBack(SubmissionStage stage) {
    // Back is not allowed from start stage
    return stage != SubmissionStage.start;
  }

  /// Get human-readable stage name
  String _getStageName(SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return 'Getting Started';
      case SubmissionStage.videoUploaded:
        return 'Video Uploaded';
      case SubmissionStage.confirmData:
        return 'Confirm Data';
      case SubmissionStage.provideInfo:
        return 'Provide Info';
      case SubmissionStage.finalConfirm:
        return 'Final Review';
    }
  }

  /// Get stage-specific icon
  IconData _getStageIcon(SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return Icons.play_circle_outline;
      case SubmissionStage.videoUploaded:
        return Icons.video_library;
      case SubmissionStage.confirmData:
        return Icons.check_circle_outline;
      case SubmissionStage.provideInfo:
        return Icons.edit_note;
      case SubmissionStage.finalConfirm:
        return Icons.task_alt;
    }
  }

  /// Get stage-specific color
  Color _getStageColor(BuildContext context, SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return Theme.of(context).colorScheme.primary;
      case SubmissionStage.videoUploaded:
        return Colors.blue;
      case SubmissionStage.confirmData:
        return Colors.orange;
      case SubmissionStage.provideInfo:
        return Colors.purple;
      case SubmissionStage.finalConfirm:
        return Colors.green;
    }
  }

  /// Get default help text for stage if not provided
  String? _getDefaultHelpText(SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return 'Upload a video of your property to get started. Make sure to show all rooms and features.';
      case SubmissionStage.videoUploaded:
        return 'Your video is being analyzed. This may take a moment.';
      case SubmissionStage.confirmData:
        return 'Review the extracted information and make any necessary corrections.';
      case SubmissionStage.provideInfo:
        return 'Please provide the missing information to complete your listing.';
      case SubmissionStage.finalConfirm:
        return 'Review all details before submitting your property listing.';
    }
  }
}
