# Security Architecture in Ebarge

## Overview

This document describes the current security implementation in the Ebarge application. It identifies confirmed security risks and provides recommendations for remediation.

## Confirmed Security Risks

### 1. SSL Certificate Validation Bypass

#### Current Implementation
```dart
/// ✅ نادیده‌گرفتن گواهی SSL برای دامنه‌های داخلی یا تستی
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
```

#### Why It's Risky
This implementation bypasses all SSL certificate validation, accepting any certificate regardless of its validity. This makes the application vulnerable to man-in-the-middle attacks in production environments.

#### Confirmed From Source Code
✅ Confirmed in `lib/main.dart`

#### Recommended Remediation
1. Remove the SSL certificate bypass for production builds
2. Use environment-specific configurations to enable bypass only in development
3. Implement proper certificate pinning for critical API endpoints

#### Architectural Changes Required
- Environment-specific configuration management
- Conditional SSL validation based on build mode

### 2. Credential Storage

#### Current Implementation
Credentials are stored using `FlutterSecureStorage`:
```dart
final storage = new FlutterSecureStorage();
await storage.write(key: "username", value: _user!.username);
await storage.write(key: "password", value: password);
```

#### Why It's Risky
While `FlutterSecureStorage` provides secure storage, storing passwords in plaintext is still a security concern. The implementation also lacks proper key management.

#### Confirmed From Source Code
✅ Confirmed in `lib/providers/userProvider.dart`

#### Recommended Remediation
1. Store only authentication tokens, not passwords
2. Implement token refresh mechanisms
3. Use biometric authentication where available
4. Implement proper session management with expiration

#### Architectural Changes Required
- Token-based authentication system
- Session management with automatic refresh

### 3. API Authentication

#### Current Implementation
Session-based authentication using cookies:
```dart
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath + "/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

#### Why It's Risky
Multiple cookie jars are created across different API calls, potentially leading to session inconsistency. There's no CSRF protection implemented.

#### Confirmed From Source Code
✅ Confirmed in multiple files with 30+ instances of cookie jar creation

#### Recommended Remediation
1. Centralize cookie management with a single cookie jar
2. Implement CSRF protection tokens
3. Add session validation and refresh mechanisms
4. Implement proper logout across all sessions

#### Architectural Changes Required
- Centralized authentication service
- Session management layer

### 4. Input Validation

#### Current Implementation
Limited input validation, primarily in form fields:
```dart
validator: (value) => value == null || value.isEmpty ? 'نام کاربری را وارد کنید' : null,
```

#### Why It's Risky
Basic validation only checks for empty values. No sanitization or security-focused validation is performed on user inputs that may be sent to APIs.

#### Confirmed From Source Code
✅ Confirmed in `lib/screens/login/loginForm.dart` and other UI components

#### Recommended Remediation
1. Implement comprehensive input validation for all user inputs
2. Add sanitization for special characters
3. Implement length and format validation
4. Add server-side validation mirroring client-side checks

#### Architectural Changes Required
- Input validation layer
- Sanitization utilities

### 5. Cookie/Session Management

#### Current Implementation
Multiple Dio instances with separate cookie jars:
```dart
// This pattern is repeated ~30 times across the codebase
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath+"/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

#### Why It's Risky
Having multiple cookie jars can lead to session inconsistency where some API calls have valid sessions while others don't. Cookie storage is not properly synchronized.

#### Confirmed From Source Code
✅ Confirmed with 30+ instances across providers and services

#### Recommended Remediation
1. Create a centralized HTTP client with a single cookie jar
2. Implement proper session synchronization
3. Add session expiration and refresh mechanisms
4. Ensure consistent authentication state across all API calls

#### Architectural Changes Required
- Centralized HTTP client service
- Unified authentication and session management

### 6. HTTPS/Network Security

#### Current Implementation
HTTPS is used for production but can be bypassed:
```dart
static final ebargeUrl = 'https://ebarge.ir';
```

#### Why It's Risky
While HTTPS is used, the SSL certificate bypass undermines the security benefits. Network requests lack additional security measures like request signing or encryption.

#### Confirmed From Source Code
✅ Confirmed in `lib/services/GlobalKeys.dart`

#### Recommended Remediation
1. Remove SSL certificate bypass in production
2. Implement request signing for critical operations
3. Add network security configuration
4. Monitor and log security-related network events

#### Architectural Changes Required
- Environment-specific security configurations
- Request signing infrastructure

### 7. Payment Security

#### Current Implementation
Payment logic is implemented directly in UI layer:
```dart
// In lib/screens/books/goldShop.dart
purchaseProduct(
    String productId,
    int goldAmount,
    String payload,
    String? dynamicPriceToken,
) async {
    // Payment processing logic in UI component
}
```

#### Why It's Risky
Payment processing in the UI layer lacks proper security controls. There's no server-side verification of purchases, making the system vulnerable to manipulation.

#### Confirmed From Source Code
✅ Confirmed in `lib/screens/books/goldShop.dart`

#### Recommended Remediation
1. Move payment logic to a dedicated service layer
2. Implement server-side purchase verification
3. Add receipt validation
4. Implement proper error handling for payment failures

#### Architectural Changes Required
- Dedicated payment service layer
- Server-side verification mechanisms

## Security Recommendations Summary

1. **Immediate**: Remove SSL certificate bypass for production builds
2. **Short-term**: Centralize HTTP client and authentication management
3. **Medium-term**: Implement comprehensive input validation and sanitization
4. **Long-term**: Add advanced security features like certificate pinning and request signing

## Compliance Considerations

The current implementation may not meet security standards required for:
- Financial transactions (payment system)
- User data protection (credential storage)
- Network security (SSL validation)

Addressing the identified risks is essential for maintaining user trust and meeting regulatory requirements.