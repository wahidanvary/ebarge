// No imports needed for ApiException

/// Custom exception class for API-related errors
///
/// This class provides a standardized way to handle different types
/// of API errors throughout the application.
class ApiException implements Exception {
  final String message;
  final String type;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalException,
  });

  /// Create a network timeout exception
  ApiException.networkTimeout({
    required String message,
    this.originalException,
  }) : type = 'network_timeout',
       statusCode = null,
       message = message;

  /// Create a network error exception
  ApiException.networkError({
    required String message,
    this.originalException,
  }) : type = 'network_error',
       statusCode = null,
       message = message;

  /// Create an HTTP error exception
  ApiException.httpError({
    required String message,
    this.statusCode,
    this.originalException,
  }) : type = 'http_error',
       message = message;

  /// Create an unauthorized exception
  ApiException.unauthorized({
    required String message,
    this.statusCode,
    this.originalException,
  }) : type = 'unauthorized',
       message = message;

  /// Create a cancelled request exception
  ApiException.cancelled({
    required String message,
    this.originalException,
  }) : type = 'cancelled',
       statusCode = null,
       message = message;

  /// Create an unknown exception
  ApiException.unknown({
    required String message,
    this.originalException,
  }) : type = 'unknown',
       statusCode = null,
       message = message;

  @override
  String toString() {
    return 'ApiException: $message (type: $type, statusCode: $statusCode)';
  }

  /// Check if this is a network timeout error
  bool isNetworkTimeout() => type == 'network_timeout';

  /// Check if this is a network error
  bool isNetworkError() => type == 'network_error';

  /// Check if this is an HTTP error
  bool isHttpError() => type == 'http_error';

  /// Check if this is an unauthorized error
  bool isUnauthorized() => type == 'unauthorized';

  /// Check if this is a cancelled request
  bool isCancelled() => type == 'cancelled';

  /// Check if this is an unknown error
  bool isUnknown() => type == 'unknown';
}