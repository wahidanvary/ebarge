# AGENTS.md

# Ebarge - AI Agent Instructions

## Project Purpose
Ebarge is an educational gamification application built with Flutter that transforms traditional learning into interactive experiences through digital textbooks, educational games (Azbazi), and AI-assisted question generation.

## Tech Stack
- **Main Application**: Flutter/Dart
- **Database**: SQLite via sqflite package
- **Network**: Dio HTTP client with cookie-based authentication
- **State Management**: Provider pattern
- **Payment**: CafeBazaar integration via flutter_poolakey plugin
- **Target Platforms**: Android (primary), iOS, Web, Windows

## Important Directories
- `lib/azbazi/` - Educational game system
- `lib/database/` - Local database and SQL queries
- `lib/models/` - Application data models
- `lib/providers/` - State management and business logic
- `lib/screens/` - Main application screens
- `lib/services/` - External integrations and utilities
- `lib/widgets/` - Reusable UI components
- `assets/` - Images, fonts, KaTeX assets
- `docs/AI/` - AI-optimized technical documentation (PRIMARY REFERENCE FOR AGENTS)

## Architecture Summary
Ebarge follows a hybrid architecture where:
- State management uses the Provider pattern
- Business logic is embedded within Providers rather than separated
- Local SQLite database provides offline functionality
- REST-like API communication with cookie-based session management
- Payment processing implemented directly in UI layer (ANTI-PATTERN)

## State Management
- Provider pattern with ChangeNotifier
- Key providers: UserProvider, BookProvider, QuestionProvider, AzbaziProvider
- State persisted locally and synchronized with backend
- See `docs/AI/ARCHITECTURE_MAP.md` for details

## Database
- SQLite via sqflite package
- Singleton database helper pattern
- Separate query files for each entity
- NO VERIFIED MIGRATION STRATEGY FOUND
- See `docs/AI/DATABASE_MAP.md` for schema details

## Network/API
- Dio HTTP client with cookie-based authentication
- REST-like endpoints with module/resource pattern
- CRITICAL SECURITY ISSUE: SSL certificate validation bypass
- ~30+ instances of duplicated HTTP client pattern (TECHNICAL DEBT)
- See `docs/AI/API_MAP.md` for endpoint details

## Authentication
- Session-based with cookie persistence
- Credentials stored in FlutterSecureStorage
- Deep linking integration with pre-authentication handling
- See `docs/AI/AUTHENTICATION.md` for flow details

## Payment
- CafeBazaar integration via flutter_poolakey
- GOLD SHOP LOGIC IN UI LAYER (ANTI-PATTERN)
- Virtual currency (gold/Zafran) economy
- See `docs/AI/PAYMENT.md` for system details

## Azbazi (Educational Games)
- Question-based quiz system with scoring
- Game creation and management features
- Achievement and reward tracking
- See `docs/AI/AZBAZI.md` for mechanics

## Important Security Rules
1. **NEVER** modify `MyHttpOverrides` SSL certificate bypass
2. **NEVER** hard-code API keys or passwords
3. **NEVER** commit secrets or sensitive credentials
4. **NEVER** store passwords in plain text without justification
5. **ALWAYS** validate and sanitize user inputs
6. See `docs/AI/SECURITY.md` for comprehensive security guide

## Build Commands
```bash
# Standard Flutter commands
flutter pub get
flutter build apk
flutter build ios
flutter build web
flutter build windows

# Development commands
flutter run
flutter run -d web
flutter run -d windows
```

## Test Commands
```bash
# Current testing status: MINIMAL COVERAGE
flutter test  # Runs existing basic tests
# See docs/AI/TESTING.md for testing strategy
```

## Analysis Commands
```bash
flutter analyze  # Static analysis
flutter format   # Code formatting
flutter pub outdated  # Dependency check
```

## Important Development Rules

### Before Modifying Code:
1. **Read relevant AI documentation** in `docs/AI/` first
2. **Identify dependencies** using `docs/AI/CHANGE_IMPACT_MAP.md`
3. **Understand existing patterns** rather than rewriting
4. **Check security implications** in `docs/AI/SECURITY.md`

### While Modifying Code:
1. **Make minimal changes** to achieve objectives
2. **Preserve existing functionality** unless explicitly requested to change
3. **Follow existing code patterns** and conventions
4. **Do not refactor large sections** without explicit approval

### After Modifying Code:
1. **Run formatting** if appropriate (`flutter format`)
2. **Run static analysis** (`flutter analyze`)
3. **Test related functionality** manually
4. **Inspect git diff** for unintended changes
5. **Report exactly what changed**

## DO NOT:
- Invent APIs or features not verified in code
- Modify unrelated modules unnecessarily
- Perform large refactors without explicit approval
- Expose secrets or disable security features
- Change database schema without migration planning
- Modify payment logic casually
- Change public behavior without verification

## Workflow for AI Agents:
1. **Inspect** relevant AI documentation (`docs/AI/`)
2. **Inspect** relevant source files (minimal necessary)
3. **Identify** dependencies and data flows
4. **Create** small, focused plan
5. **Modify** only required files
6. **Run** targeted verification
7. **Review** git diff
8. **Report** exactly what changed

## Primary AI Documentation References:
- `docs/AI/PROJECT_CONTEXT.md` - Project overview and context
- `docs/AI/ARCHITECTURE_MAP.md` - Actual architecture
- `docs/AI/CODE_MAP.md` - File structure and relationships
- `docs/AI/SECURITY.md` - Critical security issues
- `docs/AI/TECHNICAL_DEBT.md` - Known technical debt
- `docs/AI/CHANGE_GUIDELINES.md` - Change protocols
- `docs/AI/DEVELOPMENT_PROTOCOL.md` - Development workflow