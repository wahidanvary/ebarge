# Ebarge API Map

## Base Configuration
- **Base URL**: `https://ebarge.ir`
- **Endpoint Pattern**: `https://ebarge.ir/index.php?option=com_jbackend&view=request&action={ACTION}&module={MODULE}&resource={RESOURCE}`
- **HTTP Client**: Dio with cookie-based session management
- **Timeout**: Connect 18s, Receive 15s
- **Security**: SSL certificate validation bypass (CRITICAL SECURITY RISK)

## Authentication Module (module=user)
| Resource | Action | Method | Description | Verified |
|----------|--------|--------|-------------|----------|
| `login` | POST | FormData | User login with credentials | ✅ Yes |
| `mobileregister` | POST | FormData | User registration with mobile | ✅ Yes |
| `mobileconfirm` | POST | FormData | OTP verification for registration | ✅ Yes |
| `logout` | GET | Query Params | User logout | ✅ Yes |
| `status` | GET | Query Params | Check user session status | ✅ Yes |
| `goldshopdata` | GET | Query Params | Get shop product data | ✅ Yes |
| `goldpurchase` | GET | Query Params | Process gold purchase | ✅ Yes |

## Books Module (module=books)
| Resource | Action | Method | Description | Verified |
|----------|--------|--------|-------------|----------|
| `getbooks` | GET | FormData/Query Params | Retrieve user's books | ✅ Yes |
| `getbarges` | GET | Query Params | Get user transactions | ✅ Yes |
| `getranks` | GET | Query Params | Get user rankings | ✅ Yes |
| `getazbazis` | GET | Query Params | Get available games | ✅ Yes |
| `followbook` | POST | FormData | Follow/unfollow book | ✅ Yes |
| `versioning` | POST | FormData | Check app version | ✅ Yes |

## Pages Module (module=pages)
| Resource | Action | Method | Description | Verified |
|----------|--------|--------|-------------|----------|
| `getpages` | GET/POST | FormData | Get page content | ✅ Yes |
| `getcontents` | GET | Query Params | Get page contents | ✅ Yes |
| `usernotes` | GET | Query Params | Get user notes | ✅ Yes |
| `uviewaddup` | POST | FormData | Track page views | ✅ Yes |

## Azbazi Module (module=books)
| Resource | Action | Method | Description | Verified |
|----------|--------|--------|-------------|----------|
| `getazbaziqs` | GET | Query Params | Get game questions | ✅ Yes |
| `uponlineuqv` | POST | FormData | Update question view | ✅ Yes |
| `upUVQPageHint` | POST | FormData | Update question hint | ✅ Yes |
| `azscorerate` | POST | FormData | Update game score/rating | ✅ Yes |

## Request/Response Patterns

### Form Data Requests
```dart
FormData formData = FormData.fromMap({
  "username": username,
  "password": password,
  "action": "post",
  "module": "user",
  "resource": "login",
});
```

### Query Parameter Requests
```
https://ebarge.ir/index.php?option=com_jbackend&view=request&action=get&module=user&resource=status
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

## Session Management
1. User logs in with credentials
2. Server returns session cookie
3. Cookie stored locally via `PersistCookieJar`
4. Subsequent requests include cookie automatically
5. Session validated on app startup

## API Client Implementation Issues
⚠️ **CRITICAL TECHNICAL DEBT**: API calls are scattered across the application rather than using a centralized service:

- `UserProvider` - Authentication and user data API calls
- `BookProvider` - Book and content API calls
- `QuestionProvider` - Quiz data and submissions API calls
- `ContentProvider` - Content retrieval API calls
- `BargProvider` - Transaction and ranking API calls
- `AzbaziProvider` - Game API calls
- Direct API calls in screens (e.g., `goldShop.dart`)
- Direct API calls in services (e.g., `GlobalKeys.dart`)

## HTTP Client Duplication Pattern
⚠️ **This pattern is duplicated ~30 times across the codebase**:
```dart
var dio = Dio(GlobalKeys.options);
Directory appDocDir = await getApplicationDocumentsDirectory();
String appDocPath = appDocDir.path;
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath+"/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

## Error Handling
- HTTP status codes checked (200 = success)
- Application-level status field (`ok`/`ko`)
- Error codes for specific error types
- ⚠️ Inconsistent error handling across codebase

## Security Issues
1. **SSL Certificate Bypass**: `badCertificateCallback = (cert, host, port) => true;`
2. **No CSRF Protection**: Vulnerable to cross-site request forgery
3. **Plain Text Passwords**: Stored in FlutterSecureStorage
4. **Session Inconsistency**: Multiple cookie jars created per API call

## Performance Considerations
- ⚠️ No batch requests implemented
- ⚠️ No conditional requests with ETags
- ⚠️ No request deduplication
- ⚠️ No automatic retry with backoff
- Local database as primary cache