import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/submission_state.dart';

/// Service for managing submission state persistence and retrieval
/// Handles CRUD operations for submission states using SharedPreferences
class SubmissionStateManager {
  static const String _storageKey = 'submission_states';
  static const String _queueKey = 'submission_state_queue';
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  
  /// Queue for pending state updates when network fails
  final List<_QueuedUpdate> _updateQueue = [];

  SubmissionStateManager(this._prefs);

  /// Create new submission state with unique ID
  /// Returns the newly created SubmissionState
  SubmissionState createNew(String userId) {
    final submissionId = _generateSubmissionId();
    final now = DateTime.now();
    final state = SubmissionState(
      submissionId: submissionId,
      userId: userId,
      stage: SubmissionStage.start,
      createdAt: now,
      updatedAt: now,
    );
    saveState(state);
    return state;
  }

  /// Get submission state by ID
  /// Returns null if submission not found
  SubmissionState? getState(String submissionId) {
    final states = _loadAllStates();
    return states[submissionId];
  }

  /// Save submission state to local storage
  /// Overwrites existing state with same submissionId
  Future<void> saveState(SubmissionState state) async {
    final states = _loadAllStates();
    states[state.submissionId] = state;
    await _saveAllStates(states);
  }

  /// Update submission stage
  /// Updates the stage and updatedAt timestamp
  Future<void> updateStage(
    String submissionId,
    SubmissionStage stage,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        stage: stage,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Update video data for submission
  /// Stores video URL, analysis results, and metadata
  Future<void> updateVideoData(
    String submissionId,
    VideoData video,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        video: video,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Update AI extracted data
  /// Stores data extracted by AI from video analysis
  Future<void> updateAIExtracted(
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        aiExtracted: data,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Update user provided data
  /// Merges new data with existing user provided data
  Future<void> updateUserProvided(
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      final merged = {...?state.userProvided, ...data};
      await saveState(state.copyWith(
        userProvided: merged,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Update missing fields list
  /// Stores list of fields that need to be provided by user
  Future<void> updateMissingFields(
    String submissionId,
    List<String> fields,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        missingFields: fields,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Clear submission state
  /// Removes submission from storage (typically after completion)
  Future<void> clearState(String submissionId) async {
    final states = _loadAllStates();
    states.remove(submissionId);
    await _saveAllStates(states);
  }

  /// Get all active submission states
  /// Returns list sorted by most recently updated first
  List<SubmissionState> getAllActiveStates() {
    final states = _loadAllStates();
    final stateList = states.values.toList();
    stateList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return stateList;
  }

  /// Generate unique submission ID
  /// Format: sub_{timestamp}_{uuid_prefix}
  String _generateSubmissionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuidPrefix = _uuid.v4().substring(0, 8);
    return 'sub_${timestamp}_$uuidPrefix';
  }

  /// Load all states from SharedPreferences
  /// Returns empty map if no states exist
  Map<String, SubmissionState> _loadAllStates() {
    final json = _prefs.getString(_storageKey);
    if (json == null || json.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> data = jsonDecode(json);
      return data.map((key, value) =>
          MapEntry(key, SubmissionState.fromJson(value as Map<String, dynamic>)));
    } catch (e) {
      // If parsing fails, return empty map to prevent app crash
      return {};
    }
  }

  /// Save all states to SharedPreferences
  /// Serializes all states to JSON and persists to storage
  Future<void> _saveAllStates(Map<String, SubmissionState> states) async {
    try {
      final data = states.map((key, value) => MapEntry(key, value.toJson()));
      await _prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      // Queue the update for retry if save fails
      _queueStateUpdate(states);
      rethrow;
    }
  }

  /// Mark submission as having an error
  /// Preserves the state and marks it for recovery
  Future<void> markError(
    String submissionId,
    String errorMessage,
  ) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        lastError: errorMessage,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Clear error from submission
  /// Removes error marker after successful recovery
  Future<void> clearError(String submissionId) async {
    final state = getState(submissionId);
    if (state != null) {
      await saveState(state.copyWith(
        clearError: true,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Validate submission state integrity
  /// Returns true if state is valid, false if corrupted
  bool validateState(SubmissionState state) {
    try {
      // Check required fields
      if (state.submissionId.isEmpty || state.userId.isEmpty) {
        return false;
      }

      // Check timestamps are valid
      if (state.createdAt.isAfter(DateTime.now()) ||
          state.updatedAt.isBefore(state.createdAt)) {
        return false;
      }

      // Check stage-specific requirements
      switch (state.stage) {
        case SubmissionStage.videoUploaded:
          if (state.video == null || state.video!.url.isEmpty) {
            return false;
          }
          break;
        case SubmissionStage.confirmData:
          if (state.aiExtracted == null || state.aiExtracted!.isEmpty) {
            return false;
          }
          break;
        case SubmissionStage.provideInfo:
          if (state.missingFields == null || state.missingFields!.isEmpty) {
            return false;
          }
          break;
        case SubmissionStage.finalConfirm:
          if (state.allData.isEmpty) {
            return false;
          }
          break;
        default:
          break;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Detect and handle state corruption
  /// Returns list of corrupted submission IDs
  List<String> detectCorruptedStates() {
    final states = _loadAllStates();
    final corrupted = <String>[];

    for (final entry in states.entries) {
      if (!validateState(entry.value)) {
        corrupted.add(entry.key);
      }
    }

    return corrupted;
  }

  /// Remove corrupted state
  /// Clears a corrupted submission from storage
  Future<void> removeCorruptedState(String submissionId) async {
    await clearState(submissionId);
  }

  /// Queue state update for retry when network fails
  /// Stores update in memory and persists to SharedPreferences
  void _queueStateUpdate(Map<String, SubmissionState> states) {
    final update = _QueuedUpdate(
      timestamp: DateTime.now(),
      states: states,
    );
    _updateQueue.add(update);
    _persistQueue();
  }

  /// Persist update queue to SharedPreferences
  Future<void> _persistQueue() async {
    try {
      final queueData = _updateQueue.map((u) => u.toJson()).toList();
      await _prefs.setString(_queueKey, jsonEncode(queueData));
    } catch (e) {
      // If we can't persist the queue, just keep it in memory
    }
  }

  /// Load update queue from SharedPreferences
  void _loadQueue() {
    try {
      final json = _prefs.getString(_queueKey);
      if (json != null && json.isNotEmpty) {
        final List<dynamic> queueData = jsonDecode(json);
        _updateQueue.clear();
        _updateQueue.addAll(
          queueData.map((item) => _QueuedUpdate.fromJson(item)),
        );
      }
    } catch (e) {
      // If loading fails, start with empty queue
      _updateQueue.clear();
    }
  }

  /// Process queued updates
  /// Attempts to save all queued state updates
  Future<void> processQueuedUpdates() async {
    if (_updateQueue.isEmpty) {
      return;
    }

    final failedUpdates = <_QueuedUpdate>[];

    for (final update in _updateQueue) {
      try {
        await _saveAllStates(update.states);
      } catch (e) {
        // Keep failed updates in queue
        failedUpdates.add(update);
      }
    }

    _updateQueue.clear();
    _updateQueue.addAll(failedUpdates);
    await _persistQueue();
  }

  /// Get number of queued updates
  int get queuedUpdateCount => _updateQueue.length;

  /// Check if there are queued updates
  bool get hasQueuedUpdates => _updateQueue.isNotEmpty;
}

/// Internal class for queued state updates
class _QueuedUpdate {
  final DateTime timestamp;
  final Map<String, SubmissionState> states;

  _QueuedUpdate({
    required this.timestamp,
    required this.states,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'states': states.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory _QueuedUpdate.fromJson(Map<String, dynamic> json) {
    final statesData = json['states'] as Map<String, dynamic>;
    final states = statesData.map(
      (key, value) => MapEntry(
        key,
        SubmissionState.fromJson(value as Map<String, dynamic>),
      ),
    );

    return _QueuedUpdate(
      timestamp: DateTime.parse(json['timestamp'] as String),
      states: states,
    );
  }
}
