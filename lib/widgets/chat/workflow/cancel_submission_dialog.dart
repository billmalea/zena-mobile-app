import 'package:flutter/material.dart';

/// Dialog for confirming submission cancellation
/// Shows warning and allows user to confirm or cancel
class CancelSubmissionDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? submissionId;

  const CancelSubmissionDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.submissionId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Submission?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to cancel this property submission?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your progress will be saved and you can resume later.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (submissionId != null) ...[
            const SizedBox(height: 12),
            Text(
              'Submission ID: $submissionId',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Keep Working'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancel Submission'),
        ),
      ],
    );
  }

  /// Show the dialog
  static Future<bool?> show(
    BuildContext context, {
    String? submissionId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CancelSubmissionDialog(
        submissionId: submissionId,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
