import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Service for uploading files to Supabase Storage
/// Handles video uploads for property submissions
class FileUploadService {
  final _supabase = Supabase.instance.client;
  static const String bucketName = 'property-media';

  /// Upload files to Supabase Storage and return public URLs
  ///
  /// [files] - List of files to upload
  /// [userId] - User ID for organizing files in storage
  ///
  /// Returns list of public URLs for uploaded files
  Future<List<String>> uploadFiles(List<File> files, String userId) async {
    final List<String> uploadedUrls = [];

    for (final file in files) {
      try {
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(file.path);
        final fileName = '$userId/$timestamp$extension';

        // Read file bytes
        final bytes = await file.readAsBytes();

        // Upload to Supabase Storage
        await _supabase.storage.from(bucketName).uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: _getContentType(extension),
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final publicUrl =
            _supabase.storage.from(bucketName).getPublicUrl(fileName);

        uploadedUrls.add(publicUrl);
      } catch (e) {
        throw FileUploadException(
          'Failed to upload file: ${file.path}',
          originalError: e,
        );
      }
    }

    return uploadedUrls;
  }

  /// Convert file to base64 data URL (for AI SDK compatibility)
  ///
  /// [file] - File to convert
  ///
  /// Returns data URL string in format: data:mime/type;base64,<base64data>
  Future<String> fileToDataUrl(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final extension = path.extension(file.path);
      final mimeType = _getContentType(extension);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw FileUploadException(
        'Failed to convert file to data URL: ${file.path}',
        originalError: e,
      );
    }
  }

  /// Get content type from file extension or path
  String getContentType(String pathOrExtension) {
    String extension = pathOrExtension;
    if (!extension.startsWith('.')) {
      extension = path.extension(pathOrExtension);
    }

    switch (extension.toLowerCase()) {
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.webm':
        return 'video/webm';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get content type from file extension (private helper)
  String _getContentType(String extension) {
    return getContentType(extension);
  }

  /// Validate file size
  ///
  /// [file] - File to validate
  /// [maxSizeBytes] - Maximum allowed size in bytes (default 10MB)
  ///
  /// Returns true if file size is valid
  Future<bool> validateFileSize(File file,
      {int maxSizeBytes = 10485760}) async {
    try {
      final fileSize = await file.length();
      return fileSize <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0;
    }
  }
}

/// Custom exception for file upload errors
class FileUploadException implements Exception {
  final String message;
  final dynamic originalError;

  FileUploadException(this.message, {this.originalError});

  @override
  String toString() {
    if (originalError != null) {
      return '$message\nOriginal error: $originalError';
    }
    return message;
  }
}
