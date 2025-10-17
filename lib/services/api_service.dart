import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

/// API Service for handling HTTP requests
/// Singleton pattern for consistent API client across the app
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication token if available
    final token = await AuthService().getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// POST request with JSON body
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${AppConfig.apiUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.apiUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request with SSE streaming response
  Stream<String> streamPost(String endpoint, Map<String, dynamic> body) async* {
    try {
      final url = Uri.parse('${AppConfig.apiUrl}$endpoint');
      final headers = await _getHeaders();

      print('🚀 [ApiService] Starting stream request to: $url');
      print('📤 [ApiService] Request body: ${jsonEncode(body)}');

      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: AppConfig.requestTimeout));

      print('📡 [ApiService] Response status: ${streamedResponse.statusCode}');
      print('📋 [ApiService] Response headers: ${streamedResponse.headers}');

      if (streamedResponse.statusCode != 200) {
        throw ApiException(
          'Request failed with status: ${streamedResponse.statusCode}',
          streamedResponse.statusCode,
        );
      }

      int chunkCount = 0;
      int dataLineCount = 0;
      String buffer = ''; // Buffer for incomplete lines

      // Parse SSE stream
      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        chunkCount++;
        print(
            '�  [ApiService] Chunk #$chunkCount received (${chunk.length} bytes)');

        // Add chunk to buffer
        buffer += chunk;

        // Process complete lines (ending with \n)
        final lines = buffer.split('\n');

        // Keep the last incomplete line in buffer
        buffer = lines.last;

        // Process all complete lines (all except the last)
        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i];

          if (line.startsWith('data: ')) {
            dataLineCount++;
            final data = line.substring(6).trim();

            if (data.isNotEmpty && data != '[DONE]') {
              print(
                  '✅ [ApiService] Data line #$dataLineCount: ${data.length > 100 ? data.substring(0, 100) + "..." : data}');
              yield data;
            } else if (data == '[DONE]') {
              print('🏁 [ApiService] Stream completed with [DONE] marker');
            }
          } else if (line.trim().isNotEmpty && !line.startsWith(':')) {
            // Continuation of previous data line (multi-line JSON)
            // This happens when large JSON spans multiple chunks
            print('📎 [ApiService] Continuation line (${line.length} bytes)');
          }
        }
      }

      // Process any remaining data in buffer
      if (buffer.trim().isNotEmpty && buffer.startsWith('data: ')) {
        final data = buffer.substring(6).trim();
        if (data.isNotEmpty && data != '[DONE]') {
          dataLineCount++;
          print(
              '✅ [ApiService] Final data line #$dataLineCount: ${data.length > 100 ? data.substring(0, 100) + "..." : data}');
          yield data;
        }
      }

      print(
          '🎉 [ApiService] Stream finished. Total chunks: $chunkCount, Data lines: $dataLineCount');
    } catch (e) {
      print('❌ [ApiService] Stream error: $e');
      throw _handleError(e);
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw AuthException('Unauthorized - please sign in again');
    } else if (response.statusCode == 307 || response.statusCode == 308) {
      // Handle redirects - extract the redirect location
      final location = response.headers['location'] ?? 'unknown';
      throw ApiException(
        'Request redirected (${response.statusCode}). Server wants to redirect to: $location. '
        'Check if your API URL needs a trailing slash or different path.',
        response.statusCode,
      );
    } else if (response.statusCode == 400) {
      throw ApiException(
        'Bad request: ${response.body}',
        response.statusCode,
      );
    } else if (response.statusCode >= 500) {
      throw ApiException(
        'Server error: ${response.statusCode}',
        response.statusCode,
      );
    } else {
      throw ApiException(
        'Request failed: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return NetworkException('Request timeout - please check your connection');
    } else if (error is ApiException || error is AuthException) {
      return error as Exception;
    } else {
      return NetworkException('Network error: ${error.toString()}');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}
