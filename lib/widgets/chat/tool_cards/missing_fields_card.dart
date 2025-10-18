import 'package:flutter/material.dart';
import 'card_styles.dart';
import 'package:flutter/services.dart';

/// MissingFieldsCard prompts users to provide missing required property fields.
///
/// This card displays a list of missing fields with hints and input prompts,
/// validates user input, and collects the data for submission.
class MissingFieldsCard extends StatefulWidget {
  /// List of missing required field names
  final List<String> missingFields;

  /// Hints/descriptions for each field
  final Map<String, String> fieldHints;

  /// Callback when user submits the collected data
  final Function(Map<String, dynamic>) onSubmit;

  const MissingFieldsCard({
    super.key,
    required this.missingFields,
    required this.fieldHints,
    required this.onSubmit,
  });

  @override
  State<MissingFieldsCard> createState() => _MissingFieldsCardState();
}

class _MissingFieldsCardState extends State<MissingFieldsCard> {
  // Controllers for text fields
  final Map<String, TextEditingController> _controllers = {};

  // Validation errors for each field
  final Map<String, String?> _errors = {};

  // Track which fields have been touched
  final Set<String> _touchedFields = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each missing field
    for (final field in widget.missingFields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Validate a specific field
  String? _validateField(String fieldName, String value) {
    final trimmedValue = value.trim();

    // Check if field is empty
    if (trimmedValue.isEmpty) {
      return 'This field is required';
    }

    // Field-specific validation
    switch (fieldName.toLowerCase()) {
      case 'title':
        if (trimmedValue.length < 10) {
          return 'Title must be at least 10 characters';
        }
        if (trimmedValue.length > 100) {
          return 'Title must be less than 100 characters';
        }
        break;

      case 'description':
        if (trimmedValue.length < 20) {
          return 'Description must be at least 20 characters';
        }
        if (trimmedValue.length > 1000) {
          return 'Description must be less than 1000 characters';
        }
        break;

      case 'rentamount':
      case 'rent_amount':
      case 'rent':
      case 'price':
        final amount = int.tryParse(trimmedValue.replaceAll(',', ''));
        if (amount == null) {
          return 'Please enter a valid number';
        }
        if (amount <= 0) {
          return 'Amount must be greater than 0';
        }
        if (amount > 1000000000) {
          return 'Amount seems too high';
        }
        break;

      case 'bedrooms':
      case 'bathrooms':
        final count = int.tryParse(trimmedValue.replaceAll(',', ''));
        if (count == null) {
          return 'Please enter a valid number';
        }
        if (count < 0) {
          return 'Cannot be negative';
        }
        if (count > 50) {
          return 'Value seems too high';
        }
        break;

      case 'location':
      case 'address':
      case 'neighborhood':
        if (trimmedValue.length < 3) {
          return 'Please enter a valid location';
        }
        break;

      case 'propertytype':
      case 'property_type':
        if (trimmedValue.length < 3) {
          return 'Please enter a valid property type';
        }
        break;
    }

    return null;
  }

  /// Validate all fields
  bool _validateAllFields() {
    bool isValid = true;
    final newErrors = <String, String?>{};

    for (final field in widget.missingFields) {
      final value = _controllers[field]?.text ?? '';
      final error = _validateField(field, value);
      newErrors[field] = error;
      if (error != null) {
        isValid = false;
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
      _touchedFields.addAll(widget.missingFields);
    });

    return isValid;
  }

  /// Handle field change
  void _onFieldChanged(String fieldName) {
    if (_touchedFields.contains(fieldName)) {
      final value = _controllers[fieldName]?.text ?? '';
      setState(() {
        _errors[fieldName] = _validateField(fieldName, value);
      });
    }
  }

  /// Handle field focus loss
  void _onFieldUnfocused(String fieldName) {
    setState(() {
      _touchedFields.add(fieldName);
      final value = _controllers[fieldName]?.text ?? '';
      _errors[fieldName] = _validateField(fieldName, value);
    });
  }

  /// Handle submit
  void _handleSubmit() {
    if (_validateAllFields()) {
      // Collect all field values
      final data = <String, dynamic>{};
      for (final field in widget.missingFields) {
        final value = _controllers[field]?.text.trim() ?? '';
        
        // Convert numeric fields
        if (_isNumericField(field)) {
          data[field] = int.tryParse(value.replaceAll(',', '')) ?? value;
        } else {
          data[field] = value;
        }
      }

      widget.onSubmit(data);
    }
  }

  /// Check if field should be numeric
  bool _isNumericField(String fieldName) {
    final lowerField = fieldName.toLowerCase();
    return lowerField.contains('amount') ||
        lowerField.contains('price') ||
        lowerField.contains('rent') ||
        lowerField == 'bedrooms' ||
        lowerField == 'bathrooms';
  }

  /// Get keyboard type for field
  TextInputType _getKeyboardType(String fieldName) {
    if (_isNumericField(fieldName)) {
      return TextInputType.number;
    }
    if (fieldName.toLowerCase().contains('description')) {
      return TextInputType.multiline;
    }
    return TextInputType.text;
  }

  /// Get max lines for field
  int _getMaxLines(String fieldName) {
    if (fieldName.toLowerCase().contains('description')) {
      return 4;
    }
    return 1;
  }

  /// Get input formatters for field
  List<TextInputFormatter>? _getInputFormatters(String fieldName) {
    if (_isNumericField(fieldName)) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  /// Format field name for display
  String _formatFieldName(String fieldName) {
    // Convert camelCase or snake_case to Title Case
    final words = fieldName
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ');

    return words
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Build input field for a missing field
  Widget _buildInputField({
    required BuildContext context,
    required String fieldName,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final controller = _controllers[fieldName]!;
    final hint = widget.fieldHints[fieldName] ?? 'Enter ${_formatFieldName(fieldName)}';
    final error = _errors[fieldName];
    final hasError = error != null && _touchedFields.contains(fieldName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label
          Text(
            _formatFieldName(fieldName).toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Input field
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _onFieldUnfocused(fieldName);
              }
            },
            child: TextField(
              controller: controller,
              keyboardType: _getKeyboardType(fieldName),
              maxLines: _getMaxLines(fieldName),
              inputFormatters: _getInputFormatters(fieldName),
              onChanged: (_) => _onFieldChanged(fieldName),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError ? colorScheme.error : colorScheme.primary,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Error message
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: CardStyles.cardMargin,
      clipBehavior: Clip.antiAlias,
      shape: CardStyles.cardShape(context),
      child: SingleChildScrollView(
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
                      Icons.edit_note_outlined,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Missing Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.missingFields.length} field${widget.missingFields.length != 1 ? 's' : ''} required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Info message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
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
                        'Please provide the following information to complete your property listing.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Input fields for each missing field
              ...widget.missingFields.map((fieldName) {
                return _buildInputField(
                  context: context,
                  fieldName: fieldName,
                  theme: theme,
                );
              }),

              const SizedBox(height: 8),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Submit Information'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
