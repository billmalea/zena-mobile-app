import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/message.dart';
import '../ai_sdk/ai_stream_client.dart'; // ← Add AI SDK types for UIMessage, MessagePart, etc.

import '../services/chat_service.dart';
import '../services/file_upload_service.dart';
import '../services/submission_state_manager.dart';
import '../services/message_persistence_service.dart';
import '../services/offline_message_queue.dart';
import '../services/message_sync_service.dart';

/// Chat Provider for managing chat state and messages
/// Uses ChangeNotifier to notify UI of chat changes
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FileUploadService _fileUploadService = FileUploadService();
  final SubmissionStateManager _stateManager;
  final Connectivity _connectivity = Connectivity();
  MessagePersistenceService? _persistenceService;
  OfflineMessageQueue? _offlineQueue;
  MessageSyncService? _syncService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _uuid = const Uuid();

  List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  bool _isUploadingFiles = false;
  double _uploadProgress = 0.0;
  String? _error;
  StreamSubscription<ChatEvent>? _streamSubscription;
  bool _isOnline = true;

  ChatProvider(this._stateManager) {
    _initializeProvider();
  }

  /// Initialize provider and load active submission states
  Future<void> _initializeProvider() async {
    // Initialize message persistence service
    try {
      _persistenceService = await MessagePersistenceService.create();
      // print('✅ [ChatProvider] Message persistence service initialized');

      // Initialize offline queue
      _offlineQueue = OfflineMessageQueue(_persistenceService!, _chatService);
      // print('✅ [ChatProvider] Offline message queue initialized');

      // Initialize sync service
      _syncService = MessageSyncService(_persistenceService!, _chatService);
      // print('✅ [ChatProvider] Message sync service initialized');

      // Start background sync
      _syncService!.startBackgroundSync();
      // print('✅ [ChatProvider] Background sync started');

      // Initialize connectivity monitoring
      await _initializeConnectivity();
      // print('✅ [ChatProvider] Connectivity monitoring initialized');
    } catch (e) {
      print('❌ [ChatProvider] Init failed: $e'); // KEEP: Error
    }

    // Process any queued updates first
    await _stateManager.processQueuedUpdates();

    // Submission recovery removed - backend handles everything via conversation history (like web)
  }

  /// Load active submission states on app restart
  /// Restores the most recent active submission if one exists
  Future<void> _loadActiveSubmissions() async {
    // Submission recovery removed - backend handles everything via conversation history (like web)
  }

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

  // All submission getters removed - backend handles via conversation history (like web)

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Check if there are queued messages waiting to be sent
  bool get hasQueuedMessages => _offlineQueue?.hasQueuedMessages ?? false;

  /// Get number of queued messages
  int get queuedMessageCount => _offlineQueue?.queueSize ?? 0;

  /// Load a conversation by ID
  /// Loads from local storage first for instant display, then syncs with backend
  Future<void> loadConversation(String conversationId) async {
    try {
      print(
          '🔍 [ChatProvider.loadConversation] Loading conversation: $conversationId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load from local storage first for instant display
      if (_persistenceService != null) {
        try {
          final localMessages =
              await _persistenceService!.loadMessages(conversationId);
          if (localMessages.isNotEmpty) {
            print(
                '📦 [ChatProvider.loadConversation] Loaded ${localMessages.length} messages from local storage');
            _conversationId = conversationId;
            _messages = localMessages;
            notifyListeners();
          }
        } catch (e) {
          print(
              '⚠️ [ChatProvider.loadConversation] Failed to load from local storage: $e');
        }
      }

      // Then sync with backend
      final conversation = await _chatService.getConversation(conversationId);
      print(
          '✅ [ChatProvider.loadConversation] Conversation loaded from backend');
      print(
          '🆔 [ChatProvider.loadConversation] Conversation ID: ${conversation.id}');
      print(
          '💬 [ChatProvider.loadConversation] Message count: ${conversation.messages.length}');

      _conversationId = conversation.id;
      _messages = List.from(conversation.messages);

      // Save backend messages to local storage
      if (_persistenceService != null) {
        try {
          for (final message in _messages) {
            await _persistenceService!.saveMessage(message, conversationId);
          }
          print(
              '💾 [ChatProvider.loadConversation] Saved ${_messages.length} messages to local storage');
        } catch (e) {
          print(
              '⚠️ [ChatProvider.loadConversation] Failed to save to local storage: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      print(
          '✅ [ChatProvider.loadConversation] State updated and listeners notified');
    } catch (e) {
      print('❌ [ChatProvider.loadConversation] Error: $e');
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
  /// Handles offline scenarios by queuing messages
  Future<void> sendMessage(String text, [List<File>? files]) async {
    // print('🎬 [ChatProvider] sendMessage called');
    print('💬 [ChatProvider] Sending: $text'); // KEEP: What user sent
    // print('📁 [ChatProvider] Files: ${files?.length ?? 0}');

    if (text.trim().isEmpty && (files == null || files.isEmpty)) {
      // print('⚠️ [ChatProvider] Empty message, returning');
      return;
    }

    try {
      // print('🔄 [ChatProvider] Processing message...');

      // Create conversation if it doesn't exist (first message)
      if (_conversationId == null) {
        // print('🆔 [ChatProvider] No conversation ID, creating new conversation...');
        try {
          final conversation = await _chatService.createConversation();
          _conversationId = conversation.id;
          // print('✅ [ChatProvider] Conversation created: $_conversationId');
          notifyListeners();
        } catch (e) {
          print(
              '❌ [ChatProvider] Failed to create conversation: $e'); // KEEP: Error
          // Continue anyway - backend will create one
        }
      }

      // Upload files directly to Supabase Storage (avoids Vercel 4.5MB limit)
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

            // Upload single file to Supabase Storage
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

      // Build message text (clean, without URLs shown to user)
      String messageText =
          text.isNotEmpty ? text : 'I uploaded a property video';

      // Build message text for backend (with URLs for AI processing)
      String messageTextForBackend = messageText;
      if (fileUrls != null && fileUrls.isNotEmpty) {
        messageTextForBackend += '\n\n[Uploaded files: ${fileUrls.join(', ')}]';
      }

      // Add file metadata (like web does)
      final metadata = <String, dynamic>{};

      // Add conversationId like web
      if (_conversationId != null) {
        metadata['conversationId'] = _conversationId;
      }

      // Store file URLs in metadata (not shown to user)
      if (fileUrls != null && fileUrls.isNotEmpty) {
        metadata['attachedFiles'] = fileUrls;
      }

      // NOTE: We DON'T send submissionId in metadata anymore
      // The AI extracts it from conversation history (same as web)
      // We still track it locally for app restart recovery

      // Add user message immediately (clean message without URLs)
      final userMessage = Message(
        id: _uuid.v4(),
        role: 'user',
        content: messageText,
        createdAt: DateTime.now(),
        metadata: metadata.isNotEmpty ? metadata : null,
      );
      _messages.add(userMessage);
      _error = null;
      // print('✅ [ChatProvider] User message added: ${userMessage.id}');

      // Save user message to local storage immediately
      if (_persistenceService != null && _conversationId != null) {
        try {
          await _persistenceService!.saveMessage(userMessage, _conversationId!);
          // print('💾 [ChatProvider] User message saved to local storage');
        } catch (e) {
          // print('⚠️ [ChatProvider] Failed to save user message to local storage: $e');
        }
      }

      notifyListeners();

      // Check if online before attempting to send
      await _checkConnectivity();

      if (!_isOnline) {
        // print('📴 [ChatProvider] Device is offline, queuing message');

        // Enqueue message for later sending
        if (_offlineQueue != null && _conversationId != null) {
          await _offlineQueue!.enqueue(userMessage, _conversationId!);
          // print('✅ [ChatProvider] Message queued for offline sending');
        }

        // Don't set error - we have the dot indicator now
        _isLoading = false;
        notifyListeners();
        return;
      }

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

      // Extract submissionId from recent tool results to include in context
      String? activeSubmissionId;
      for (final msg in _messages.reversed) {
        if (msg.toolResults != null) {
          for (final toolResult in msg.toolResults!) {
            if (toolResult.toolName == 'submitProperty' && 
                toolResult.result is Map<String, dynamic>) {
              final result = toolResult.result as Map<String, dynamic>;
              if (result['submissionId'] != null) {
                activeSubmissionId = result['submissionId'] as String;
                break;
              }
            }
          }
          if (activeSubmissionId != null) break;
        }
      }
      
      // Add submissionId context to message if found
      String messageWithContext = messageTextForBackend;
      if (activeSubmissionId != null) {
        messageWithContext = '$messageTextForBackend\n\n[Context: Active submission ID: $activeSubmissionId]';
        print('🔑 [ChatProvider] Including submissionId in context: $activeSubmissionId'); // KEEP: Critical
      }

      // Stream the response with message text (URLs embedded for backend)
      // print('🔄 [ChatProvider] Calling ChatService.sendMessage...');
      // print('📝 [ChatProvider] Message text for backend: $messageTextForBackend');
      print(
          '🆔 [ChatProvider] ConversationId: $_conversationId'); // KEEP: Critical for debugging

      final stream = _chatService.sendMessage(
        message: messageWithContext,
        conversationId: _conversationId,
        conversationHistory: null, // ← Don't send history, let backend load from DB
      );

      // print('✅ [ChatProvider] Stream obtained, setting up listener...');

      _streamSubscription = stream.listen(
        (ChatEvent event) {
          print(
              '📥 [ChatProvider] Event: ${event.type}'); // KEEP: Critical for flow
          _handleChatEvent(event, assistantMessageId);
        },
        onError: (error) {
          print('❌ [ChatProvider] Stream error: $error'); // KEEP: Error
          _error = 'Stream error: ${error.toString()}';
          _isLoading = false;

          notifyListeners();
        },
        onDone: () {
          // print('🏁 [ChatProvider] Stream done');
          _isLoading = false;

          // Save assistant message after streaming completes
          if (_persistenceService != null && _conversationId != null) {
            final messageIndex =
                _messages.indexWhere((m) => m.id == assistantMessageId);
            if (messageIndex != -1) {
              final message = _messages[messageIndex];
              _persistenceService!
                  .saveMessage(message, _conversationId!)
                  .then((_) {
                print(
                    '💾 [ChatProvider] Assistant message saved to local storage after streaming complete');
              }).catchError((e) {
                print(
                    '⚠️ [ChatProvider] Failed to save assistant message to local storage: $e');
              });
            }
          }

          notifyListeners();
        },
        cancelOnError: false,
      );

      // print('✅ [ChatProvider] Stream listener set up successfully');
    } catch (e) {
      print('❌ [ChatProvider] Exception: $e'); // KEEP: Error
      // print('❌ [ChatProvider] Stack trace: ${StackTrace.current}');

      // Check if error is due to network connectivity
      final isNetworkError = _isNetworkError(e);

      if (isNetworkError) {
        print('📴 [ChatProvider] Network error detected, marking as offline');
        _isOnline = false;

        // Get the last user message
        final lastMessage = _messages.lastWhere(
          (m) => m.role == 'user',
          orElse: () => _messages.last,
        );

        // Enqueue message for later sending
        if (_offlineQueue != null && _conversationId != null) {
          await _offlineQueue!.enqueue(lastMessage, _conversationId!);
          print('✅ [ChatProvider] Message queued after network error');
        }

        // Don't set error - we have the dot indicator now
      } else {
        _error = 'Failed to send message: ${e.toString()}';
      }

      _isLoading = false;
      _isUploadingFiles = false;

      notifyListeners();

      if (!isNetworkError) {
        rethrow;
      }
    }
  }

  /// Initialize connectivity monitoring with connectivity_plus
  Future<void> _initializeConnectivity() async {
    // Check initial connectivity status
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        print('🔄 [ChatProvider] Connectivity changed: $results');
        await _handleConnectivityChange(results);
      },
    );
  }

  /// Handle connectivity changes
  Future<void> _handleConnectivityChange(
      List<ConnectivityResult> results) async {
    final wasOnline = _isOnline;

    // Check if we have any connectivity
    _isOnline = results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);

    print(
        '📡 [ChatProvider] Connectivity status: ${_isOnline ? "ONLINE" : "OFFLINE"}');

    // If we just came back online, process queued messages
    if (_isOnline && !wasOnline) {
      print('✅ [ChatProvider] Connection restored, processing queued messages');
      await _processOfflineQueue();
    } else if (!_isOnline && wasOnline) {
      print('📴 [ChatProvider] Connection lost');
      // Don't set error - we have the dot indicator now
    }

    notifyListeners();
  }

  /// Check network connectivity using connectivity_plus
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);

      print(
          '📡 [ChatProvider] Connectivity check: ${_isOnline ? "ONLINE" : "OFFLINE"}');

      // Process any queued messages if we're online
      if (_isOnline &&
          _offlineQueue != null &&
          _offlineQueue!.hasQueuedMessages) {
        print(
            '🔄 [ChatProvider] Online with queued messages, processing queue');
        await _processOfflineQueue();
      }
    } catch (e) {
      print('⚠️ [ChatProvider] Connectivity check failed: $e');
      _isOnline = false;
    }
  }

  /// Check if error is network-related
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no internet');
  }

  /// Process offline message queue
  Future<void> _processOfflineQueue() async {
    if (_offlineQueue == null) return;

    try {
      print('🔄 [ChatProvider] Processing offline queue...');
      final success = await _offlineQueue!.processQueue();

      if (success) {
        print('✅ [ChatProvider] All queued messages sent successfully');
        _error = null;
      } else {
        print('⚠️ [ChatProvider] Some messages failed to send');
        _error = 'Some messages could not be sent. Will retry later.';
      }

      notifyListeners();
    } catch (e) {
      print('❌ [ChatProvider] Error processing offline queue: $e');
    }
  }

  /// Manually trigger queue processing (for pull-to-refresh or retry button)
  Future<void> retryQueuedMessages() async {
    await _checkConnectivity();

    if (_isOnline) {
      await _processOfflineQueue();
    } else {
      _error = 'Still offline. Please check your connection.';
      notifyListeners();
    }
  }

  /// Handle incoming chat events from the stream
  void _handleChatEvent(ChatEvent event, String assistantMessageId) {
    // print('🎯 [ChatProvider] Received event: ${event.type}');

    // Handle conversation ID event (set conversation ID if not already set)
    if (event.isConversationId && event.content != null) {
      if (_conversationId == null) {
        _conversationId = event.content;
        // print('🆔 [ChatProvider] Conversation ID set: $_conversationId');
        notifyListeners();
      }
      return;
    }

    final messageIndex =
        _messages.indexWhere((m) => m.id == assistantMessageId);

    if (messageIndex == -1) {
      // print('⚠️ [ChatProvider] Message not found: $assistantMessageId');
      return;
    }

    final currentMessage = _messages[messageIndex];

    if (event.isText && event.content != null) {
      // print('💬 [ChatProvider] Updating text content: "${event.content!.substring(0, event.content!.length > 50 ? 50 : event.content!.length)}..."');

      // Replace text content with accumulated text from stream
      // (ChatService already accumulates text in buffer)
      _messages[messageIndex] = currentMessage.copyWith(
        content: event.content!,
      );
      notifyListeners();

      // print('✅ [ChatProvider] Message updated, notified listeners');
    } else if (event.isToolResult && event.toolResult != null) {
      print(
          '🔧 [ChatProvider] Tool: ${event.toolResult!['toolName']}'); // KEEP: Critical
      print(
          '📊 [ChatProvider] Result: ${event.toolResult}'); // KEEP: Critical for debugging

      // Add tool result to assistant message
      // Extract the actual result data from the nested 'result' field
      final resultData = event.toolResult!['result'] as Map<String, dynamic>? ??
          event.toolResult!;

      final toolResult = ToolResult(
        toolName: event.toolResult!['toolName'] as String? ?? 'unknown',
        toolCallId: event.toolResult!['toolCallId']
            as String?, // ← Capture toolCallId from stream
        result: resultData,
      );

      final updatedToolResults = List<ToolResult>.from(
        currentMessage.toolResults ?? [],
      )..add(toolResult);

      // If no text content yet, add a default message
      String content = currentMessage.content;
      if (content.isEmpty && updatedToolResults.isNotEmpty) {
        content = 'I found some results for you:';
        // print('💬 [ChatProvider] Adding default text for tool-only response');
      }

      _messages[messageIndex] = currentMessage.copyWith(
        content: content,
        toolResults: updatedToolResults,
      );

      // print('✅ [ChatProvider] Tool result added, message updated');
      // print('📝 [ChatProvider] Message content: "$content"');
      // print('🔧 [ChatProvider] Tool results count: ${updatedToolResults.length}');
      // print('🔔 [ChatProvider] Calling notifyListeners()');
      notifyListeners();
      // print('✅ [ChatProvider] notifyListeners() called');

      // Tool results are handled by the UI cards (like web does)
      // No submission tracking needed - backend handles via conversation history
    } else if (event.isError) {
      // Handle error event
      _error = event.content ?? 'An error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  // All submission management methods removed - backend handles everything via conversation history (like web)

  /// Convert Message objects to UIMessage objects with tool results (like web's useChat does)
  List<UIMessage> _convertMessagesToUIMessages(List<Message> messages) {
    final uiMessages = <UIMessage>[];

    for (final msg in messages) {
      final parts = <MessagePart>[];

      // Add text part if there's content
      if (msg.content.isNotEmpty) {
        parts.add(TextPart(text: msg.content));
      }

      // Add the main message
      uiMessages.add(UIMessage(
        id: msg.id,
        role: msg.role,
        parts: parts.isNotEmpty ? parts : [TextPart(text: '')],
      ));

      // Add tool results as separate 'tool' messages (AI SDK format)
      if (msg.toolResults != null && msg.toolResults!.isNotEmpty) {
        for (final toolResult in msg.toolResults!) {
          uiMessages.add(UIMessage(
            id: '${msg.id}-tool-${toolResult.toolName}',
            role: 'tool',
            parts: [
              ToolCallPart(
                toolName: toolResult.toolName,
                toolCallId: toolResult.toolCallId,
                output: toolResult.result,
              ),
            ],
          ));
        }
      }
    }

    return uiMessages;
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

  /// Manually trigger message sync for current conversation
  /// Useful for pull-to-refresh or manual sync button
  Future<void> syncCurrentConversation() async {
    if (_syncService == null || _conversationId == null) {
      print(
          '⚠️ [ChatProvider] Cannot sync: service or conversation not initialized');
      return;
    }

    try {
      print(
          '🔄 [ChatProvider] Manually syncing conversation: $_conversationId');
      await _syncService!.syncMessages(_conversationId!);

      // Reload messages from local storage to reflect synced changes
      if (_persistenceService != null) {
        final syncedMessages =
            await _persistenceService!.loadMessages(_conversationId!);
        _messages = syncedMessages;
        print('✅ [ChatProvider] Conversation synced successfully');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [ChatProvider] Failed to sync conversation: $e');
      _error = 'Failed to sync messages: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Manually trigger sync for all conversations
  /// Useful for app startup or settings sync button
  Future<void> syncAllConversations() async {
    if (_syncService == null) {
      print('⚠️ [ChatProvider] Cannot sync: service not initialized');
      return;
    }

    try {
      print('🔄 [ChatProvider] Syncing all conversations');
      await _syncService!.syncAllConversations();
      print('✅ [ChatProvider] All conversations synced successfully');
    } catch (e) {
      print('❌ [ChatProvider] Failed to sync all conversations: $e');
      // Don't set error for background sync failures
    }
  }

  @override
  void dispose() {
    print('🧹 [ChatProvider] Disposing resources');

    // Stop background sync
    if (_syncService != null) {
      _syncService!.stopBackgroundSync();
      print('✅ [ChatProvider] Background sync stopped');
    }

    // Cancel stream subscriptions
    _streamSubscription?.cancel();
    _connectivitySubscription?.cancel();

    // Close persistence service
    _persistenceService?.close();

    super.dispose();
  }
}
