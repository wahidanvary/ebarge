import 'package:flutter_test/flutter_test.dart';
import 'package:ebarge/services/network/api_exception.dart';
import 'package:dio/dio.dart';

void main() {
  group('ApiException', () {
    test('should create network timeout exception', () {
      final exception = ApiException.networkTimeout(
        message: 'Connection timed out',
      );

      expect(exception.message, 'Connection timed out');
      expect(exception.type, 'network_timeout');
      expect(exception.statusCode, isNull);
      expect(exception.isNetworkTimeout(), isTrue);
    });

    test('should create network error exception', () {
      final exception = ApiException.networkError(
        message: 'No internet connection',
      );

      expect(exception.message, 'No internet connection');
      expect(exception.type, 'network_error');
      expect(exception.statusCode, isNull);
      expect(exception.isNetworkError(), isTrue);
    });

    test('should create HTTP error exception', () {
      final exception = ApiException.httpError(
        message: 'Bad request',
        statusCode: 400,
      );

      expect(exception.message, 'Bad request');
      expect(exception.type, 'http_error');
      expect(exception.statusCode, 400);
      expect(exception.isHttpError(), isTrue);
    });

    test('should create unauthorized exception', () {
      final exception = ApiException.unauthorized(
        message: 'Invalid credentials',
        statusCode: 401,
      );

      expect(exception.message, 'Invalid credentials');
      expect(exception.type, 'unauthorized');
      expect(exception.statusCode, 401);
      expect(exception.isUnauthorized(), isTrue);
    });

    test('should create cancelled exception', () {
      final exception = ApiException.cancelled(
        message: 'Request cancelled',
      );

      expect(exception.message, 'Request cancelled');
      expect(exception.type, 'cancelled');
      expect(exception.statusCode, isNull);
      expect(exception.isCancelled(), isTrue);
    });

    test('should create unknown exception', () {
      final exception = ApiException.unknown(
        message: 'Something went wrong',
      );

      expect(exception.message, 'Something went wrong');
      expect(exception.type, 'unknown');
      expect(exception.statusCode, isNull);
      expect(exception.isUnknown(), isTrue);
    });

    test('should include original exception when provided', () {
      final original = DioException(requestOptions: RequestOptions());
      final exception = ApiException.unknown(
        message: 'Something went wrong',
        originalException: original,
      );

      expect(exception.originalException, original);
    });

    test('should return string representation', () {
      final exception = ApiException.httpError(
        message: 'Bad request',
        statusCode: 400,
      );

      expect(
        exception.toString(),
        'ApiException: Bad request (type: http_error, statusCode: 400)',
      );
    });
  });
}