import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'api_exception.dart';

/// Centralized HTTP client for Ebarge application
///
/// This class provides a single, centralized Dio instance with proper
/// cookie management and error handling. It replaces the scattered
/// Dio/PersistCookieJar pattern found throughout the codebase.
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late Dio _dio;
  late PersistCookieJar _cookieJar;
  bool _initialized = false;

  /// Factory constructor to ensure singleton pattern
  factory HttpClient() {
    return _instance;
  }

  /// Internal constructor to initialize the HTTP client
  HttpClient._internal();

  /// Initialize the HTTP client with proper configuration
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Create Dio instance with base configuration
    _dio = Dio(BaseOptions(
      baseUrl: 'https://ebarge.ir',
      connectTimeout: const Duration(milliseconds: 18000),
      receiveTimeout: const Duration(milliseconds: 15000),
      receiveDataWhenStatusError: true,
    ));

    // Initialize cookie jar with proper storage path
    await _initCookieJar();

    // Attach cookie manager interceptor
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    _initialized = true;
  }

  /// Initialize the persistent cookie jar
  Future<void> _initCookieJar() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage('$appDocPath/.cookies/'),
      );
    } catch (e) {
      // In test environments or when path provider fails, use memory storage
      _cookieJar = PersistCookieJar();
    }
  }

  /// Ensure the client is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Get the underlying Dio instance (for advanced use cases)
  Dio get dio {
    if (!_initialized) {
      throw StateError('HttpClient not initialized. Call initialize() first.');
    }
    return _dio;
  }

  /// Get the cookie jar instance
  PersistCookieJar get cookieJar {
    if (!_initialized) {
      throw StateError('HttpClient not initialized. Call initialize() first.');
    }
    return _cookieJar;
  }

  /// Perform a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Perform a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Perform a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Perform a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _ensureInitialized();
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Map DioException to ApiException
  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.networkTimeout(
          message: e.message ?? 'Network timeout occurred',
          originalException: e,
        );
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return ApiException.unauthorized(
            message: 'Unauthorized access',
            statusCode: e.response?.statusCode,
            originalException: e,
          );
        }
        return ApiException.httpError(
          message: e.message ?? 'HTTP error occurred',
          statusCode: e.response?.statusCode,
          originalException: e,
        );
      case DioExceptionType.cancel:
        return ApiException.cancelled(
          message: 'Request was cancelled',
          originalException: e,
        );
      case DioExceptionType.unknown:
        return ApiException.networkError(
          message: e.message ?? 'Unknown network error',
          originalException: e,
        );
      default:
        return ApiException.unknown(
          message: e.message ?? 'An unknown error occurred',
          originalException: e,
        );
    }
  }
}