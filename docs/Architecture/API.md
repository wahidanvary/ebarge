# API Architecture in Ebarge

## Overview

Ebarge communicates with a backend API through HTTP requests. The API follows a REST-like pattern with specific endpoints for different functionalities. Communication is handled through the Dio HTTP client with cookie-based session management.

## Network Layer Architecture

### HTTP Client Configuration

```dart
// GlobalKeys.dart
static final BaseOptions options = new BaseOptions(
  baseUrl: ebargeUrl,
  receiveDataWhenStatusError: true,
  connectTimeout: Duration(milliseconds: 18000),
  receiveTimeout: Duration(milliseconds: 15000),
);
```

### Cookie Management

- Persistent cookie storage using `cookie_jar` and `dio_cookie_manager`
- Cookies stored in application documents directory
- Automatic cookie handling for session persistence
- ⚠️ Multiple cookie jars created per API call (technical debt issue)

## API Endpoints

### Base URL
- Production: `https://ebarge.ir`
- Development: Various local IPs (commented in code)

### Endpoint Pattern
```
https://ebarge.ir/index.php?option=com_jbackend&view=request&action={ACTION}&module={MODULE}&resource={RESOURCE}
```

### Verified Modules and Resources

#### Authentication Module (`module=user`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `login` | POST | User login | ✅ Yes |
| `mobileregister` | POST | User registration | ✅ Yes |
| `mobileconfirm` | POST | OTP verification for registration | ✅ Yes |
| `logout` | GET | User logout | ✅ Yes |
| `status` | GET | Check user session status | ✅ Yes |
| `goldshopdata` | GET | Get shop product data | ✅ Yes |

#### Books Module (`module=books`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `getbooks` | GET | Retrieve user's books | ✅ Yes |
| `getbarges` | GET | Get user transactions | ✅ Yes |
| `getranks` | GET | Get user rankings | ✅ Yes |
| `getazbazis` | GET | Get available games | ✅ Yes |
| `followbook` | POST | Follow/unfollow book | ✅ Yes |

#### Pages Module (`module=pages`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `getpages` | GET/POST | Get page content | ✅ Yes |
| `getcontents` | GET | Get page contents | ✅ Yes |
| `usernotes` | GET | Get user notes | ✅ Yes |
| `uviewaddup` | POST | Track page views | ✅ Yes |

#### Azbazi Module (`module=books`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `getazbaziqs` | GET | Get game questions | ✅ Yes |
| `uponlineuqv` | POST | Update question view | ✅ Yes |
| `upUVQPageHint` | POST | Update question hint | ✅ Yes |
| `azscorerate` | POST | Update game score/rating | ✅ Yes |

#### Payment Module (`module=user`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `goldpurchase` | GET | Process gold purchase | ✅ Yes |

#### System Module (`module=books`)
| Resource | Action | Description | Verified |
|----------|--------|-------------|----------|
| `versioning` | POST | Check app version | ✅ Yes |

## Request/Response Patterns

### Form Data Requests
Most POST requests use `FormData`:
```dart
FormData formData = new FormData.fromMap({
  "username": username,
  "password": password,
  "action": "post",
  "module": "user",
  "resource": "login",
});
```

### Response Structure
```json
{
  "status": "ok|ko",
  "data": {...},
  "error_code": "ERROR_CODE",
  "error_description": "Human readable error"
}
```

### Error Handling
- HTTP status codes checked (200 = success)
- Application-level status field (`ok`/`ko`)
- Error codes for specific error types
- ⚠️ Inconsistent error handling across codebase (technical debt)

## Authentication Flow

### Session Management
1. User logs in with credentials
2. Server returns session cookie
3. Cookie stored locally via `PersistCookieJar`
4. Subsequent requests include cookie automatically
5. Session validated on app startup

### Token/Cookie Handling
- `FlutterSecureStorage` for credential storage
- Cookie persistence across app restarts
- WebView cookie synchronization for payment flows

## API Client Implementation

### Current State (Technical Debt)
⚠️ API calls are scattered across the application rather than using a centralized service:

- `UserProvider` - Authentication and user data API calls
- `BookProvider` - Book and content API calls
- `QuestionProvider` - Quiz data and submissions API calls
- `ContentProvider` - Content retrieval API calls
- `BargProvider` - Transaction and ranking API calls
- `AzbaziProvider` - Game API calls
- Direct API calls in screens (e.g., `goldShop.dart`)

### Service Layer (`lib/services/GlobalKeys.dart`)
Limited centralized API helpers:
- Base URL configuration
- Internet connectivity checking
- Page/content retrieval methods
- ⚠️ Does not centralize API calls

## Network Resilience

### Offline Support
- Local database caching
- Graceful degradation when offline
- ⚠️ No queue for pending operations
- ⚠️ Limited sync when connectivity restored

### Retry Logic
- Timeout configurations (18s connect, 15s receive)
- Manual retry implementation in providers
- ⚠️ No exponential backoff implemented

### Error Recovery
- Automatic session refresh on auth errors
- User-friendly error messages
- Fallback to cached data

## Security Considerations

### Transport Security
- HTTPS for production
- ⚠️ SSL certificate bypass for development (MyHttpOverrides) - CRITICAL SECURITY RISK
- Certificate pinning not implemented

### Data Protection
- Credentials stored in secure storage
- Sensitive data not logged
- Request/response logging minimal

### API Security
- Session-based authentication
- ⚠️ CSRF protection not implemented
- ⚠️ Rate limiting not verified

## Performance Optimization

### Request Optimization
- ⚠️ No batch requests implemented
- ⚠️ No conditional requests with ETags
- Compression (gzip) - depends on server config

### Caching Strategy
- Local database as primary cache
- In-memory caching in providers
- Cache invalidation on data changes

## Monitoring and Debugging

### Logging
- Print statements for debugging
- Error logging to console
- No structured logging framework

### Metrics
- No explicit API metrics collection
- Performance monitoring not implemented

## Testing Considerations

### Current State
⚠️ No automated testing framework implemented for API calls

### Mock Strategy Needed
- API mocking framework required for testing
- Integration tests needed for API interactions
- Unit tests for API response handling

### Test Environments
- Development URLs configurable
- Staging environment unknown
- Production endpoint hardcoded

## Known Issues and Technical Debt

### API Call Duplication
⚠️ Multiple files recreate the same API call patterns:
```dart
// This pattern is duplicated ~30 times
var dio = Dio(GlobalKeys.options);
Directory appDocDir = await getApplicationDocumentsDirectory();
String appDocPath = appDocDir.path;
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath+"/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

### Inconsistent Error Handling
⚠️ Error handling varies significantly across API call sites

### Session Management Issues
⚠️ Multiple cookie jars may lead to session inconsistency

## Future Enhancement Opportunities

### API Layer Improvements
- Centralized API client/service to eliminate duplication
- Request/response interceptors for consistent behavior
- Automatic retry with backoff
- Request cancellation support
- Better error typing and handling

### Security Enhancements
- Remove SSL certificate bypass for production
- Implement CSRF protection
- Add certificate pinning
- OAuth2/OpenID Connect integration consideration

### Performance Improvements
- Request deduplication
- Background sync optimization
- Progressive data loading
- Response caching strategy