import 'package:flutter/foundation.dart';

/// Debug logger that only logs in debug mode
/// This prevents logging in production builds
class DebugLogger {
  /// Log a debug message (only in debug mode)
  static void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }
}
