import 'package:flutter/material.dart';
import 'connectivity_indicator.dart';

/// Example of how to integrate the connectivity indicator in your app bar
/// 
/// Usage:
/// ```dart
/// AppBar(
///   title: Text('Chat'),
///   actions: [
///     ConnectivityIndicator(size: 10),
///     SizedBox(width: 16),
///   ],
/// )
/// ```

class ChatAppBarExample extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Chat'),
      actions: const [
        // Simple dot indicator
        ConnectivityIndicator(size: 10),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Alternative: Indicator with label
class ChatAppBarWithLabelExample extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBarWithLabelExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Chat'),
      actions: const [
        // Dot with label
        ConnectivityIndicator(
          size: 8,
          showLabel: true,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Alternative: Indicator in title area
class ChatAppBarWithTitleIndicatorExample extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBarWithTitleIndicatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        children: [
          Text('Chat'),
          SizedBox(width: 12),
          ConnectivityIndicator(size: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Alternative: Larger indicator for better visibility
class ChatAppBarLargeIndicatorExample extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBarLargeIndicatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Chat'),
      actions: const [
        // Larger dot for better visibility
        ConnectivityIndicator(size: 12),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
