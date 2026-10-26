// 职责: 全局日志入口 — 静态便捷方法与模块作用域日志，统一路由到 LogManager 文件输出
// 关联文件:
//   lib/shared/logger/log_manager.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'log_manager.dart';

/// 全局日志入口。
///
/// - 一次性日志：直接用 `AppLogger.info/warning/error`。
/// - 模块日志：在文件顶部声明 `final _log = AppLogger.forModule('ModuleName');`，
///   后续用 `_log.info/debug/warning/error`，自动添加 `[ModuleName]` 前缀。
///
/// 所有日志在 LogManager 初始化后写入文件；初始化前 fallback 到 debugPrint。
class AppLogger {
  static final _aiTraceContextKey = Object();

  /// Carries local diagnostic IDs through async image callbacks, not HTTP headers.
  static T withAiTraceContext<T>(
    Map<String, Object?> context,
    T Function() action,
  ) => runZoned(
    action,
    zoneValues: {
      _aiTraceContextKey: {
        ...?Zone.current[_aiTraceContextKey] as Map<String, Object?>?,
        ...context,
      },
    },
  );

  // ---------------------------------------------------------------------------
  // 静态便捷 API（无 tag，适用于一次性日志）
  // ---------------------------------------------------------------------------

  static void trace(String message) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.trace(message);
    } else {
      debugPrint('[TRACE] $message');
    }
  }

  static void debug(String message) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.debug(message);
    } else {
      debugPrint('[DEBUG] $message');
    }
  }

  static void info(String message, {Map<String, dynamic>? extra}) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.info(message, extra: extra);
    } else {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.warning(message);
    } else {
      debugPrint('[WARN] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.error(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// 崩溃诊断检查点 — 立即落盘（内部以 warning 级别写入）。
  /// 仅用于原生崩溃高发路径（窗口生命周期、退出流程），禁止高频调用。
  static void checkpoint(String message) {
    if (LogManager.instance.isInitialized) {
      LogManager.instance.checkpoint(message);
    } else {
      debugPrint('[CHECKPOINT] $message');
    }
  }

  /// 当前日志级别（仅初始化后有效）。
  static Level? get currentLevel => LogManager.instance.isInitialized
      ? LogManager.instance.currentLevel
      : null;

  /// 设置日志级别，即时生效。
  static void setLogLevel(Level level) {
    LogManager.instance.setLogLevel(level);
  }

  // ---------------------------------------------------------------------------
  // 模块作用域日志
  // ---------------------------------------------------------------------------

  /// 创建一个带 `[module]` 前缀的模块日志器。
  /// 建议在文件顶部声明为 `final _log = AppLogger.forModule('Xxx');`。
  static ModuleLogger forModule(String module) => ModuleLogger(module);

  AppLogger._();
}

/// 模块作用域日志器，自动为每条日志添加 `[module]` 前缀。
class ModuleLogger {
  final String _tag;
  const ModuleLogger(this._tag);

  void trace(String message) => AppLogger.trace('[$_tag] $message');
  void debug(String message) => AppLogger.debug('[$_tag] $message');
  void info(String message, {Map<String, dynamic>? extra}) =>
      AppLogger.info('[$_tag] $message', extra: extra);
  void warning(String message) => AppLogger.warning('[$_tag] $message');
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.error('[$_tag] $message', error: error, stackTrace: stackTrace);
  void checkpoint(String message) => AppLogger.checkpoint('[$_tag] $message');

  /// Full local AI diagnostics are on in Debug builds, never in Release.
  bool get aiTraceEnabled => kDebugMode;

  /// Keep text complete; split long records so terminal line limits do not hide
  /// prompts/results. This writes locally only, not to anonymous telemetry.
  void aiTrace(
    String stage,
    Object? payload, {
    List<String> secrets = const [],
  }) {
    if (!aiTraceEnabled) {
      return;
    }
    try {
      final context = Zone.current[AppLogger._aiTraceContextKey];
      final contextLabel = context == null
          ? ''
          : ' context=${jsonEncode(context)}';
      var text = jsonEncode(_aiTraceValue(payload), toEncodable: (v) => '$v');
      for (final secret in secrets) {
        if (secret.isNotEmpty) {
          final encoded = jsonEncode(secret);
          text = text.replaceAll(
            encoded.substring(1, encoded.length - 1),
            '[REDACTED]',
          );
        }
      }
      const chunkSize = 2000;
      final chunks = <String>[];
      for (var offset = 0; offset < text.length;) {
        var end = offset + chunkSize < text.length
            ? offset + chunkSize
            : text.length;
        if (end < text.length &&
            text.codeUnitAt(end - 1) >= 0xd800 &&
            text.codeUnitAt(end - 1) <= 0xdbff) {
          end -= 1;
        }
        chunks.add(text.substring(offset, end));
        offset = end;
      }
      for (var index = 0; index < chunks.length; index++) {
        info(
          '[AIFLOW] $stage$contextLabel part=${index + 1}/${chunks.length} ${chunks[index]}',
        );
      }
    } catch (error) {
      // Diagnostic serialization must not change the request/tool outcome.
      warning(
        '[AIFLOW] $stage diagnostic_serialization_failed type=${error.runtimeType}',
      );
    }
  }
}

final _credentialKey = RegExp(
  r'^(authorization|proxyauthorization|apikey|password|proxypassword|accesstoken|refreshtoken|idtoken|token|secret|clientsecret|cookie|setcookie)$',
);
final _dataUri = RegExp(r'data:[^\s"<>]*?;base64,[A-Za-z0-9+/=_-]+');
final _bearer = RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false);
final _credentialText = RegExp(
  r'''((?:api[_-]?key|access[_-]?token|refresh[_-]?token|password|signature|x-amz-signature)["']?\s*[:=]\s*["']?)[^\s"'&,;}]+''',
  caseSensitive: false,
);

Object? _aiTraceValue(Object? value) {
  if (value is Uint8List) {
    return '[binary bytes=${value.length}]';
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        '${entry.key}':
            _credentialKey.hasMatch(
              '${entry.key}'.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), ''),
            )
            ? '[REDACTED]'
            : const {'b64_json', 'imageBase64', 'base64'}.contains(entry.key) ||
                  (entry.key == 'data' &&
                      (value.containsKey('mimeType') ||
                          value['type'] == 'base64'))
            ? '[binary chars=${entry.value is String ? (entry.value as String).length : 0}]'
            : _aiTraceValue(entry.value),
    };
  }
  if (value is Iterable) {
    return value.map(_aiTraceValue).toList();
  }
  if (value is String) {
    final trimmed = value.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return _aiTraceValue(jsonDecode(value));
      } on FormatException {
        // Tool text and partial SSE are not necessarily complete JSON.
      }
    }
    return value
        .replaceAllMapped(_dataUri, (m) => '[data URI chars=${m[0]!.length}]')
        .replaceAll(_bearer, 'Bearer [REDACTED]')
        .replaceAllMapped(_credentialText, (m) => '${m[1]}[REDACTED]');
  }
  return value;
}
