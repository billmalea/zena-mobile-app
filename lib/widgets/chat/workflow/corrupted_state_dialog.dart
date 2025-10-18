import 'package:flutter/material.dart';

/// Dialog for handling corrupted submission state
/// Offers to restart submission or remove corrupted data
class CorruptedStateDialog extends StatelessWidget {
  final String submissionId;
  final VoidCallback onRestart;
  final VoidCallback onRemove;

  const CorruptedStateDialog({
    super.key,
    required this.submissionId,
    required this.onRestart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Corrupted Submission'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We detected a problem with your submission data.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What happened?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The submission data may have been corrupted due to an unexpected error or app crash.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submission ID: $submissionId',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can either restart the submission or remove the corrupted data.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRemove,
          child: const Text('Remove Data'),
        ),
        ElevatedButton(
          onPressed: onRestart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text('Restart Submission'),
        ),
      ],
    );
  }

  /// Show the dialog
  static Future<CorruptedStateAction?> show(
    BuildContext context,
    String submissionId,
  ) {
    return showDialog<CorruptedStateAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CorruptedStateDialog(
        submissionId: submissionId,
        onRestart: () =>
            Navigator.of(context).pop(CorruptedStateAction.restart),
        onRemove: () => Navigator.of(context).pop(CorruptedStateAction.remove),
      ),
    );
  }
}

/// Actions that can be taken for corrupted state
enum CorruptedStateAction {
  restart,
  remove,
}
