import 'package:flutter/material.dart';
import '../../../models/submission_state.dart';

/// Dialog to prompt user to continue or cancel incomplete submission
class SubmissionRecoveryDialog extends StatelessWidget {
  final SubmissionState submissionState;
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final VoidCallback? onRetry;
  final bool isError;

  const SubmissionRecoveryDialog({
    super.key,
    required this.submissionState,
    required this.onContinue,
    required this.onCancel,
    this.onRetry,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = submissionState.hasError || isError;
    
    return AlertDialog(
      title: Text(hasError ? 'Submission Error' : 'Continue Submission?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasError) ...[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'An error occurred during your submission.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            if (submissionState.lastError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  submissionState.lastError!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ] else ...[
            const Text(
              'You have an incomplete property submission.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 16),
          _buildInfoRow('Stage', _getStageName(submissionState.stage)),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Started',
            _formatDateTime(submissionState.createdAt),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Last Updated',
            _formatDateTime(submissionState.updatedAt),
          ),
          const SizedBox(height: 16),
          Text(
            hasError
                ? 'Would you like to retry from the last successful stage?'
                : 'Would you like to continue where you left off?',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Start New'),
        ),
        if (hasError && onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Retry'),
          )
        else
          ElevatedButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getStageName(SubmissionStage stage) {
    switch (stage) {
      case SubmissionStage.start:
        return 'Getting Started';
      case SubmissionStage.videoUploaded:
        return 'Video Uploaded';
      case SubmissionStage.confirmData:
        return 'Confirming Data';
      case SubmissionStage.provideInfo:
        return 'Providing Information';
      case SubmissionStage.finalConfirm:
        return 'Final Review';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Show the dialog for normal recovery
  static Future<bool?> show(
    BuildContext context,
    SubmissionState submissionState,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmissionRecoveryDialog(
        submissionState: submissionState,
        onContinue: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Show the dialog for error recovery with retry option
  static Future<RecoveryAction?> showError(
    BuildContext context,
    SubmissionState submissionState,
  ) {
    return showDialog<RecoveryAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmissionRecoveryDialog(
        submissionState: submissionState,
        isError: true,
        onContinue: () => Navigator.of(context).pop(RecoveryAction.continue_),
        onCancel: () => Navigator.of(context).pop(RecoveryAction.startNew),
        onRetry: () => Navigator.of(context).pop(RecoveryAction.retry),
      ),
    );
  }
}

/// Actions that can be taken from recovery dialog
enum RecoveryAction {
  continue_,
  retry,
  startNew,
}
