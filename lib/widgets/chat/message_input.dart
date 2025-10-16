import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/theme.dart';

/// MessageInput widget for composing and sending chat messages
/// Supports multi-line text input and file attachments
class MessageInput extends StatefulWidget {
  final Function(String text, List<String>? fileUrls) onSend;
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
  final ImagePicker _imagePicker = ImagePicker();
  
  List<XFile> _selectedFiles = [];
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
           (_textController.text.trim().isNotEmpty || _selectedFiles.isNotEmpty);
  }

  /// Handle send button press
  Future<void> _handleSend() async {
    if (!_canSend) return;

    final text = _textController.text.trim();
    final files = List<XFile>.from(_selectedFiles);

    // Clear input immediately for better UX
    _textController.clear();
    setState(() {
      _selectedFiles = [];
      _isSending = true;
    });

    try {
      // In a real implementation, files would be uploaded first
      // For now, we'll pass null for fileUrls
      // The actual upload logic would be in the ChatProvider
      List<String>? fileUrls;
      
      if (files.isNotEmpty) {
        // TODO: Upload files and get URLs
        // fileUrls = await _uploadFiles(files);
        fileUrls = files.map((f) => f.path).toList();
      }

      widget.onSend(text, fileUrls);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// Handle attach button press - show options
  Future<void> _handleAttach() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildAttachmentOptions(),
    );

    if (result == null) return;

    if (result == 'camera') {
      await _pickFromCamera();
    } else if (result == 'gallery') {
      await _pickFromGallery();
    }
  }

  /// Build attachment options bottom sheet
  Widget _buildAttachmentOptions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedFiles.add(photo);
        });
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  /// Pick images from gallery
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(images);
        });
      }
    } catch (e) {
      _showError('Failed to select images: $e');
    }
  }

  /// Remove file from selection
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            if (_selectedFiles.isNotEmpty) _buildFilePreviews(),

            // Input row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attach button
                  IconButton(
                    onPressed: widget.isLoading ? null : _handleAttach,
                    icon: const Icon(Icons.attach_file),
                    color: AppTheme.primaryColor,
                    tooltip: 'Attach file',
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
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
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
                        : const Icon(Icons.send),
                    color: AppTheme.primaryColor,
                    disabledColor: AppTheme.textTertiary,
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
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          return _buildFilePreview(_selectedFiles[index], index);
        },
      ),
    );
  }

  /// Build individual file preview
  Widget _buildFilePreview(XFile file, int index) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(file.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.backgroundColor,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppTheme.textTertiary,
                  ),
                );
              },
            ),
          ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
