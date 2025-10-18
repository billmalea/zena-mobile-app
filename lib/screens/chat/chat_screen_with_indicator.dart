// This is an example showing how to add the connectivity indicator
// Copy the _buildAppBar method to your chat_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/connectivity_indicator.dart';

/// Example of _buildAppBar with connectivity indicator
/// 
/// Replace your existing _buildAppBar method in chat_screen.dart with this:
PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.menu),
      tooltip: 'Conversations',
      onPressed: () {}, // Your existing onPressed
    ),
    title: const Text('Chat'), // Your existing title widget
    actions: [
      // ✅ ADD THIS: Connectivity indicator
      const ConnectivityIndicator(size: 10),
      const SizedBox(width: 12),
      
      // Your existing actions
      IconButton(
        icon: const Icon(Icons.add_comment_outlined),
        tooltip: 'New Chat',
        onPressed: () {}, // Your existing onPressed
      ),
      const SizedBox(width: 8),
    ],
  );
}

// Don't forget to add this import at the top of chat_screen.dart:
// import '../../widgets/connectivity_indicator.dart';
