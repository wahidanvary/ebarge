# Technical Debt in Ebarge

## Overview

This document identifies confirmed technical debt in the Ebarge application. These issues impact maintainability, performance, and development velocity.

## Confirmed Technical Debt Issues

### 1. Scattered API Calls

#### Current Implementation
API calls are duplicated across multiple files with identical patterns:
```dart
// Pattern repeated ~30 times across providers and services
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath+"/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

#### Impact
- Code duplication increases maintenance burden
- Inconsistent error handling across API calls
- Difficult to implement global changes to HTTP behavior
- Session management inconsistencies

#### Files Affected
- All provider files (`userProvider.dart`, `bookProvider.dart`, etc.)
- Service files (`GlobalKeys.dart`, `azbazi_service.dart`, etc.)
- Screen files with direct API calls (`goldShop.dart`, etc.)

#### Remediation
Create a centralized HTTP client service that handles:
- Cookie management
- Error handling
- Request/response interceptors
- Authentication

### 2. Inconsistent Error Handling

#### Current Implementation
Error handling varies significantly across the codebase:
```dart
// Some files have detailed error handling
} catch (e) {
  print("درخواست با خطا مواجه شد");
  return null;
}

// Others have minimal handling
} catch (e) {
  print(e);
}
```

#### Impact
- Inconsistent user experience for error scenarios
- Difficult debugging due to varying log levels
- Poor offline handling in some components
- Missing error recovery mechanisms

#### Files Affected
- All provider files
- Service files
- Screen components with API calls

#### Remediation
- Standardize error handling patterns
- Implement comprehensive error logging
- Add user-friendly error messages
- Create centralized error handling service

### 3. Multiple Dio Instances/Cookie Jars

#### Current Implementation
Each API call creates its own Dio instance and cookie jar:
```dart
// Found in ~30 locations
var dio = Dio(GlobalKeys.options);
var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(appDocPath+"/.cookies/"));
dio.interceptors.add(CookieManager(cookieJar));
```

#### Impact
- Memory overhead from multiple HTTP clients
- Session inconsistency across API calls
- Cookie synchronization issues
- Difficult to manage global HTTP settings

#### Files Affected
- All files making HTTP requests

#### Remediation
- Create singleton HTTP client service
- Implement single cookie jar for session consistency
- Add request/response interceptors for global behavior

### 4. Payment Logic in UI Layer

#### Current Implementation
Payment processing is implemented directly in UI components:
```dart
// In lib/screens/books/goldShop.dart
class GoldShopScreen extends StatefulWidget {
  // Payment methods implemented as class methods
  purchaseProduct(...) async {
    // Payment logic mixed with UI logic
  }
}
```

#### Impact
- Violates separation of concerns
- Difficult to test payment functionality
- Business logic mixed with presentation logic
- Hard to implement payment security measures

#### Files Affected
- `lib/screens/books/goldShop.dart`

#### Remediation
- Move payment logic to dedicated service layer
- Implement proper payment state management
- Add server-side verification
- Separate business logic from UI components

### 5. Lack of Automated Tests

#### Current Implementation
No automated testing framework is implemented or documented:
- No unit tests for providers or services
- No widget tests for UI components
- No integration tests for API interactions
- No test documentation or strategy

#### Impact
- High risk of regressions during development
- Difficult to verify changes don't break existing functionality
- No performance or security testing
- Manual testing burden increases with application complexity

#### Files Affected
- Entire codebase lacks test coverage

#### Remediation
- Implement unit testing framework
- Add widget tests for critical UI components
- Create integration tests for API interactions
- Establish testing guidelines and best practices

### 6. Database Migration/Versioning Concerns

#### Current Implementation
Database schema is defined statically with no migration strategy:
```dart
// In lib/database/ebargeDBHelper.dart
int dBVersion = 1;
// Only onCreate method, no onUpgrade
```

#### Impact
- No strategy for handling schema changes in production
- Risk of data loss during application updates
- No backward compatibility for database changes
- Manual database management required for updates

#### Files Affected
- `lib/database/ebargeDBHelper.dart`

#### Remediation
- Implement database migration strategy
- Add onUpgrade method for schema changes
- Create data backup and recovery mechanisms
- Document database versioning process

### 7. Missing Performance Monitoring

#### Current Implementation
No performance monitoring or profiling infrastructure:
- No startup time tracking
- No API response time monitoring
- No memory usage tracking
- No performance optimization guidelines

#### Impact
- Difficult to identify performance bottlenecks
- No baseline for performance improvements
- No alerting for performance degradation
- Poor user experience optimization

#### Files Affected
- Entire application lacks performance monitoring

#### Remediation
- Implement performance monitoring framework
- Add startup time tracking
- Monitor API response times
- Create performance optimization guidelines

### 8. Inconsistent Code Quality

#### Current Implementation
Code quality varies significantly across files:
- Some files have detailed comments and documentation
- Others have minimal or no comments
- Naming conventions are not consistently applied
- Some code uses English comments, others Persian

#### Impact
- Difficult for new developers to understand codebase
- Inconsistent maintenance practices
- Reduced code readability
- Increased onboarding time for new team members

#### Files Affected
- Entire codebase shows inconsistent quality

#### Remediation
- Establish coding standards and guidelines
- Implement code review processes
- Add comprehensive documentation
- Standardize commenting practices

## Technical Debt Priority

### High Priority
1. Scattered API calls
2. Multiple Dio instances/cookie jars
3. Payment logic in UI layer

### Medium Priority
1. Inconsistent error handling
2. Lack of automated tests
3. Database migration concerns

### Low Priority
1. Missing performance monitoring
2. Inconsistent code quality

## Recommendations

1. **Immediate**: Create centralized HTTP client service to address scattered API calls
2. **Short-term**: Move payment logic to service layer and implement automated tests
3. **Medium-term**: Implement database migration strategy and performance monitoring
4. **Long-term**: Establish comprehensive code quality standards and review processes