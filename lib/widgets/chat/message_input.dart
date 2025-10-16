import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Message input widget for composing and sending messages
/// Supports text input, file attachments, and send functionality
class MessageInput extends StatefulWidget {
  final Function(String text, List<String>? fileUrls) onSend;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _selectedFiles = [];
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle send button press
  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    // Send message
    widget.onSend(
      text,
      _selectedFiles.isNotEmpty ? _selectedFiles : null,
    );

    // Clear input
    _textController.clear();
    _selectedFiles.clear();

    setState(() {
      _isSending = false;
    });

    // Refocus
    _focusNode.requestFocus();
  }

  /// Handle attach button press
  void _handleAttach() {
    // TODO: Implement file picker in task 9.1
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attachment coming in task 9.1'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Remove file from selection
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textController.text.trim().isNotEmpty;
    final canSend = (hasText || _selectedFiles.isNotEmpty) && 
                    widget.isEnabled && 
                    !_isSending;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File previews
            if (_selectedFiles.isNotEmpty) _buildFilePreviews(),

            // Input row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attach button
                  IconButton(
                    onPressed: widget.isEnabled ? _handleAttach : null,
                    icon: const Icon(Icons.attach_file),
                    color: AppTheme.textSecondary,
                    tooltip: 'Attach file',
                  ),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120,
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: widget.isEnabled,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(
                            color: AppTheme.textTertiary,
                          ),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          if (canSend) {
                            _handleSend();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: canSend
                          ? AppTheme.primaryColor
                          : AppTheme.textTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: canSend ? _handleSend : null,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      color: Colors.white,
                      tooltip: 'Send message',
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

  /// Build file preview list
  Widget _buildFilePreviews() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFilePreview(file, index);
          }).toList(),
        ),
      ),
    );
  }

  /// Build individual file preview
  Widget _buildFilePreview(String fileUrl, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fileUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.insert_drive_file,
                      color: AppTheme.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: IconButton(
              onPressed: () => _removeFile(index),
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
