import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'http_client.dart';

/// Session manager for handling user authentication sessions
///
/// This class provides a centralized way to manage user sessions
/// without duplicating the authentication logic from UserProvider.
/// It focuses on cookie/session management rather than authentication logic.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  final HttpClient _httpClient = HttpClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Factory constructor to ensure singleton pattern
  factory SessionManager() {
    return _instance;
  }

  /// Internal constructor
  SessionManager._internal();

  /// Check if a session exists by looking for stored credentials
  Future<bool> hasSession() async {
    try {
      String? username = await _storage.read(key: 'username');
      return username != null && username.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear the current session
  ///
  /// This method clears:
  /// 1. Stored credentials from secure storage
  /// 2. Cookies from the cookie jar
  /// 3. Any other session-related data
  Future<void> clearSession() async {
    try {
      // Clear credentials from secure storage
      await _storage.deleteAll();
      
      // Initialize HTTP client if needed and clear cookies
      await _httpClient.initialize();
      await _httpClient.cookieJar.deleteAll();
    } catch (e) {
      // Log error but don't throw to ensure session cleanup proceeds
      // ignore: avoid_print
      print('Error clearing session: $e');
    }
  }

  /// Get the stored username if available
  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: 'username');
    } catch (e) {
      return null;
    }
  }

  /// Get the stored password if available
  Future<String?> getPassword() async {
    try {
      return await _storage.read(key: 'password');
    } catch (e) {
      return null;
    }
  }

  /// Store credentials securely
  Future<void> storeCredentials(String username, String password) async {
    try {
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'password', value: password);
    } catch (e) {
      // Log error but don't throw to avoid breaking the auth flow
      // ignore: avoid_print
      print('Error storing credentials: $e');
    }
  }

  /// Delete stored credentials
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
    } catch (e) {
      // Log error but don't throw to ensure cleanup proceeds
      // ignore: avoid_print
      print('Error deleting credentials: $e');
    }
  }
}