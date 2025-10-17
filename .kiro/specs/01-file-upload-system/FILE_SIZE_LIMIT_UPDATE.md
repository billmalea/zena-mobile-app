# File Size Limit Update - 10MB → 50MB

## Summary

Updated the file size limit from 10MB to 50MB to match the Supabase bucket configuration.

## Changes Made

### 1. Code Changes

#### `lib/config/app_config.dart`
```dart
// Before:
static const int maxFileSize = 10 * 1024 * 1024; // 10MB

// After:
static const int maxFileSize = 50 * 1024 * 1024; // 50MB (matches Supabase bucket limit)
```

#### `lib/services/file_upload_service.dart`
```dart
// Before:
Future<bool> validateFileSize(File file, {int maxSizeBytes = 10485760}) async

// After:
Future<bool> validateFileSize(File file, {int maxSizeBytes = 52428800}) async
```

**Note:** 52428800 bytes = 50 MB

### 2. Documentation Updates

Updated the following specification documents:

- ✅ `requirements.md` - Updated requirement 1.5 to specify 50MB limit
- ✅ `design.md` - Updated error message to reference 50MB limit
- ✅ `tasks.md` - Updated task descriptions to reference 50MB limit

## Verification

### Bucket Configuration
Your Supabase bucket is configured with:
```json
{
  "file_size_limit": 52428800,  // 50 MB
  "allowed_mime_types": ["image/*", "video/*"]
}
```

### Code Configuration
Your app now validates files with:
- **AppConfig.maxFileSize**: 52428800 bytes (50 MB)
- **FileUploadService.validateFileSize**: 52428800 bytes default (50 MB)

## Usage

### In Code

```dart
// Using AppConfig constant
final isValid = await fileSize <= AppConfig.maxFileSize;

// Using FileUploadService validation
final fileUploadService = FileUploadService();
final isValid = await fileUploadService.validateFileSize(file);

// Custom size limit (if needed)
final isValid = await fileUploadService.validateFileSize(
  file,
  maxSizeBytes: 100 * 1024 * 1024, // 100MB
);
```

### Error Messages

When implementing UI validation, use:
```dart
if (!isValid) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('File size exceeds 50MB limit'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Benefits of 50MB Limit

1. **HD Video Support**: Allows users to upload higher quality property videos
2. **Longer Videos**: Supports longer video durations without compression
3. **Better AI Processing**: Higher quality videos provide better AI analysis results
4. **Matches Backend**: Aligns with Supabase bucket configuration

## File Size Reference

| Size | Bytes | Typical Use Case |
|------|-------|------------------|
| 10 MB | 10,485,760 | ~1 minute 720p video |
| 25 MB | 26,214,400 | ~2 minutes 720p video |
| 50 MB | 52,428,800 | ~4 minutes 720p or ~2 minutes 1080p video |
| 100 MB | 104,857,600 | ~8 minutes 720p or ~4 minutes 1080p video |

## Testing Recommendations

Test with various file sizes:
- ✅ Small file (< 10 MB) - Should upload successfully
- ✅ Medium file (10-30 MB) - Should upload successfully
- ✅ Large file (30-50 MB) - Should upload successfully
- ❌ Oversized file (> 50 MB) - Should show validation error

## Next Steps

1. ✅ Code updated with 50MB limit
2. ✅ Documentation updated
3. ⏳ Test with real video files of various sizes
4. ⏳ Verify error messages display correctly
5. ⏳ Test on both Android and iOS devices

## Notes

- The 50MB limit is enforced both client-side (app) and server-side (Supabase bucket)
- Users will see validation errors before attempting upload if file exceeds limit
- The limit can be adjusted in `AppConfig` if needed in the future
- Consider adding file compression for very large files (optional enhancement)
