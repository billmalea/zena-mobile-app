import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/file_upload_service.dart';

/// Chat Provider for managing chat state and messages
/// Uses ChangeNotifier to notify UI of chat changes
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FileUploadService _fileUploadService = FileUploadService();
  final _uuid = const Uuid();

  List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  bool _isUploadingFiles = false;
  double _uploadProgress = 0.0;
  String? _error;
  StreamSubscription<ChatEvent>? _streamSubscription;

  /// Get current messages
  List<Message> get messages => List.unmodifiable(_messages);

  /// Get current conversation ID
  String? get conversationId => _conversationId;

  /// Check if chat is loading
  bool get isLoading => _isLoading;

  /// Check if files are being uploaded
  bool get isUploadingFiles => _isUploadingFiles;

  /// Get upload progress (0.0 to 1.0)
  double get uploadProgress => _uploadProgress;

  /// Get current error message
  String? get error => _error;

  /// Load a conversation by ID
  Future<void> loadConversation(String conversationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final conversation = await _chatService.getConversation(conversationId);
      _conversationId = conversation.id;
      _messages = List.from(conversation.messages);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load conversation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Start a new conversation
  Future<void> startNewConversation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final conversation = await _chatService.createConversation();
      _conversationId = conversation.id;
      _messages = [];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create conversation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Send a message with streaming support
  /// Converts files to data URLs and sends as message parts (AI SDK format)
  Future<void> sendMessage(String text, [List<File>? files]) async {
    if (text.trim().isEmpty && (files == null || files.isEmpty)) return;

    try {
      // Convert files to data URLs if provided
      List<Map<String, dynamic>>? fileParts;
      if (files != null && files.isNotEmpty) {
        _isUploadingFiles = true;
        _uploadProgress = 0.0;
        _error = null;
        notifyListeners();

        try {
          fileParts = [];
          for (int i = 0; i < files.length; i++) {
            final file = files[i];
            
            // Update progress
            _uploadProgress = (i / files.length) * 0.5;
            notifyListeners();
            
            // Convert file to data URL
            final dataUrl = await _fileUploadService.fileToDataUrl(file);
            final mimeType = _fileUploadService.getContentType(file.path);
            
            fileParts.add({
              'type': 'file',
              'mediaType': mimeType,
              'url': dataUrl,
            });
            
            // Update progress
            _uploadProgress = ((i + 1) / files.length) * 0.5 + 0.5;
            notifyListeners();
          }
        } catch (e) {
          _error = 'Failed to process files: ${e.toString()}';
          _isUploadingFiles = false;
          notifyListeners();
          rethrow;
        } finally {
          _isUploadingFiles = false;
          notifyListeners();
        }
      }

      // Add user message immediately
      final userMessage = Message(
        id: _uuid.v4(),
        role: 'user',
        content: text.isNotEmpty ? text : 'Uploaded ${files?.length ?? 0} video(s)',
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

      // Stream the response with file parts
      final stream = _chatService.sendMessage(
        message: text.isNotEmpty ? text : 'I uploaded a property video',
        conversationId: _conversationId,
        fileParts: fileParts,
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

  /// Handle incoming chat events from the stream
  void _handleChatEvent(ChatEvent event, String assistantMessageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == assistantMessageId);
    
    if (messageIndex == -1) return;

    final currentMessage = _messages[messageIndex];

    if (event.isText && event.content != null) {
      // Append text content to assistant message
      _messages[messageIndex] = currentMessage.copyWith(
        content: currentMessage.content + event.content!,
      );
      notifyListeners();
    } else if (event.isTool && event.toolResult != null) {
      // Add tool result to assistant message
      final toolResult = ToolResult(
        toolName: event.toolResult!['toolName'] as String? ?? 'unknown',
        result: event.toolResult!,
      );
      
      final updatedToolResults = List<ToolResult>.from(
        currentMessage.toolResults ?? [],
      )..add(toolResult);

      _messages[messageIndex] = currentMessage.copyWith(
        toolResults: updatedToolResults,
      );
      notifyListeners();
    } else if (event.isError) {
      // Handle error event
      _error = event.content ?? 'An error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all messages (for new conversation)
  void clearMessages() {
    _messages = [];
    _conversationId = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
