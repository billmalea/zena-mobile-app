import 'package:flutter/material.dart';
import 'card_styles.dart';

/// Test widget to verify CardStyles work correctly in both light and dark themes
/// This is a simple demonstration widget, not for production use
class CardStylesTestWidget extends StatelessWidget {
  const CardStylesTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Styles Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Test Card with standard styling
          Card(
            elevation: 2,
            margin: CardStyles.cardMargin,
            clipBehavior: Clip.antiAlias,
            shape: CardStyles.cardShape(context),
            child: Padding(
              padding: CardStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardStyles.sectionHeader(context, 'Standard Card'),
                  const SizedBox(height: CardStyles.elementSpacing),
                  Text(
                    'This card uses consistent styling from CardStyles.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: CardStyles.sectionSpacing),
                  
                  // Secondary container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: CardStyles.secondaryContainer(context),
                    child: CardStyles.iconText(
                      context,
                      Icons.check_circle,
                      'Secondary Container',
                    ),
                  ),
                  const SizedBox(height: CardStyles.elementSpacing),
                  
                  // Primary container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: CardStyles.primaryContainer(context),
                    child: CardStyles.iconText(
                      context,
                      Icons.star,
                      'Primary Container',
                    ),
                  ),
                  const SizedBox(height: CardStyles.sectionSpacing),
                  
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: CardStyles.primaryButton(context),
                      child: const Text('Primary Button'),
                    ),
                  ),
                  const SizedBox(height: CardStyles.smallSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: CardStyles.secondaryButton(context),
                      child: const Text('Secondary Button'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test loading indicator
          Card(
            elevation: 2,
            margin: CardStyles.cardMargin,
            clipBehavior: Clip.antiAlias,
            shape: CardStyles.cardShape(context),
            child: Padding(
              padding: CardStyles.cardPadding,
              child: Column(
                children: [
                  CardStyles.sectionHeader(context, 'Loading States'),
                  const SizedBox(height: CardStyles.elementSpacing),
                  CardStyles.loadingWithMessage(context, 'Loading data...'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test error display
          Card(
            elevation: 2,
            margin: CardStyles.cardMargin,
            clipBehavior: Clip.antiAlias,
            shape: CardStyles.cardShape(context),
            child: Padding(
              padding: CardStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardStyles.sectionHeader(context, 'Error States'),
                  const SizedBox(height: CardStyles.elementSpacing),
                  CardStyles.errorMessage(
                    context,
                    'This is an error message',
                    onRetry: () {},
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test status badges
          Card(
            elevation: 2,
            margin: CardStyles.cardMargin,
            clipBehavior: Clip.antiAlias,
            shape: CardStyles.cardShape(context),
            child: Padding(
              padding: CardStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardStyles.sectionHeader(context, 'Status Badges'),
                  const SizedBox(height: CardStyles.elementSpacing),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CardStyles.statusBadge(
                        context,
                        'Available',
                        color: Colors.green,
                        icon: Icons.check,
                      ),
                      CardStyles.statusBadge(
                        context,
                        'Pending',
                        color: Colors.orange,
                        icon: Icons.schedule,
                      ),
                      CardStyles.statusBadge(
                        context,
                        'Unavailable',
                        color: Colors.red,
                        icon: Icons.close,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
