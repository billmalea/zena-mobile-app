import 'package:flutter/material.dart';

/// Widget that displays suggested queries for users to quickly start conversations
class SuggestedQueries extends StatelessWidget {
  final Function(String) onQuerySelected;
  final List<String> suggestions;

  const SuggestedQueries({
    super.key,
    required this.onQuerySelected,
    this.suggestions = defaultSuggestions,
  });

  /// Default suggested queries covering common use cases
  static const List<String> defaultSuggestions = [
    "Find me a 2-bedroom apartment in Westlands under 50k",
    "I want to list my property",
    "Show me bedsitters near Ngong Road",
    "What's the difference between a bedsitter and studio?",
    "Help me calculate what I can afford",
    "Tell me about Kilimani neighborhood",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Try asking:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        ...suggestions.map((query) => _buildQueryChip(context, query)),
      ],
    );
  }

  /// Builds a tappable query chip with border and arrow icon
  Widget _buildQueryChip(BuildContext context, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onQuerySelected(query),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  query,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
