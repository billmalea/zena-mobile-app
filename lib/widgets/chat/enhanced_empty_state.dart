import 'package:flutter/material.dart';
import 'suggested_queries.dart';

/// Enhanced empty state widget that welcomes users and shows key features
/// Displays when the chat has no messages
class EnhancedEmptyState extends StatelessWidget {
  final String? userName;
  final Function(String) onQuerySelected;

  const EnhancedEmptyState({
    super.key,
    this.userName,
    required this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // App logo/icon
          Icon(
            Icons.home_work,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 24),

          // Welcome message with user name if available
          Text(
            'Hi${userName != null ? ' $userName' : ''}! 👋',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'I\'m your AI rental assistant',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Features section header
          const Text(
            'I can help you:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Key features list
          _buildFeature(context, Icons.search, 'Find properties'),
          _buildFeature(context, Icons.add_home, 'List your property'),
          _buildFeature(context, Icons.calculate, 'Calculate affordability'),
          _buildFeature(
              context, Icons.location_city, 'Get neighborhood info'),

          const SizedBox(height: 32),

          // Suggested queries
          SuggestedQueries(onQuerySelected: onQuerySelected),
        ],
      ),
    );
  }

  /// Builds a feature item with icon and text
  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
