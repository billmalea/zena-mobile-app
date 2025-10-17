# CRITICAL CODE EXAMPLES FOR MOBILE APP

## 1. Complete File Upload Implementation

### A. File Upload Widget with Camera & Gallery

```dart
// lib/widgets/chat/file_upload_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FileUploadBottomSheet extends StatefulWidget {
  final Function(List<File>) onFilesSelected;

  const FileUploadBottomSheet({
    super.key,
    required this.onFilesSelected,
  });

  @override
  State<FileUploadBottomSheet> createState() => _FileUploadBottomSheetState();
}

class _FileUploadBottomSheetState extends State<FileUploadBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length();

        // Validate file size (max 10MB)
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFiles.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      widget.onFilesSelected(_selectedFiles);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Upload Property Video',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
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

          // Upload progress
          if (_isUploading) ...[
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toInt()}% uploaded',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          if (!_isUploading) ...[
            ElevatedButton.icon(
              onPressed: () => _pickVideo(ImageSource.camera),
              icon: const Icon(Icons.videocam),
              label: const Text('Record Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickVideo(ImageSource.gallery),
              icon: const Icon(Icons.video_library),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Upload button
          if (_selectedFiles.isNotEmpty && !_isUploading)
            ElevatedButton(
              onPressed: _uploadFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Upload ${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'Video' : 'Videos'}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(File file, int index) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.video_file,
            size: 40,
          ),
        ),
        Positioned(
          top: -8,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _removeFile(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
```


### B. Supabase Storage Upload Service

```dart
// lib/services/file_upload_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class FileUploadService {
  final _supabase = Supabase.instance.client;

  /// Upload files to Supabase Storage and return public URLs
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
        await _supabase.storage
            .from('property-media')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: _getContentType(extension),
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final publicUrl = _supabase.storage
            .from('property-media')
            .getPublicUrl(fileName);

        uploadedUrls.add(publicUrl);
      } catch (e) {
        print('Error uploading file: $e');
        rethrow;
      }
    }

    return uploadedUrls;
  }

  /// Convert file to base64 data URL (for AI SDK compatibility)
  Future<String> fileToDataUrl(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final extension = path.extension(file.path);
    final mimeType = _getContentType(extension);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
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
}
```

---

## 2. Enhanced Message Input with File Upload

```dart
// lib/widgets/chat/message_input.dart (UPDATED)
import 'package:flutter/material.dart';
import 'dart:io';
import 'file_upload_bottom_sheet.dart';

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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<File> _attachedFiles = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFileUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FileUploadBottomSheet(
        onFilesSelected: (files) {
          setState(() {
            _attachedFiles = files;
          });
        },
      ),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFiles.isEmpty) return;

    widget.onSend(text, _attachedFiles.isNotEmpty ? _attachedFiles : null);
    
    _controller.clear();
    setState(() {
      _attachedFiles = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File preview
          if (_attachedFiles.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedFiles.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(Icons.video_file, size: 24),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _attachedFiles.removeAt(index);
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          Row(
            children: [
              // Attach file button
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: widget.isLoading ? null : _showFileUploadSheet,
                tooltip: 'Attach file',
              ),

              // Text input
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  enabled: !widget.isLoading,
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              IconButton(
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: widget.isLoading ? null : _handleSend,
                tooltip: 'Send',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```


---

## 3. Updated ChatProvider with File Upload Support

```dart
// lib/providers/chat_provider.dart (UPDATED)
import 'dart:io';
import '../services/file_upload_service.dart';

class ChatProvider with ChangeNotifier {
  // ... existing code ...
  
  final FileUploadService _fileUploadService = FileUploadService();
  bool _isUploadingFiles = false;

  bool get isUploadingFiles => _isUploadingFiles;

  /// Send message with optional files
  Future<void> sendMessage(String text, [List<File>? files]) async {
    if (text.trim().isEmpty && (files == null || files.isEmpty)) return;

    try {
      // Upload files first if present
      List<String>? fileUrls;
      if (files != null && files.isNotEmpty) {
        _isUploadingFiles = true;
        notifyListeners();

        // Get user ID (you'll need to get this from auth)
        final userId = 'user-id'; // Replace with actual user ID
        
        fileUrls = await _fileUploadService.uploadFiles(files, userId);
        
        _isUploadingFiles = false;
        notifyListeners();
      }

      // Add user message immediately
      final userMessage = Message(
        id: _uuid.v4(),
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      );
      _messages.add(userMessage);
      _error = null;
      notifyListeners();

      // Set loading state
      _isLoading = true;
      notifyListeners();

      // Create assistant message placeholder
      final assistantMessageId = _uuid.v4();
      final assistantMessage = Message(
        id: assistantMessageId,
        role: 'assistant',
        content: '',
        createdAt: DateTime.now(),
      );
      _messages.add(assistantMessage);
      notifyListeners();

      // Stream the response
      final stream = _chatService.sendMessage(
        message: text,
        conversationId: _conversationId,
        fileUrls: fileUrls,
      );

      _streamSubscription = stream.listen(
        (ChatEvent event) {
          _handleChatEvent(event, assistantMessageId);
        },
        onError: (error) {
          _error = 'Stream error: ${error.toString()}';
          _isLoading = false;
          notifyListeners();
        },
        onDone: () {
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
      _isLoading = false;
      _isUploadingFiles = false;
      notifyListeners();
      rethrow;
    }
  }
}
```

---

## 4. Tool Result Widget Factory (Complete)

```dart
// lib/widgets/chat/tool_result_widget.dart
import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'tool_cards/property_card.dart';
import 'tool_cards/payment_status_card.dart';
import 'tool_cards/phone_confirmation_card.dart';
import 'tool_cards/contact_info_card.dart';
import 'tool_cards/property_submission_card.dart';
import 'tool_cards/no_properties_found_card.dart';

class ToolResultWidget extends StatelessWidget {
  final ToolResult toolResult;
  final Function(String)? onSendMessage;

  const ToolResultWidget({
    super.key,
    required this.toolResult,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (toolResult.toolName) {
      case 'searchProperties':
      case 'smartSearch':
        return _buildPropertySearchResults(context);
      
      case 'requestContactInfo':
        return _buildContactInfoResult(context);
      
      case 'submitProperty':
        return _buildPropertySubmissionResult(context);
      
      case 'adminPropertyHunting':
        return _buildPropertyHuntingResult(context);
      
      case 'getNeighborhoodInfo':
        return _buildNeighborhoodInfo(context);
      
      case 'calculateAffordability':
        return _buildAffordabilityCalculator(context);
      
      default:
        return _buildGenericToolResult(context);
    }
  }

  Widget _buildPropertySearchResults(BuildContext context) {
    final result = toolResult.result;
    
    // Handle no results with property hunting offer
    if (result['canTriggerPropertyHunting'] == true && 
        result['matchCount'] == 0) {
      return NoPropertiesFoundCard(
        searchCriteria: result['searchCriteria'] ?? {},
        suggestions: List<String>.from(result['suggestions'] ?? []),
        onStartPropertyHunting: () {
          onSendMessage?.call('Yes, help me find properties');
        },
        onAdjustSearch: () {
          onSendMessage?.call('Help me adjust my search criteria');
        },
      );
    }
    
    // Handle results found
    if (result['properties'] != null) {
      final properties = List<Map<String, dynamic>>.from(
        result['properties']
      );
      
      return Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Found ${properties.length} properties',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          
          // Property cards
          ...properties.map((property) {
            return PropertyCard(
              propertyData: property,
              onRequestContact: (propertyId) {
                onSendMessage?.call(
                  'I want to contact the owner of property $propertyId'
                );
              },
            );
          }),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildContactInfoResult(BuildContext context) {
    final result = toolResult.result;
    
    // Payment initiated
    if (result['paymentInitiated'] == true) {
      return PaymentStatusCard(
        paymentId: result['paymentId'],
        propertyTitle: result['propertyTitle'],
        amount: result['amount'],
        message: result['message'],
        checkoutRequestId: result['checkoutRequestId'],
        phoneNumber: result['phoneNumber'],
        isPending: true,
        onTryAgain: () {
          onSendMessage?.call('Please try the payment again');
        },
      );
    }
    
    // Contact info received
    if (result['contactInfo'] != null) {
      return ContactInfoCard(
        contactInfo: result['contactInfo'],
        message: result['message'],
        alreadyPaid: result['alreadyPaid'] ?? false,
      );
    }
    
    // Phone confirmation needed
    if (result['needsPhoneConfirmation'] == true) {
      return PhoneConfirmationCard(
        message: result['message'],
        phoneNumber: result['userPhoneFromProfile'],
        onConfirm: () {
          onSendMessage?.call(
            'Yes, please use ${result['userPhoneFromProfile']} for the payment'
          );
        },
        onDecline: () {
          onSendMessage?.call(
            'No, I\'ll provide a different phone number'
          );
        },
      );
    }
    
    // Phone number needed
    if (result['needsPhoneNumber'] == true) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number Required',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(result['message'] ?? 'Please provide your phone number'),
            ],
          ),
        ),
      );
    }
    
    // Error
    if (result['error'] != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result['error'],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildPropertySubmissionResult(BuildContext context) {
    final result = toolResult.result;
    
    return PropertySubmissionCard(
      stage: result['stage'],
      message: result['message'],
      instructions: result['instructions'],
      submissionId: result['submissionId'],
      onSendMessage: onSendMessage,
    );
  }

  Widget _buildPropertyHuntingResult(BuildContext context) {
    final result = toolResult.result;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Property Hunting Request',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(result['message'] ?? 'Request submitted successfully'),
          ],
        ),
      ),
    );
  }

  Widget _buildNeighborhoodInfo(BuildContext context) {
    final result = toolResult.result;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['neighborhood'] ?? 'Neighborhood Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(result['description'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAffordabilityCalculator(BuildContext context) {
    final result = toolResult.result;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Affordability Calculation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(result['message'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericToolResult(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toolResult.toolName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(toolResult.result.toString()),
          ],
        ),
      ),
    );
  }
}
```


---

## 5. Updated Chat Screen with Tool Result Rendering

```dart
// lib/screens/chat/chat_screen.dart (UPDATED)
import '../../widgets/chat/tool_result_widget.dart';

class _ChatScreenState extends State<ChatScreen> {
  // ... existing code ...

  Widget _buildMessageList(ChatProvider chatProvider) {
    if (chatProvider.messages.isEmpty && !chatProvider.isLoading) {
      _previousMessageCount = 0;
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator at the end if loading
        if (index == chatProvider.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: TypingIndicator(),
          );
        }

        final message = chatProvider.messages[index];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message bubble for text content
            if (message.content.isNotEmpty)
              MessageBubble(message: message),

            // Tool results rendering
            if (message.hasToolResults)
              ...message.toolResults!.map((toolResult) {
                return ToolResultWidget(
                  toolResult: toolResult,
                  onSendMessage: (text) {
                    _handleSendMessage(
                      context,
                      chatProvider,
                      text,
                      null,
                    );
                  },
                );
              }),
          ],
        );
      },
    );
  }

  Future<void> _handleSendMessage(
    BuildContext context,
    ChatProvider chatProvider,
    String text,
    List<File>? files,
  ) async {
    if (text.trim().isEmpty && (files == null || files.isEmpty)) return;

    try {
      // Reset user scrolling flag when sending a new message
      _isUserScrolling = false;
      
      await chatProvider.sendMessage(text, files);
      
      // Auto-scroll will be handled by _handleAutoScroll
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to send message: ${e.toString()}');
      }
    }
  }

  // ... rest of existing code ...
}
```

---

## 6. Contact Info Card Implementation

```dart
// lib/widgets/chat/tool_cards/contact_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfoCard extends StatelessWidget {
  final Map<String, dynamic> contactInfo;
  final String message;
  final bool alreadyPaid;

  const ContactInfoCard({
    super.key,
    required this.contactInfo,
    required this.message,
    this.alreadyPaid = false,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = contactInfo['phone'] ?? contactInfo['agentPhone'];
    final email = contactInfo['email'];
    final propertyTitle = contactInfo['propertyTitle'];
    final propertyLocation = contactInfo['propertyLocation'];
    final rentAmount = contactInfo['rentAmount'];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alreadyPaid ? 'Already Paid!' : 'Payment Successful!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),

            // Property info
            if (propertyTitle != null) ...[
              Text(
                'Property Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                propertyTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (propertyLocation != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(propertyLocation),
                  ],
                ),
              ],
              if (rentAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  'KSh ${rentAmount.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}/month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
              const Divider(height: 32),
            ],

            // Contact info
            Text(
              'Agent Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Phone number
            if (phone != null) ...[
              _buildContactRow(
                context,
                icon: Icons.phone,
                label: 'Phone',
                value: phone,
                onTap: () => _makePhoneCall(phone),
                onCopy: () => _copyToClipboard(context, phone),
              ),
              const SizedBox(height: 12),
            ],

            // Email
            if (email != null) ...[
              _buildContactRow(
                context,
                icon: Icons.email,
                label: 'Email',
                value: email,
                onCopy: () => _copyToClipboard(context, email),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                if (phone != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(phone),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendSMS(phone),
                      icon: const Icon(Icons.message),
                      label: const Text('SMS'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}
```

---

## 7. No Properties Found Card (Property Hunting Offer)

```dart
// lib/widgets/chat/tool_cards/no_properties_found_card.dart
import 'package:flutter/material.dart';

class NoPropertiesFoundCard extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  final List<String> suggestions;
  final VoidCallback onStartPropertyHunting;
  final VoidCallback onAdjustSearch;

  const NoPropertiesFoundCard({
    super.key,
    required this.searchCriteria,
    required this.suggestions,
    required this.onStartPropertyHunting,
    required this.onAdjustSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(
                  Icons.search_off,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No Properties Found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              'We couldn\'t find any properties matching your criteria right now.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Search criteria
            if (searchCriteria.isNotEmpty) ...[
              Text(
                'Your Search:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...searchCriteria.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Text('${entry.key}: ${entry.value}'),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Suggestions
            if (suggestions.isNotEmpty) ...[
              Text(
                'Suggestions:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Property hunting offer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Property Hunting Service',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let our team find properties for you! We\'ll search actively and notify you when we find matches.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStartPropertyHunting,
                    icon: const Icon(Icons.search),
                    label: const Text('Start Property Hunting'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAdjustSearch,
                    icon: const Icon(Icons.tune),
                    label: const Text('Adjust Search'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 8. Property Submission Card (Multi-Stage)

```dart
// lib/widgets/chat/tool_cards/property_submission_card.dart
import 'package:flutter/material.dart';

class PropertySubmissionCard extends StatelessWidget {
  final String stage;
  final String message;
  final Map<String, dynamic>? instructions;
  final String? submissionId;
  final Function(String)? onSendMessage;

  const PropertySubmissionCard({
    super.key,
    required this.stage,
    required this.message,
    this.instructions,
    this.submissionId,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage indicator
            _buildStageIndicator(context),
            const SizedBox(height: 16),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Instructions
            if (instructions != null) ...[
              _buildInstructions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStageIndicator(BuildContext context) {
    final stageMap = {
      'start': 1,
      'video_upload': 1,
      'video_uploaded': 2,
      'user_confirmation': 2,
      'confirm_data': 3,
      'missing_info': 4,
      'provide_info': 4,
      'final_review': 5,
      'final_confirm': 5,
    };

    final currentStage = stageMap[stage] ?? 1;
    final totalStages = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Submission',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Stage $currentStage of $totalStages',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: currentStage / totalStages,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final title = instructions!['title'] as String?;
    final description = instructions!['description'] as String?;
    final checklist = instructions!['checklist'] as List?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          if (description != null) ...[
            Text(description),
            const SizedBox(height: 12),
          ],
          if (checklist != null && checklist.isNotEmpty) ...[
            ...checklist.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.toString())),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
```

---

**These code examples provide the complete implementation for the most critical missing features. Copy and adapt them to your mobile app to achieve feature parity with the web app.**
