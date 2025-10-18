import 'package:flutter/material.dart';
import 'card_styles.dart';

/// AffordabilityCard displays rent affordability calculations and recommendations.
///
/// This card is shown when calculating how much rent a user can afford
/// based on their monthly income, providing budget breakdowns and tips.
class AffordabilityCard extends StatelessWidget {
  /// User's monthly income
  final double monthlyIncome;

  /// Recommended rent range (min and max)
  final Map<String, double> recommendedRange;

  /// Affordability percentage (rent as % of income)
  final double affordabilityPercentage;

  /// Budget breakdown by category
  final Map<String, double> budgetBreakdown;

  /// Financial tips and recommendations
  final List<String> tips;

  const AffordabilityCard({
    super.key,
    required this.monthlyIncome,
    required this.recommendedRange,
    required this.affordabilityPercentage,
    required this.budgetBreakdown,
    required this.tips,
  });

  /// Get affordability status color
  Color _getAffordabilityColor(double percentage) {
    if (percentage <= 30) {
      return Colors.green;
    } else if (percentage <= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get affordability status text
  String _getAffordabilityStatus(double percentage) {
    if (percentage <= 30) {
      return 'Excellent';
    } else if (percentage <= 40) {
      return 'Moderate';
    } else {
      return 'High Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final affordabilityColor = _getAffordabilityColor(affordabilityPercentage);

    final minRent = recommendedRange['min'] ?? 0;
    final maxRent = recommendedRange['max'] ?? 0;

    return Card(
      elevation: 2,
      margin: CardStyles.cardMargin,
      clipBehavior: Clip.antiAlias,
      shape: CardStyles.cardShape(context),
      child: Padding(
        padding: CardStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calculate_outlined,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rent Affordability',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Monthly income display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: CardStyles.secondaryContainer(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Income',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'KES ${monthlyIncome.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recommended rent range - prominent display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Rent Range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minimum',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KES ${minRent.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'to',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Maximum',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KES ${maxRent.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: affordabilityColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          affordabilityPercentage <= 30
                              ? Icons.check_circle
                              : Icons.info,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${affordabilityPercentage.toStringAsFixed(0)}% of income - ${_getAffordabilityStatus(affordabilityPercentage)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget breakdown
            if (budgetBreakdown.isNotEmpty) ...[
              Text(
                'Budget Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: CardStyles.secondaryContainer(context),
                child: Column(
                  children: budgetBreakdown.entries.map((entry) {
                    final percentage = (entry.value / monthlyIncome * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(entry.key),
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'KES ${entry.value.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: colorScheme.outline.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Financial tips
            if (tips.isNotEmpty) ...[
              Text(
                'Financial Tips',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// Get icon for budget category
  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('rent') || cat.contains('housing')) {
      return Icons.home;
    } else if (cat.contains('food') || cat.contains('groceries')) {
      return Icons.restaurant;
    } else if (cat.contains('transport')) {
      return Icons.directions_car;
    } else if (cat.contains('utilities')) {
      return Icons.bolt;
    } else if (cat.contains('savings')) {
      return Icons.savings;
    } else if (cat.contains('entertainment')) {
      return Icons.movie;
    } else {
      return Icons.attach_money;
    }
  }
}
