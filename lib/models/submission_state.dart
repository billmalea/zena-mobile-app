/// Submission state model for tracking multi-turn property submission workflows
/// Maintains state across multiple user messages and AI responses

/// Enum representing the stages of property submission workflow
enum SubmissionStage {
  start,
  videoUploaded,
  confirmData,
  provideInfo,
  finalConfirm,
}

/// Video data model for storing video information
class VideoData {
  final String url;
  final String? publicUrl;
  final Map<String, dynamic>? analysisResults;
  final int? duration;
  final String? quality;

  VideoData({
    required this.url,
    this.publicUrl,
    this.analysisResults,
    this.duration,
    this.quality,
  });

  /// Create VideoData from JSON
  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      url: json['url'] as String,
      publicUrl: json['publicUrl'] as String?,
      analysisResults: json['analysisResults'] as Map<String, dynamic>?,
      duration: json['duration'] as int?,
      quality: json['quality'] as String?,
    );
  }

  /// Convert VideoData to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicUrl': publicUrl,
      'analysisResults': analysisResults,
      'duration': duration,
      'quality': quality,
    };
  }

  /// Create a copy with updated fields
  VideoData copyWith({
    String? url,
    String? publicUrl,
    Map<String, dynamic>? analysisResults,
    int? duration,
    String? quality,
  }) {
    return VideoData(
      url: url ?? this.url,
      publicUrl: publicUrl ?? this.publicUrl,
      analysisResults: analysisResults ?? this.analysisResults,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
    );
  }
}

/// Submission state model for tracking property submission workflow
class SubmissionState {
  final String submissionId;
  final String userId;
  final SubmissionStage stage;
  final VideoData? video;
  final Map<String, dynamic>? aiExtracted;
  final Map<String, dynamic>? userProvided;
  final List<String>? missingFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastError;

  SubmissionState({
    required this.submissionId,
    required this.userId,
    required this.stage,
    this.video,
    this.aiExtracted,
    this.userProvided,
    this.missingFields,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });

  /// Calculate progress based on current stage (0.0 to 1.0)
  double get progress {
    final stageIndex = SubmissionStage.values.indexOf(stage);
    final totalStages = SubmissionStage.values.length;
    return (stageIndex + 1) / totalStages;
  }

  /// Check if submission is complete
  bool get isComplete => stage == SubmissionStage.finalConfirm;

  /// Check if submission has an error
  bool get hasError => lastError != null && lastError!.isNotEmpty;

  /// Get all data (merged AI extracted and user provided)
  Map<String, dynamic> get allData {
    return {
      ...?aiExtracted,
      ...?userProvided,
    };
  }

  /// Create SubmissionState from JSON
  factory SubmissionState.fromJson(Map<String, dynamic> json) {
    return SubmissionState(
      submissionId: json['submissionId'] as String,
      userId: json['userId'] as String,
      stage: SubmissionStage.values.firstWhere(
        (e) => e.toString() == 'SubmissionStage.${json['stage']}',
        orElse: () => SubmissionStage.start,
      ),
      video: json['video'] != null
          ? VideoData.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      aiExtracted: json['aiExtracted'] as Map<String, dynamic>?,
      userProvided: json['userProvided'] as Map<String, dynamic>?,
      missingFields: json['missingFields'] != null
          ? (json['missingFields'] as List).cast<String>()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastError: json['lastError'] as String?,
    );
  }

  /// Convert SubmissionState to JSON
  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'userId': userId,
      'stage': stage.toString().split('.').last,
      'video': video?.toJson(),
      'aiExtracted': aiExtracted,
      'userProvided': userProvided,
      'missingFields': missingFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastError': lastError,
    };
  }

  /// Create a copy with updated fields
  /// Use clearError: true to explicitly clear the lastError field
  SubmissionState copyWith({
    String? submissionId,
    String? userId,
    SubmissionStage? stage,
    VideoData? video,
    Map<String, dynamic>? aiExtracted,
    Map<String, dynamic>? userProvided,
    List<String>? missingFields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastError,
    bool clearError = false,
  }) {
    return SubmissionState(
      submissionId: submissionId ?? this.submissionId,
      userId: userId ?? this.userId,
      stage: stage ?? this.stage,
      video: video ?? this.video,
      aiExtracted: aiExtracted ?? this.aiExtracted,
      userProvided: userProvided ?? this.userProvided,
      missingFields: missingFields ?? this.missingFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
