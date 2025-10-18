import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import '../models/message.dart';
import '../models/submission_state.dart';
import '../services/chat_service.dart';
import '../services/file_upload_service.dart';
import '../services/submission_state_manager.dart';

/// Chat Provider for managing chat state and messages
/// Uses ChangeNotifier to notify UI of chat changes
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FileUploadService _fileUploadService = FileUploadService();
  final SubmissionStateManager _stateManager;
  final _uuid = const Uuid();

  List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  bool _isUploadingFiles = false;
  double _uploadProgress = 0.0;
  String? _error;
  StreamSubscription<ChatEvent>? _streamSubscription;
  String? _currentSubmissionId;
  List<String> _corruptedSubmissions = [];

  ChatProvider(this._stateManager) {
    _initializeProvider();
  }

  /// Initialize provider and load active submission states
  Future<void> _initializeProvider() async {
    // Process any queued updates first
    await _stateManager.processQueuedUpdates();
    
    // Check for corrupted submissions
    final corrupted = _stateManager.detectCorruptedStates();
    if (corrupted.isNotEmpty) {
      print('⚠️ [ChatProvider] Found ${corrupted.length} corrupted submissions');
      // Store for later handling in UI
      _corruptedSubmissions = corrupted;
    }
    
    await _loadActiveSubmissions();
  }

  /// Load active submission states on app restart
  /// Restores the most recent active submission if one exists
  Future<void> _loadActiveSubmissions() async {
    try {
      final activeStates = _stateManager.getAllActiveStates();
      
      if (activeStates.isNotEmpty) {
        // Get the most recent submission
        final mostRecent = activeStates.first;
        _currentSubmissionId = mostRecent.submissionId;
        print('🔄 [ChatProvider] Restored submission: $_currentSubmissionId at stage ${mostRecent.stage}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [ChatProvider] Error loading active submissions: $e');
    }
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

  /// Get current submission ID
  String? get currentSubmissionId => _currentSubmissionId;

  /// Get current submission state
  SubmissionState? get currentSubmissionState => _currentSubmissionId != null
      ? _stateManager.getState(_currentSubmissionId!)
      : null;

  /// Check if there's a recovered submission that needs user action
  bool get hasRecoveredSubmission => _currentSubmissionId != null;

  /// Get list of corrupted submission IDs
  List<String> get corruptedSubmissions => List.unmodifiable(_corruptedSubmissions);

  /// Check if there are corrupted submissions
  bool get hasCorruptedSubmissions => _corruptedSubmissions.isNotEmpty;

  /// Load a conversation by ID
  Future<void> loadConversation(String conversationId) async {
    try {
      print('🔍 [ChatProvider.loadConversation] Loading conversation: $conversationId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final conversation = await _chatService.getConversation(conversationId);
      print('✅ [ChatProvider.loadConversation] Conversation loaded');
      print('🆔 [ChatProvider.loadConversation] Conversation ID: ${conversation.id}');
      print('💬 [ChatProvider.loadConversation] Message count: ${conversation.messages.length}');
      
      _conversationId = conversation.id;
      _messages = List.from(conversation.messages);

      _isLoading = false;
      notifyListeners();
      print('✅ [ChatProvider.loadConversation] State updated and listeners notified');
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

      // Add submission context to message metadata
      final metadata = <String, dynamic>{};
      if (_currentSubmissionId != null) {
        metadata['submissionId'] = _currentSubmissionId;
        if (currentSubmissionState != null) {
          metadata['workflowStage'] = currentSubmissionState!.stage.toString();
        }
        print(
            '📋 [ChatProvider] Adding submission context to message: submissionId=$_currentSubmissionId, stage=${currentSubmissionState?.stage}');
      }

      // Add user message immediately
      final userMessage = Message(
        id: _uuid.v4(),
        role: 'user',
        content: messageText,
        createdAt: DateTime.now(),
        metadata: metadata.isNotEmpty ? metadata : null,
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
          
          // Preserve submission state on error
          if (_currentSubmissionId != null) {
            handleSubmissionError(error.toString());
          }
          
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
      
      // Preserve submission state on error
      if (_currentSubmissionId != null) {
        await handleSubmissionError(e.toString());
      }
      
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
      print(
          '🔧 [ChatProvider] Tool results count: ${updatedToolResults.length}');
      print('🔔 [ChatProvider] Calling notifyListeners()');
      notifyListeners();
      print('✅ [ChatProvider] notifyListeners() called');

      // Handle submission workflow tool results
      final toolName = event.toolResult!['toolName'] as String?;
      if (toolName == 'submitProperty') {
        print('🏠 [ChatProvider] Detected submitProperty tool result');
        _handleSubmissionToolResult(event.toolResult!);
      }
    } else if (event.isError) {
      // Handle error event
      _error = event.content ?? 'An error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle submission workflow tool results
  /// Processes submitProperty tool results and updates submission state
  /// Handles stage transitions: start → video_uploaded → confirm_data → provide_info → final_confirm → complete
  void _handleSubmissionToolResult(Map<String, dynamic> result) {
    print('🔄 [ChatProvider] Processing submission tool result');

    final stage = result['stage'] as String?;
    final submissionId = result['submissionId'] as String?;

    print('📊 [ChatProvider] Stage: $stage, SubmissionId: $submissionId');

    // Initialize submission if not already started
    if (submissionId != null && _currentSubmissionId == null) {
      _currentSubmissionId = submissionId;
      print('🎬 [ChatProvider] Initialized submission: $_currentSubmissionId');
    }

    // Handle stage transitions
    if (stage == null) {
      print('⚠️ [ChatProvider] No stage found in tool result');
      return;
    }

    switch (stage) {
      case 'start':
        print('🎬 [ChatProvider] Stage: START - Initializing submission');
        // Submission already initialized above
        updateSubmissionStage(SubmissionStage.start);
        break;

      case 'video_uploaded':
        print('🎥 [ChatProvider] Stage: VIDEO_UPLOADED - Processing video data');
        _handleVideoUploadedStage(result);
        break;

      case 'confirm_data':
        print('✅ [ChatProvider] Stage: CONFIRM_DATA - Processing extracted data');
        _handleConfirmDataStage(result);
        break;

      case 'provide_info':
        print('📝 [ChatProvider] Stage: PROVIDE_INFO - Processing missing fields');
        _handleProvideInfoStage(result);
        break;

      case 'final_confirm':
        print('🎯 [ChatProvider] Stage: FINAL_CONFIRM - Final review');
        _handleFinalConfirmStage(result);
        break;

      case 'complete':
        print('✅ [ChatProvider] Stage: COMPLETE - Completing submission');
        completeSubmission();
        break;

      default:
        print('⚠️ [ChatProvider] Unknown stage: $stage');
    }
  }

  /// Handle video_uploaded stage
  /// Stores video URL, analysis results, and metadata
  void _handleVideoUploadedStage(Map<String, dynamic> result) {
    final videoData = result['video'] as Map<String, dynamic>?;

    if (videoData != null) {
      try {
        final video = VideoData.fromJson(videoData);
        updateSubmissionVideo(video);
        print('✅ [ChatProvider] Video data stored successfully');
      } catch (e) {
        print('❌ [ChatProvider] Error parsing video data: $e');
      }
    }

    updateSubmissionStage(SubmissionStage.videoUploaded);
  }

  /// Handle confirm_data stage
  /// Stores AI-extracted property data
  void _handleConfirmDataStage(Map<String, dynamic> result) {
    final extractedData = result['extractedData'] as Map<String, dynamic>?;

    if (extractedData != null) {
      updateSubmissionAIData(extractedData);
      print('✅ [ChatProvider] AI extracted data stored successfully');
    }

    updateSubmissionStage(SubmissionStage.confirmData);
  }

  /// Handle provide_info stage
  /// Stores missing fields list and user-provided data
  void _handleProvideInfoStage(Map<String, dynamic> result) {
    // Store missing fields
    final missingFields = result['missingFields'] as List<dynamic>?;
    if (missingFields != null && _currentSubmissionId != null) {
      final fields = missingFields.cast<String>();
      _stateManager.updateMissingFields(_currentSubmissionId!, fields);
      print('✅ [ChatProvider] Missing fields stored: $fields');
    }

    // Store user-provided data if present
    final userData = result['userData'] as Map<String, dynamic>?;
    if (userData != null) {
      updateSubmissionUserData(userData);
      print('✅ [ChatProvider] User provided data stored successfully');
    }

    updateSubmissionStage(SubmissionStage.provideInfo);
  }

  /// Handle final_confirm stage
  /// Prepares for final submission
  void _handleFinalConfirmStage(Map<String, dynamic> result) {
    // Store any final user corrections or additions
    final finalData = result['finalData'] as Map<String, dynamic>?;
    if (finalData != null) {
      updateSubmissionUserData(finalData);
      print('✅ [ChatProvider] Final data stored successfully');
    }

    updateSubmissionStage(SubmissionStage.finalConfirm);
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

  /// Start new property submission
  /// Creates a new submission state with unique ID
  void startSubmission() {
    final userId = _chatService.getUserId();
    if (userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    final state = _stateManager.createNew(userId);
    _currentSubmissionId = state.submissionId;
    print('🎬 [ChatProvider] Started submission: $_currentSubmissionId');
    notifyListeners();
  }

  /// Update submission stage
  /// Updates the current stage of the submission workflow
  Future<void> updateSubmissionStage(SubmissionStage stage) async {
    if (_currentSubmissionId != null) {
      await _stateManager.updateStage(_currentSubmissionId!, stage);
      print('📊 [ChatProvider] Updated submission stage to: $stage');
      notifyListeners();
    }
  }

  /// Update submission with video data
  /// Stores video URL, analysis results, and metadata
  Future<void> updateSubmissionVideo(VideoData video) async {
    if (_currentSubmissionId != null) {
      await _stateManager.updateVideoData(_currentSubmissionId!, video);
      print('🎥 [ChatProvider] Updated submission video data');
      notifyListeners();
    }
  }

  /// Update submission with AI extracted data
  /// Stores data extracted by AI from video analysis
  Future<void> updateSubmissionAIData(Map<String, dynamic> data) async {
    if (_currentSubmissionId != null) {
      await _stateManager.updateAIExtracted(_currentSubmissionId!, data);
      print('🤖 [ChatProvider] Updated AI extracted data');
      notifyListeners();
    }
  }

  /// Update submission with user provided data
  /// Merges user corrections/additions with existing data
  Future<void> updateSubmissionUserData(Map<String, dynamic> data) async {
    if (_currentSubmissionId != null) {
      await _stateManager.updateUserProvided(_currentSubmissionId!, data);
      print('👤 [ChatProvider] Updated user provided data');
      notifyListeners();
    }
  }

  /// Complete submission and clear state
  /// Called when submission workflow is successfully completed
  Future<void> completeSubmission() async {
    if (_currentSubmissionId != null) {
      await _stateManager.clearState(_currentSubmissionId!);
      print('✅ [ChatProvider] Completed submission: $_currentSubmissionId');
      _currentSubmissionId = null;
      notifyListeners();
    }
  }

  /// Cancel submission
  /// Clears current submission ID but preserves state for potential recovery
  /// Note: This should be called after user confirms cancellation via dialog
  Future<void> cancelSubmission() async {
    if (_currentSubmissionId != null) {
      print('❌ [ChatProvider] Cancelled submission: $_currentSubmissionId');
      // Keep state for recovery - just clear the current reference
      _currentSubmissionId = null;
      notifyListeners();
    }
  }

  /// Delete submission permanently
  /// Removes submission state completely (no recovery possible)
  Future<void> deleteSubmission(String submissionId) async {
    await _stateManager.clearState(submissionId);
    if (_currentSubmissionId == submissionId) {
      _currentSubmissionId = null;
    }
    print('🗑️ [ChatProvider] Deleted submission: $submissionId');
    notifyListeners();
  }

  /// Retry submission from last successful stage
  /// Recovers from errors and continues from where it left off
  Future<void> retrySubmission(String submissionId) async {
    try {
      final state = _stateManager.getState(submissionId);
      if (state == null) {
        throw Exception('Submission not found');
      }

      // Validate state integrity
      if (!_stateManager.validateState(state)) {
        throw Exception('Submission state is corrupted');
      }

      // Clear any previous error
      await _stateManager.clearError(submissionId);

      // Set as current submission
      _currentSubmissionId = submissionId;
      print('🔄 [ChatProvider] Retrying submission: $submissionId from stage ${state.stage}');
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to retry submission: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Handle submission error
  /// Preserves state and marks submission with error
  Future<void> handleSubmissionError(String errorMessage) async {
    if (_currentSubmissionId != null) {
      await _stateManager.markError(_currentSubmissionId!, errorMessage);
      print('❌ [ChatProvider] Submission error: $errorMessage');
      notifyListeners();
    }
  }

  /// Recover corrupted submission
  /// Attempts to fix or restart corrupted submission
  Future<void> recoverCorruptedSubmission(String submissionId) async {
    try {
      final state = _stateManager.getState(submissionId);
      if (state == null) {
        throw Exception('Submission not found');
      }

      // Check if state is valid
      if (_stateManager.validateState(state)) {
        // State is actually valid, just restore it
        _currentSubmissionId = submissionId;
        notifyListeners();
        return;
      }

      // State is corrupted, offer to restart
      await _stateManager.removeCorruptedState(submissionId);
      print('🗑️ [ChatProvider] Removed corrupted submission: $submissionId');
      
      // Start new submission
      startSubmission();
    } catch (e) {
      _error = 'Failed to recover submission: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Process queued state updates
  /// Attempts to save any pending updates that failed due to network issues
  Future<void> processQueuedUpdates() async {
    try {
      await _stateManager.processQueuedUpdates();
      print('✅ [ChatProvider] Processed queued updates');
    } catch (e) {
      print('❌ [ChatProvider] Failed to process queued updates: $e');
    }
  }

  /// Check for corrupted submissions
  /// Returns list of corrupted submission IDs
  List<String> checkForCorruptedSubmissions() {
    return _stateManager.detectCorruptedStates();
  }

  /// Get submission by ID
  /// Useful for recovering specific submissions
  SubmissionState? getSubmissionById(String submissionId) {
    return _stateManager.getState(submissionId);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
