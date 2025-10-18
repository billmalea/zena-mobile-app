import 'package:flutter/material.dart';

/// AuthPromptCard displays a prompt for users to sign in or sign up.
///
/// This card is shown when authentication is required to access certain features
/// or perform specific actions in the app.
class AuthPromptCard extends StatelessWidget {
  /// Message explaining why authentication is needed
  final String message;

  /// Callback when user taps sign in button
  final VoidCallback onSignIn;

  /// Callback when user taps sign up button
  final VoidCallback onSignUp;

  /// Optional callback to continue as guest (if feature allows)
  final VoidCallback? onContinueAsGuest;

  const AuthPromptCard({
    super.key,
    required this.message,
    required this.onSignIn,
    required this.onSignUp,
    this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with lock icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Authentication Required',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message explaining why auth is needed
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message.isNotEmpty
                          ? message
                          : 'Please sign in or create an account to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Benefits of signing in
            Text(
              'Benefits of having an account:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              context,
              Icons.bookmark_outline,
              'Save your favorite properties',
            ),
            const SizedBox(height: 8),
            _buildBenefitItem(
              context,
              Icons.history,
              'Track your search history',
            ),
            const SizedBox(height: 8),
            _buildBenefitItem(
              context,
              Icons.notifications_outlined,
              'Get notified about new listings',
            ),
            const SizedBox(height: 8),
            _buildBenefitItem(
              context,
              Icons.account_balance_wallet_outlined,
              'Manage payments and commissions',
            ),
            const SizedBox(height: 20),

            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary button - Sign In
                ElevatedButton.icon(
                  onPressed: onSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary button - Sign Up
                ElevatedButton.icon(
                  onPressed: onSignUp,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Optional - Continue as guest
                if (onContinueAsGuest != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onContinueAsGuest,
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    label: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),

            // Privacy note
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your data is secure and protected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a benefit item with icon and text
  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
