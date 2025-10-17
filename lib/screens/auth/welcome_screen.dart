import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

/// Welcome screen for user authentication
/// Displays app branding and Google Sign In button
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo and Branding
                _buildLogo(),
                const SizedBox(height: 24),
                _buildTitle(context),
                const SizedBox(height: 12),
                _buildSubtitle(context),
                const SizedBox(height: 48),

                // Google Sign In Button
                _buildSignInButton(context),
                const SizedBox(height: 24),

                // Error Message Display
                _buildErrorMessage(context),
                const SizedBox(height: 48),

                // Terms and Privacy Text
                _buildTermsAndPrivacy(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app logo
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Z',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build app title
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Welcome to Zena',
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build subtitle
  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Your AI-powered rental assistant',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build Google Sign In button with loading state
  Widget _buildSignInButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoading = authProvider.isLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handleSignIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Logo
                      Image.asset(
                        'assets/google_logo.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image not found
                          return const Icon(
                            Icons.login,
                            size: 24,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Build error message display
  Widget _buildErrorMessage(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final error = authProvider.error;

        if (error == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Failed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: theme.colorScheme.error,
                onPressed: () {
                  authProvider.clearError();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build terms and privacy text
  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'By signing in, you agree to our Terms of Service and Privacy Policy',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Handle sign in button tap
  Future<void> _handleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print('🔐 [WelcomeScreen] Starting Google Sign-In...');
      await authProvider.signInWithGoogle();
      print('✅ [WelcomeScreen] Google Sign-In completed successfully');
      // Navigation will be handled by AuthWrapper in main.dart
    } catch (e, stackTrace) {
      // Error is already set in AuthProvider
      // UI will update automatically via Consumer
      print('❌ [WelcomeScreen] Sign-In Error: $e');
      print('📍 [WelcomeScreen] Stack Trace: $stackTrace');
    }
  }
}
