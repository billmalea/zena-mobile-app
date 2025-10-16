import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Main chat screen (placeholder)
/// TODO: Implement full chat functionality in task 7
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Zena'),
      ),
      body: const Center(
        child: Text(
          'Chat Screen - Coming Soon',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
