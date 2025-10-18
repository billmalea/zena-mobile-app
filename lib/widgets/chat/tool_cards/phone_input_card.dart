import 'package:flutter/material.dart';
import 'card_styles.dart';

/// PhoneInputCard provides a form for users to input their phone number
/// when it's not available in their profile or they want to use a different number.
///
/// This card validates Kenyan phone formats and normalizes them to +254 format
/// before submission.
class PhoneInputCard extends StatefulWidget {
  /// The message explaining why phone input is needed
  final String message;

  /// Property data for context (title, commission amount, etc.)
  final Map<String, dynamic> property;

  /// Callback when user submits a valid phone number
  /// The phone number will be normalized to +254 format
  final Function(String) onSubmit;

  const PhoneInputCard({
    super.key,
    required this.message,
    required this.property,
    required this.onSubmit,
  });

  @override
  State<PhoneInputCard> createState() => _PhoneInputCardState();
}

class _PhoneInputCardState extends State<PhoneInputCard> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _errorMessage;
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  /// Validates Kenyan phone number formats:
  /// - +254XXXXXXXXX (12 digits total)
  /// - 254XXXXXXXXX (12 digits total)
  /// - 07XXXXXXXX (10 digits)
  /// - 01XXXXXXXX (10 digits)
  bool _validatePhoneNumber(String phone) {
    // Remove all whitespace and special characters except +
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for +254 format (12 digits total)
    if (RegExp(r'^\+254[17]\d{8}$').hasMatch(cleaned)) {
      return true;
    }

    // Check for 254 format without + (12 digits total)
    if (RegExp(r'^254[17]\d{8}$').hasMatch(cleaned)) {
      return true;
    }

    // Check for 07 or 01 format (10 digits)
    if (RegExp(r'^0[17]\d{8}$').hasMatch(cleaned)) {
      return true;
    }

    return false;
  }

  /// Normalizes phone number to +254 format
  String _normalizePhoneNumber(String phone) {
    // Remove all whitespace and special characters except +
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Already in +254 format
    if (cleaned.startsWith('+254')) {
      return cleaned;
    }

    // In 254 format without +
    if (cleaned.startsWith('254')) {
      return '+$cleaned';
    }

    // In 07 or 01 format - replace leading 0 with +254
    if (cleaned.startsWith('0')) {
      return '+254${cleaned.substring(1)}';
    }

    return cleaned;
  }

  void _onPhoneChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage = null;
        _isValid = false;
      } else if (_validatePhoneNumber(value)) {
        _errorMessage = null;
        _isValid = true;
      } else {
        _errorMessage = 'Please enter a valid Kenyan phone number';
        _isValid = false;
      }
    });
  }

  void _onSubmit() {
    if (_isValid) {
      final normalizedPhone = _normalizePhoneNumber(_phoneController.text);
      widget.onSubmit(normalizedPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract property details
    final propertyTitle = widget.property['title'] as String? ?? 'Property';
    // Handle both commission_amount and commission field names
    final commission = (widget.property['commission_amount'] ?? widget.property['commission'] ?? 0) as num;
    final formattedCommission = 'KES ${commission.toStringAsFixed(0)}';

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
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enter Phone Number',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Property context
            Container(
              padding: const EdgeInsets.all(12),
              decoration: CardStyles.secondaryContainer(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          propertyTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Commission: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        formattedCommission,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Explanation text
            Text(
              widget.message.isNotEmpty
                  ? widget.message
                  : 'Please enter your M-Pesa phone number to receive the payment request.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Phone number input field
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onChanged: _onPhoneChanged,
              onSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+254712345678 or 0712345678',
                prefixIcon: Icon(
                  Icons.phone,
                  color: _isValid
                      ? colorScheme.primary
                      : (_errorMessage != null
                          ? colorScheme.error
                          : colorScheme.onSurface.withOpacity(0.6)),
                ),
                suffixIcon: _phoneController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _phoneController.clear();
                          _onPhoneChanged('');
                        },
                      )
                    : null,
                errorText: _errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.error,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Format hints
            Container(
              padding: const EdgeInsets.all(10),
              decoration: CardStyles.secondaryContainer(context).copyWith(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Accepted formats: +254712345678, 254712345678, or 0712345678',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isValid ? _onSubmit : null,
                icon: const Icon(Icons.send),
                label: const Text('Submit Phone Number'),
                style: CardStyles.primaryButton(context).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return colorScheme.onSurface.withOpacity(0.12);
                    }
                    return colorScheme.primary;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return colorScheme.onSurface.withOpacity(0.38);
                    }
                    return colorScheme.onPrimary;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
