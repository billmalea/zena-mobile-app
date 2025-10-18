/// Message model for chat messages
/// Represents both user and assistant messages with optional tool results
class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ToolResult>? toolResults;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.role,
    required this.content,
    this.toolResults,
    required this.createdAt,
    this.metadata,
  });

  /// Check if message is from user
  bool get isUser => role == 'user';

  /// Check if message has tool results
  bool get hasToolResults => toolResults != null && toolResults!.isNotEmpty;

  /// Get submission ID from metadata
  String? get submissionId => metadata?['submissionId'] as String?;

  /// Get workflow stage from metadata
  String? get workflowStage => metadata?['workflowStage'] as String?;

  /// Check if message is part of a workflow
  bool get isPartOfWorkflow => submissionId != null;

  /// Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      toolResults: json['toolResults'] != null
          ? (json['toolResults'] as List)
              .map((tr) => ToolResult.fromJson(tr as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'toolResults': toolResults?.map((tr) => tr.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? role,
    String? content,
    List<ToolResult>? toolResults,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      toolResults: toolResults ?? this.toolResults,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Tool result from AI assistant tool calls
class ToolResult {
  final String toolName;
  final Map<String, dynamic> result;

  ToolResult({
    required this.toolName,
    required this.result,
  });

  /// Create ToolResult from JSON
  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolName: json['toolName'] as String,
      result: json['result'] as Map<String, dynamic>,
    );
  }

  /// Convert ToolResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'toolName': toolName,
      'result': result,
    };
  }
}
