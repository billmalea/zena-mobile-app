import 'package:flutter/material.dart';

/// Shared styling utilities for tool result cards
/// Provides consistent theming, spacing, and decoration across all cards
class CardStyles {
  // Private constructor to prevent instantiation
  CardStyles._();

  // ============================================================================
  // CARD DECORATION
  // ============================================================================

  /// Standard card decoration with theme-aware colors
  static BoxDecoration cardDecoration(BuildContext context, {Color? borderColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor ?? colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Card shape for Material Card widget
  static ShapeBorder cardShape(BuildContext context, {Color? borderColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: borderColor ?? colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // ============================================================================
  // SPACING CONSTANTS
  // ============================================================================

  /// Standard card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  /// Standard card margin
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 8, horizontal: 4);

  /// Section spacing (between major sections)
  static const double sectionSpacing = 16.0;

  /// Element spacing (between related elements)
  static const double elementSpacing = 12.0;

  /// Small spacing (between tightly related elements)
  static const double smallSpacing = 8.0;

  /// Tiny spacing (for icon-text pairs)
  static const double tinySpacing = 4.0;

  // ============================================================================
  // CONTAINER DECORATIONS
  // ============================================================================

  /// Container for highlighted content (success, info, etc.)
  static BoxDecoration highlightContainer(
    BuildContext context, {
    required Color color,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Container for secondary content sections
  static BoxDecoration secondaryContainer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Container for primary highlighted content
  static BoxDecoration primaryContainer(BuildContext context, {double opacity = 0.3}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BoxDecoration(
      color: colorScheme.primaryContainer.withOpacity(opacity),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Container for info/tip messages
  static BoxDecoration infoContainer(BuildContext context) {
    return BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.blue.shade200,
        width: 1,
      ),
    );
  }

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  /// Primary elevated button style
  static ButtonStyle primaryButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Secondary outlined button style
  static ButtonStyle secondaryButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      foregroundColor: colorScheme.primary,
      side: BorderSide(
        color: colorScheme.primary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Destructive/error button style
  static ButtonStyle destructiveButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Success button style (e.g., for WhatsApp)
  static ButtonStyle successButton(BuildContext context, {Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      backgroundColor: backgroundColor ?? const Color(0xFF25D366), // WhatsApp green
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // ============================================================================
  // LOADING INDICATORS
  // ============================================================================

  /// Standard loading indicator
  static Widget loadingIndicator(BuildContext context, {double size = 24}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
      ),
    );
  }

  /// Loading indicator with message
  static Widget loadingWithMessage(BuildContext context, String message) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingIndicator(context),
        const SizedBox(height: 12),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Loading placeholder for images
  static Widget imageLoadingPlaceholder(
    BuildContext context, {
    double height = 200,
    IconData icon = Icons.image,
    String message = 'Loading...',
  }) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          loadingIndicator(context),
        ],
      ),
    );
  }

  // ============================================================================
  // ERROR DISPLAYS
  // ============================================================================

  /// Standard error message container
  static Widget errorMessage(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline,
    VoidCallback? onRetry,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: primaryButton(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Image error placeholder
  static Widget imageErrorPlaceholder(
    BuildContext context, {
    double height = 200,
    String message = 'Failed to load image',
  }) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: theme.colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STATUS BADGES
  // ============================================================================

  /// Status badge (e.g., Available, Unavailable, Pending)
  static Widget statusBadge(
    BuildContext context,
    String text, {
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ICON-TEXT PAIRS
  // ============================================================================

  /// Icon with text label (for property details, etc.)
  static Widget iconText(
    BuildContext context,
    IconData icon,
    String text, {
    double iconSize = 20,
    Color? iconColor,
    TextStyle? textStyle,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.onSurface.withOpacity(0.7);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? defaultColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
            color: defaultColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // SECTION HEADERS
  // ============================================================================

  /// Section header text style
  static Widget sectionHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  // ============================================================================
  // DIVIDERS
  // ============================================================================

  /// Standard divider with spacing
  static Widget divider({double height = 24}) {
    return Divider(height: height);
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /// Get darker shade of a color
  static Color getDarkerColor(Color color, double factor) {
    return Color.fromRGBO(
      (color.red * factor).round().clamp(0, 255),
      (color.green * factor).round().clamp(0, 255),
      (color.blue * factor).round().clamp(0, 255),
      1,
    );
  }

  /// Get lighter shade of a color
  static Color getLighterColor(Color color, double factor) {
    return Color.fromRGBO(
      (color.red + (255 - color.red) * factor).round().clamp(0, 255),
      (color.green + (255 - color.green) * factor).round().clamp(0, 255),
      (color.blue + (255 - color.blue) * factor).round().clamp(0, 255),
      1,
    );
  }
}
