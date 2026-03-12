import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String scope, String message) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    debugPrint('[$scope][$ts][INFO] $message');
  }

  static void error(
    String scope,
    Object error, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    final ctx = context == null ? '' : '[$context]';
    debugPrint('[$scope][$ts][ERROR]$ctx $error');
    if (stackTrace != null) {
      debugPrint('[$scope][$ts][STACK] $stackTrace');
    }
  }
}
