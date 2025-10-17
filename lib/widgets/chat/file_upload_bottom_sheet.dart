import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Bottom sheet for uploading property videos
/// Supports camera recording and gallery selection
class FileUploadBottomSheet extends StatefulWidget {
  final Function(List<File>) onFilesSelected;
  final int maxFiles;
  final int maxFileSizeMB;
  final Duration maxVideoDuration;

  const FileUploadBottomSheet({
    super.key,
    required this.onFilesSelected,
    this.maxFiles = 5,
    this.maxFileSizeMB = 10,
    this.maxVideoDuration = const Duration(minutes: 2),
  });

  @override
  State<FileUploadBottomSheet> createState() => _FileUploadBottomSheetState();
}

class _FileUploadBottomSheetState extends State<FileUploadBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  bool _isProcessing = false;

  /// Pick video from camera
  Future<void> _pickVideoFromCamera() async {
    if (_selectedFiles.length >= widget.maxFiles) {
      _showError('Maximum ${widget.maxFiles} files allowed');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: widget.maxVideoDuration,
      );

      if (video != null) {
        await _addFile(File(video.path));
      }
    } catch (e) {
      _showError('Failed to record video: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Pick video from gallery
  Future<void> _pickVideoFromGallery() async {
    if (_selectedFiles.length >= widget.maxFiles) {
      _showError('Maximum ${widget.maxFiles} files allowed');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: widget.maxVideoDuration,
      );

      if (video != null) {
        await _addFile(File(video.path));
      }
    } catch (e) {
      _showError('Failed to select video: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Add file with validation
  Future<void> _addFile(File file) async {
    // Validate file size
    final fileSize = await file.length();
    final fileSizeMB = fileSize / (1024 * 1024);

    if (fileSizeMB > widget.maxFileSizeMB) {
      _showError(
        'Video must be less than ${widget.maxFileSizeMB}MB\n'
        'Current size: ${fileSizeMB.toStringAsFixed(1)}MB',
      );
      return;
    }

    setState(() {
      _selectedFiles.add(file);
    });
  }

  /// Remove file from selection
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Confirm and return selected files
  void _confirmSelection() {
    if (_selectedFiles.isEmpty) {
      _showError('Please select at least one video');
      return;
    }

    widget.onFilesSelected(_selectedFiles);
    Navigator.pop(context);
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Upload Property Video',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Max ${widget.maxFileSizeMB}MB • ${widget.maxVideoDuration.inMinutes} min duration',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // File preview
            if (_selectedFiles.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return _buildFilePreview(_selectedFiles[index], index);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Processing indicator
            if (_isProcessing) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              Text(
                'Processing video...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            if (!_isProcessing) ...[
              // Camera button
              ElevatedButton.icon(
                onPressed: _pickVideoFromCamera,
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Gallery button
              OutlinedButton.icon(
                onPressed: _pickVideoFromGallery,
                icon: const Icon(Icons.video_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Confirm button
            if (_selectedFiles.isNotEmpty && !_isProcessing)
              ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Upload ${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'Video' : 'Videos'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build file preview widget
  Widget _buildFilePreview(File file, int index) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Video icon container
          Container(
            width: 80,
            height: 80,
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
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeMB = snapshot.data! / (1024 * 1024);
                      return Text(
                        '${sizeMB.toStringAsFixed(1)}MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
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
            top: -8,
            right: -8,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: theme.colorScheme.error,
                size: 24,
              ),
              onPressed: () => _removeFile(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove video',
            ),
          ),
        ],
      ),
    );
  }
}
