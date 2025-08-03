import 'package:flutter/foundation.dart';

/// Lightweight logger to replace print calls and satisfy avoid_print lint.
/// In debug/profile (non-release) it prints to console. In release it is silent by default.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[$tag] $message');
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[$tag] $message');
    }
  }

  static void warn(String message, {String tag = 'WARN'}) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[$tag] $message');
    }
  }

  static void error(String message, {String tag = 'ERROR'}) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('[$tag] $message');
    }
  }
}
