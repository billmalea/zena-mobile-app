import 'package:flutter/material.dart';
import 'dart:io';
import 'file_upload_bottom_sheet.dart';

/// MessageInput widget for composing and sending chat messages
/// Supports multi-line text input and file attachments
class MessageInput extends StatefulWidget {
  final Function(String text, List<File>? files) onSend;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<File> _attachedFiles = [];
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Check if send button should be enabled
  bool get _canSend {
    return !_isSending && 
           !widget.isLoading && 
           (_textController.text.trim().isNotEmpty || _attachedFiles.isNotEmpty);
  }

  /// Handle send button press
  Future<void> _handleSend() async {
    if (!_canSend) return;

    final text = _textController.text.trim();
    final files = _attachedFiles.isNotEmpty ? List<File>.from(_attachedFiles) : null;

    // Clear input immediately for better UX
    _textController.clear();
    setState(() {
      _attachedFiles = [];
      _isSending = true;
    });

    try {
      widget.onSend(text, files);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// Show file upload bottom sheet
  void _showFileUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FileUploadBottomSheet(
        onFilesSelected: (files) {
          setState(() {
            _attachedFiles = files;
          });
        },
      ),
    );
  }

  /// Remove file from selection
  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File previews
            if (_attachedFiles.isNotEmpty) _buildFilePreviews(),

            // Input row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attach button
                  IconButton(
                    onPressed: widget.isLoading ? null : _showFileUploadSheet,
                    icon: const Icon(Icons.attach_file),
                    color: theme.colorScheme.primary,
                    tooltip: 'Attach video',
                  ),

                  const SizedBox(width: 8),

                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.dividerColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  IconButton(
                    onPressed: _canSend ? _handleSend : null,
                    icon: _isSending
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    color: theme.colorScheme.primary,
                    disabledColor: theme.disabledColor,
                    tooltip: 'Send message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build file preview section
  Widget _buildFilePreviews() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _attachedFiles.length,
              itemBuilder: (context, index) {
                return _buildFilePreview(_attachedFiles[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual file preview
  Widget _buildFilePreview(File file, int index) {
    final theme = Theme.of(context);
    
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Video icon container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_file,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 2),
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeMB = snapshot.data! / (1024 * 1024);
                      return Text(
                        '${sizeMB.toStringAsFixed(1)}MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Remove button
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
