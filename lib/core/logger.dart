import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Structured logging service for the application.
/// Provides consistent logging format with context and severity levels.
class AppLogger {
  AppLogger._();

  static const String _appName = 'LuxeDining';

  /// Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;

  /// Format log message with timestamp and context
  static String _formatMessage(
    String level,
    String message, {
    Map<String, dynamic>? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.write('[$timestamp] [$level] $message');
    if (context != null && context.isNotEmpty) {
      buffer.write(' | Context: $context');
    }
    return buffer.toString();
  }

  /// Debug level logging - only in debug mode
  static void debug(String message, {Map<String, dynamic>? context}) {
    if (!kDebugMode) return;
    final formatted = _formatMessage('DEBUG', message, context: context);
    developer.log(formatted, name: _appName, level: _levelDebug);
  }

  /// Info level logging
  static void info(String message, {Map<String, dynamic>? context}) {
    final formatted = _formatMessage('INFO', message, context: context);
    developer.log(formatted, name: _appName, level: _levelInfo);
  }

  /// Warning level logging
  static void warning(String message, {Map<String, dynamic>? context}) {
    final formatted = _formatMessage('WARNING', message, context: context);
    developer.log(formatted, name: _appName, level: _levelWarning);
  }

  /// Error level logging with optional exception and stack trace
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final formatted = _formatMessage('ERROR', message, context: context);
    developer.log(
      formatted,
      name: _appName,
      level: _levelError,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a user action for analytics/debugging
  static void userAction(
    String action, {
    String? screen,
    Map<String, dynamic>? details,
  }) {
    final ctx = <String, dynamic>{
      if (screen != null) 'screen': screen,
      if (details != null) ...details,
    };
    info('User Action: $action', context: ctx);
  }

  /// Log an API/network call
  static void network(
    String endpoint, {
    String method = 'GET',
    int? statusCode,
    String? error,
  }) {
    final ctx = <String, dynamic>{
      'method': method,
      if (statusCode != null) 'status': statusCode,
    };
    if (error != null) {
      AppLogger.error('Network Error: $endpoint', context: ctx);
    } else {
      debug('Network: $endpoint', context: ctx);
    }
  }

  /// Log booking-related events
  static void booking(
    String event, {
    String? bookingId,
    String? packageName,
    int? guestCount,
    DateTime? eventDate,
  }) {
    final ctx = <String, dynamic>{
      if (bookingId != null) 'bookingId': bookingId,
      if (packageName != null) 'package': packageName,
      if (guestCount != null) 'guests': guestCount,
      if (eventDate != null) 'date': eventDate.toIso8601String(),
    };
    info('Booking: $event', context: ctx);
  }

  /// Log authentication events
  static void auth(String event, {String? userId, String? email}) {
    final ctx = <String, dynamic>{
      if (userId != null) 'userId': userId,
      if (email != null) 'email': _maskEmail(email),
    };
    info('Auth: $event', context: ctx);
  }

  /// Mask email for privacy in logs
  static String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    if (name.length <= 2) return '***@${parts[1]}';
    return '${name.substring(0, 2)}***@${parts[1]}';
  }
}
