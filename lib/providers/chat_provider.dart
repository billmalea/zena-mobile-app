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
  /// Uploads files to Supabase Storage and appends URLs to message text
  Future<void> sendMessage(String text, [List<File>? files]) async {
    print('🎬 [ChatProvider] sendMessage called');
    print('💬 [ChatProvider] Text: $text');
    print('📁 [ChatProvider] Files: ${files?.length ?? 0}');

    if (text.trim().isEmpty && (files == null || files.isEmpty)) {
      print('⚠️ [ChatProvider] Empty message, returning');
      return;
    }

    try {
      print('🔄 [ChatProvider] Processing message...');
      // Upload files to Supabase Storage and get public URLs
      List<String>? fileUrls;
      if (files != null && files.isNotEmpty) {
        _isUploadingFiles = true;
        _uploadProgress = 0.0;
        _error = null;
        notifyListeners();

        try {
          // Get user ID from Supabase auth
          final userId = _chatService.getUserId();
          if (userId == null) {
            throw Exception('User not authenticated');
          }

          // Upload files and track progress
          fileUrls = [];
          for (int i = 0; i < files.length; i++) {
            final file = files[i];

            // Update progress
            _uploadProgress = (i / files.length);
            notifyListeners();

            // Upload single file
            final urls = await _fileUploadService.uploadFiles([file], userId);
            fileUrls.addAll(urls);

            // Update progress
            _uploadProgress = ((i + 1) / files.length);
            notifyListeners();
          }
        } catch (e) {
          _error = 'Failed to upload files: ${e.toString()}';
          _isUploadingFiles = false;
          notifyListeners();
          rethrow;
        } finally {
          _isUploadingFiles = false;
          notifyListeners();
        }
      }

      // Build message text with file URLs appended
      String messageText =
          text.isNotEmpty ? text : 'I uploaded a property video';
      if (fileUrls != null && fileUrls.isNotEmpty) {
        messageText += '\n\n[Uploaded files: ${fileUrls.join(', ')}]';
      }

      // Add user message immediately
      final userMessage = Message(
        id: _uuid.v4(),
        role: 'user',
        content: messageText,
        createdAt: DateTime.now(),
      );
      _messages.add(userMessage);
      _error = null;
      print('✅ [ChatProvider] User message added: ${userMessage.id}');
      notifyListeners();

      // Set loading state
      _isLoading = true;
      print('⏳ [ChatProvider] Loading state set to true');
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
      print(
          '✅ [ChatProvider] Assistant message placeholder added: $assistantMessageId');
      notifyListeners();

      // Stream the response with message text (URLs already embedded)
      print('🔄 [ChatProvider] Calling ChatService.sendMessage...');
      print('📝 [ChatProvider] Message text: $messageText');
      print('🆔 [ChatProvider] Conversation ID: $_conversationId');

      final stream = _chatService.sendMessage(
        message: messageText,
        conversationId: _conversationId,
      );

      print('✅ [ChatProvider] Stream obtained, setting up listener...');

      _streamSubscription = stream.listen(
        (ChatEvent event) {
          print('📥 [ChatProvider] Stream event received: ${event.type}');
          _handleChatEvent(event, assistantMessageId);
        },
        onError: (error) {
          print('❌ [ChatProvider] Stream error: $error');
          _error = 'Stream error: ${error.toString()}';
          _isLoading = false;
          notifyListeners();
        },
        onDone: () {
          print('🏁 [ChatProvider] Stream done');
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );

      print('✅ [ChatProvider] Stream listener set up successfully');
    } catch (e) {
      print('❌ [ChatProvider] Exception caught: $e');
      print('❌ [ChatProvider] Stack trace: ${StackTrace.current}');
      _error = 'Failed to send message: ${e.toString()}';
      _isLoading = false;
      _isUploadingFiles = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Handle incoming chat events from the stream
  void _handleChatEvent(ChatEvent event, String assistantMessageId) {
    print('🎯 [ChatProvider] Received event: ${event.type}');

    final messageIndex =
        _messages.indexWhere((m) => m.id == assistantMessageId);

    if (messageIndex == -1) {
      print('⚠️ [ChatProvider] Message not found: $assistantMessageId');
      return;
    }

    final currentMessage = _messages[messageIndex];

    if (event.isText && event.content != null) {
      print(
          '💬 [ChatProvider] Updating text content: "${event.content!.substring(0, event.content!.length > 50 ? 50 : event.content!.length)}..."');

      // Replace text content with accumulated text from stream
      // (ChatService already accumulates text in buffer)
      _messages[messageIndex] = currentMessage.copyWith(
        content: event.content!,
      );
      notifyListeners();

      print('✅ [ChatProvider] Message updated, notified listeners');
    } else if (event.isToolResult && event.toolResult != null) {
      print('🔧 [ChatProvider] Tool result received');
      
      // Add tool result to assistant message
      final toolResult = ToolResult(
        toolName: event.toolResult!['toolName'] as String? ?? 'unknown',
        result: event.toolResult!,
      );

      final updatedToolResults = List<ToolResult>.from(
        currentMessage.toolResults ?? [],
      )..add(toolResult);

      // If no text content yet, add a default message
      String content = currentMessage.content;
      if (content.isEmpty && updatedToolResults.isNotEmpty) {
        content = 'I found some results for you:';
        print('💬 [ChatProvider] Adding default text for tool-only response');
      }

      _messages[messageIndex] = currentMessage.copyWith(
        content: content,
        toolResults: updatedToolResults,
      );
      
      print('✅ [ChatProvider] Tool result added, message updated');
      print('📝 [ChatProvider] Message content: "$content"');
      print('🔧 [ChatProvider] Tool results count: ${updatedToolResults.length}');
      print('🔔 [ChatProvider] Calling notifyListeners()');
      notifyListeners();
      print('✅ [ChatProvider] notifyListeners() called');
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
