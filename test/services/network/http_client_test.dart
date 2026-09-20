import 'package:flutter_test/flutter_test.dart';
import 'package:ebarge/services/network/http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('HttpClient', () {
    late HttpClient httpClient;

    setUp(() async {
      // Initialize bindings for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      // Get the singleton instance
      httpClient = HttpClient();
      // Initialize the client
      await httpClient.initialize();
    });

    test('should be a singleton', () {
      final client1 = HttpClient();
      final client2 = HttpClient();
      
      expect(client1, same(client2));
    });

    test('should have proper base configuration', () {
      expect(httpClient.dio.options.baseUrl, 'https://ebarge.ir');
      expect(httpClient.dio.options.connectTimeout, const Duration(milliseconds: 18000));
      expect(httpClient.dio.options.receiveTimeout, const Duration(milliseconds: 15000));
    });

    test('should have cookie jar attached', () {
      expect(httpClient.cookieJar, isNotNull);
    });

    test('should expose dio instance', () {
      expect(httpClient.dio, isNotNull);
      expect(httpClient.dio, TypeMatcher<Dio>());
    });
  });
}