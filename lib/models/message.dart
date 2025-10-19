/// Message model for chat messages
/// Represents both user and assistant messages with optional tool results
class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ActiveToolCall>? activeToolCalls;  // Currently running tools
  final List<ToolResult>? toolResults;          // Completed tools
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final bool synced;
  final bool localOnly;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.role,
    required this.content,
    this.activeToolCalls,
    this.toolResults,
    required this.createdAt,
    this.metadata,
    this.synced = false,
    this.localOnly = false,
    this.updatedAt,
  });

  /// Check if message is from user
  bool get isUser => role == 'user';

  /// Check if message has active tool calls
  bool get hasActiveToolCalls => activeToolCalls != null && activeToolCalls!.isNotEmpty;

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
    // Tool results can be at top level (from streaming) or in metadata (from database)
    List<ToolResult>? toolResults;
    
    if (json['toolResults'] != null) {
      // Top-level toolResults (from streaming)
      toolResults = (json['toolResults'] as List)
          .map((tr) => ToolResult.fromJson(tr as Map<String, dynamic>))
          .toList();
    } else if (json['metadata'] != null) {
      // Check for toolResults in metadata (from database)
      final metadata = json['metadata'] as Map<String, dynamic>;
      if (metadata['toolResults'] != null) {
        toolResults = (metadata['toolResults'] as List)
            .map((tr) => ToolResult.fromJson(tr as Map<String, dynamic>))
            .toList();
      }
    }
    
    // Active tool calls (only from streaming, not persisted)
    List<ActiveToolCall>? activeToolCalls;
    if (json['activeToolCalls'] != null) {
      activeToolCalls = (json['activeToolCalls'] as List)
          .map((tc) => ActiveToolCall.fromJson(tc as Map<String, dynamic>))
          .toList();
    }
    
    return Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      activeToolCalls: activeToolCalls,
      toolResults: toolResults,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      synced: json['synced'] as bool? ?? false,
      localOnly: json['localOnly'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      if (activeToolCalls != null)
        'activeToolCalls': activeToolCalls!.map((tc) => tc.toJson()).toList(),
      'toolResults': toolResults?.map((tr) => tr.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'synced': synced,
      'localOnly': localOnly,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? role,
    String? content,
    List<ActiveToolCall>? activeToolCalls,
    List<ToolResult>? toolResults,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    bool? synced,
    bool? localOnly,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      activeToolCalls: activeToolCalls ?? this.activeToolCalls,
      toolResults: toolResults ?? this.toolResults,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      synced: synced ?? this.synced,
      localOnly: localOnly ?? this.localOnly,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Active Tool Call (currently running tool)
class ActiveToolCall {
  final String name;
  final String id;
  final String state;  // 'input-streaming' | 'input-available'

  ActiveToolCall({
    required this.name,
    required this.id,
    required this.state,
  });

  /// Create ActiveToolCall from JSON
  factory ActiveToolCall.fromJson(Map<String, dynamic> json) {
    return ActiveToolCall(
      name: json['name'] as String,
      id: json['id'] as String,
      state: json['state'] as String,
    );
  }

  /// Convert ActiveToolCall to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'state': state,
    };
  }
}

/// Tool result from AI assistant tool calls
class ToolResult {
  final String toolName;
  final Map<String, dynamic> result;
  final String state;  // 'success' | 'error'

  ToolResult({
    required this.toolName,
    required this.result,
    this.state = 'success',
  });

  /// Check if this is an error result
  bool get isError => state == 'error';

  /// Check if this is a success result
  bool get isSuccess => state == 'success';

  /// Create ToolResult from JSON
  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolName: json['toolName'] as String,
      result: json['result'] as Map<String, dynamic>,
      state: json['state'] as String? ?? 'success',
    );
  }

  /// Convert ToolResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'toolName': toolName,
      'result': result,
      'state': state,
    };
  }
}
