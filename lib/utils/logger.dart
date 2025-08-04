import 'dart:convert';
import 'package:flutter/foundation.dart';

/// App-wide logger with JSON output support.
/// - Debug/Profile: pretty (human-readable) by default, JSON optional.
/// - Release: JSON format by default (per product requirement).
/// - Provides level filtering and optional throttling for noisy logs (e.g., DEBUG).
class AppLogger {
  AppLogger._();

  /// Configure at app startup if needed.
  static bool jsonInRelease = true; // Prod: JSON format
  static bool jsonInDebug = false; // Dev: pretty by default
  static LogLevel minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug;

  /// Optional simple throttle for very chatty logs (by key).
  static final Map<String, _Throttle> _throttles = {};

  static void debug(String message, {String tag = 'DEBUG', Map<String, Object?> extra = const {}, String? throttleKey, Duration throttle = const Duration(milliseconds: 300)}) {
    _log(LogLevel.debug, message, tag: tag, extra: extra, throttleKey: throttleKey, throttle: throttle);
  }

  static void info(String message, {String tag = 'INFO', Map<String, Object?> extra = const {}}) {
    _log(LogLevel.info, message, tag: tag, extra: extra);
  }

  static void warn(String message, {String tag = 'WARN', Map<String, Object?> extra = const {}}) {
    _log(LogLevel.warn, message, tag: tag, extra: extra);
  }

  static void error(String message, {String tag = 'ERROR', Map<String, Object?> extra = const {}}) {
    _log(LogLevel.error, message, tag: tag, extra: extra);
  }

  static void _log(LogLevel level, String message, {required String tag, required Map<String, Object?> extra, String? throttleKey, Duration? throttle}) {
    if (level.index < minLevel.index) return;

    // Throttle only for debug-level logs to reduce noise
    if (level == LogLevel.debug && throttleKey != null && throttle != null) {
      final now = DateTime.now();
      final t = _throttles[throttleKey];
      if (t != null && now.difference(t.last) < throttle) {
        return;
      }
      _throttles[throttleKey] = _Throttle(now);
    }

    final record = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name.toUpperCase(),
      'tag': tag,
      'message': message,
      if (extra.isNotEmpty) 'extra': extra,
      if (!kReleaseMode) 'mode': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
    };

    final useJson = kReleaseMode ? jsonInRelease : jsonInDebug;
    final output = useJson ? jsonEncode(record) : '[${record['level']}] ${record['tag']}: ${record['message']}'
        '${record.containsKey('extra') ? ' | extra=${jsonEncode(record['extra'])}' : ''}';

    // ignore: avoid_print
    print(output);
  }
}

enum LogLevel { debug, info, warn, error }

class _Throttle {
  _Throttle(this.last);
  DateTime last;
}
