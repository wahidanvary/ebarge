# Ebarge Authentication System

## Overview
Ebarge implements a session-based authentication system with user registration, login, OTP verification, and persistent session management. The system combines local storage with server-side session validation to provide a seamless user experience.

## Core Components

### Authentication Provider
- **Primary**: `UserProvider` manages all authentication state and operations
- **Storage**: `FlutterSecureStorage` for credential persistence
- **Session**: Cookie-based authentication with `PersistCookieJar`
- **Database**: Local SQLite storage for user profile data

### Key Models
- `UserModel` - User profile, credentials, and session information
- Session tokens and cookies for persistent authentication

## Authentication Flow

### 1. Application Startup
- `main.dart` initializes the app and database
- `UserProvider.instance()` created and `checkLogin()` called
- Local storage checked for existing credentials
- If credentials exist, session validation attempted

### 2. Session Validation
- Credentials retrieved from `FlutterSecureStorage`
- API call to `/user/status` to validate existing session
- If valid session, user data loaded from local database
- If invalid session, automatic re-authentication attempted

### 3. User Login
- User provides username and password in login form
- Credentials validated for basic requirements
- `sendLoginRequest()` method called with credentials
- API request to `/user/login` with FormData
- Server response processed and user data stored
- Credentials saved to `FlutterSecureStorage`
- User data cached in local SQLite database

### 4. User Registration
- User provides registration details (name, mobile, email, etc.)
- `signUpUser()` method called with user data
- API request to `/user/mobileregister` with FormData
- Server sends OTP to user's mobile number
- Registration confirmation required

### 5. OTP Verification
- User receives OTP via SMS
- `signUpConfirm()` method called with OTP code
- API request to `/user/mobileconfirm` with code
- If successful, automatic login performed
- User profile created and stored

### 6. Session Persistence
- Credentials stored in `FlutterSecureStorage`
- Session cookies managed by `PersistCookieJar`
- WebView cookie synchronization for payment flows
- Automatic session refresh on app restart

## Technical Implementation

### Provider Layer
- `UserProvider` handles all authentication operations
- State management through `ChangeNotifier`
- Status tracking with `Status` enum (Uninitialized, Authenticating, Authenticated, Unauthenticated)
- Deep link handling for game invitations before authentication

### Session Management
- Cookie-based authentication using Dio interceptors
- `PersistCookieJar` for cookie persistence across app restarts
- Multiple cookie jar instances created per API call (TECHNICAL DEBT)
- WebView cookie synchronization for payment flows

### Data Flow
```
App Startup
    ↓
UserProvider.checkLogin()
    ↓
FlutterSecureStorage.read()
    ↓
If Credentials Found:
  → API: /user/status
    ↓
If Valid Session:
  → Load User from Database
    ↓
Authenticated State
    ↓
If Invalid Session:
  → sendLoginRequest()
    ↓
API: /user/login
    ↓
User Data Processing
    ↓
FlutterSecureStorage.write()
    ↓
userQueries.saveUserToDB()
    ↓
Authenticated State
```

## Security Issues

### Critical Vulnerabilities
1. **SSL Certificate Validation Bypass**: 
   ```dart
   badCertificateCallback = (cert, host, port) => true;
   ```
   This accepts ANY SSL certificate, making the app vulnerable to man-in-the-middle attacks.

2. **Plain Text Password Storage**: 
   Passwords stored directly in `FlutterSecureStorage` without hashing or encryption.

3. **Session Inconsistency**: 
   Multiple cookie jars created per API call can lead to session state inconsistencies.

4. **No CSRF Protection**: 
   API endpoints lack CSRF token validation.

### Authentication Anti-Patterns
1. **Credentials in State**: 
   Passwords stored in `UserModel` which is accessible through provider state.

2. **Scattered Authentication Logic**: 
   Authentication operations spread across multiple methods in UserProvider.

3. **No Token Expiration Handling**: 
   No automatic refresh or expiration checking for authentication tokens.

## Technical Debt

### Code Structure Issues
- Multiple cookie jar instances created per API call (~30+ instances)
- Authentication and user profile management mixed in single provider
- No centralized authentication service
- Inconsistent error handling across authentication methods

### Session Management Problems
- No unified session handling across the application
- Cookie storage not properly synchronized between API calls
- No session timeout or refresh mechanisms
- WebView session management separate from main API sessions

### Error Handling
- Basic error messages without detailed logging
- No retry mechanisms for failed authentication
- Limited account lockout or security event handling
- No distinction between network errors and authentication failures

## Data Models

### UserModel Structure
- `status`: Authentication status (ok/ko)
- `user_id`: Unique user identifier
- `username`: User's login name
- `name`, `family`: User's real name
- `email`, `tell_mobile`: Contact information
- `zafran`: Virtual currency balance
- `time_balance`: Time resource balance
- `gold_amount`: Gold currency balance
- `wallet_id`: Wallet identifier
- `session_id`: Current session identifier
- `password`: User password (SECURITY RISK)
- Authentication error codes and descriptions

### Local Storage
- `FlutterSecureStorage` keys: "username", "password"
- SQLite database table: `user_tbl`
- SharedPreferences for additional session data
- Cookie storage in application documents directory

## API Endpoints

### Authentication Endpoints
1. **Login**: `POST /user/login`
   - Parameters: username, password
   - Response: User data, session information

2. **Registration**: `POST /user/mobileregister`
   - Parameters: username, name, family, mobile, email, password
   - Response: Registration status, OTP sent

3. **OTP Verification**: `POST /user/mobileconfirm`
   - Parameters: code
   - Response: Verification status, user data

4. **Session Validation**: `GET /user/status`
   - Parameters: None (cookie-based)
   - Response: Current user data, session validity

5. **Logout**: `GET /user/logout`
   - Parameters: None (cookie-based)
   - Response: Logout confirmation, session termination

## Deep Link Integration

### Pre-Authentication Flow
- Deep links for game invitations handled in `main.dart`
- Pending links stored in `UserProvider.pendingAzbaziLink`
- After successful authentication, user redirected to pending game
- Session validation occurs before deep link processing

### Link Structure
- Pattern: `ebarge://azbazi/{game_id}`
- Parameters: Game identifier for direct access
- State management: Pending link storage until authentication

## Logout Process

### Local Cleanup
- Delete credentials from `FlutterSecureStorage`
- Clear WebView cookies
- Reset SharedPreferences
- Delete user data from local database
- Close and delete database file

### Server-Side
- API call to `/user/logout` to invalidate session
- Server response validation
- Status update in local state

### UI Navigation
- Return to login screen
- Clear all authenticated routes
- Reset provider states

## Future Enhancement Opportunities

### Security Improvements
1. **Token-Based Authentication**: Replace password storage with JWT or OAuth tokens
2. **Certificate Pinning**: Implement proper SSL certificate validation
3. **CSRF Protection**: Add CSRF tokens to all authentication requests
4. **Biometric Authentication**: Integrate fingerprint or face recognition
5. **Multi-Factor Authentication**: Add additional verification steps

### Architecture Improvements
1. **Centralized Auth Service**: Dedicated service layer for authentication operations
2. **Repository Pattern**: Separate authentication data access from business logic
3. **Improved Session Management**: Unified session handling across all components
4. **Enhanced Error Handling**: Comprehensive authentication error categorization

### Feature Improvements
1. **Social Login**: Integration with Google, Apple, or other providers
2. **Password Reset**: Self-service password recovery mechanism
3. **Account Management**: User profile editing and security settings
4. **Session Timeout**: Automatic logout after inactivity period
5. **Device Management**: Multi-device session tracking and control