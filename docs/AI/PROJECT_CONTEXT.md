# Ebarge Project Context

## Project Overview
Ebarge is an educational gamification application built with Flutter that provides:
- Digital educational textbooks
- Interactive learning content
- Azbazi educational quiz-games
- AI-assisted question generation
- User accounts and progress tracking
- Virtual currencies (Zafran economy)
- CafeBazaar in-app purchases
- Notes and annotations system

## Technology Stack
- **Main Application**: Flutter/Dart
- **Target Platforms**: Android (primary), iOS, Web, Windows
- **Database**: SQLite via sqflite package
- **Network**: Dio HTTP client with cookie-based authentication
- **Payment**: CafeBazaar integration via flutter_poolakey plugin
- **State Management**: Provider pattern
- **Mathematics**: KaTeX assets for formula rendering

## Repository Structure
```
lib/
├── azbazi/           # Educational game system
├── database/         # Local database and SQL queries
├── models/           # Application data models
├── providers/        # State management and business logic
├── screens/          # Main application screens
├── services/         # External integrations and utilities
├── widgets/          # Reusable UI components
├── utils/            # Utility functions
assets/               # Images, fonts, KaTeX assets
flutter_poolakey/     # Local CafeBazaar payment plugin
image_painter/        # Local image annotation package
fieldssettings/       # Local settings UI package
cupertino_settings/   # Local settings UI package
docs/                 # Project documentation
```

## Key Components
1. **Authentication System** - User login/logout with secure credential storage
2. **Educational Content System** - Digital textbooks with page viewing and note-taking
3. **Azbazi Game System** - Educational quiz-games based on book content
4. **Virtual Economy** - Zafran currency system and gold shop
5. **Payment Integration** - CafeBazaar in-app purchases
6. **Data Management** - Local SQLite database with offline functionality

## Critical Security Issues
1. **SSL Certificate Validation Bypass** - Accepts any certificate, vulnerable to MITM attacks
2. **Password Storage** - Plain text passwords stored with FlutterSecureStorage
3. **Session Management** - Multiple cookie jars causing potential inconsistency
4. **Payment Logic** - Implemented directly in UI layer without proper security controls

## Technical Debt
1. **Scattered API Calls** - ~30+ instances of duplicated Dio/PersistCookieJar pattern
2. **No Centralized HTTP Client** - Each provider/service creates its own instances
3. **No Database Migration Strategy** - Only onCreate method exists
4. **Inconsistent Error Handling** - Varies significantly across API call sites
5. **No Automated Testing** - Only basic widget test exists