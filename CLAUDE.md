# Ebarge Flutter Project - AI Coding Agent Instructions

## 🏗️ Architecture and Design Patterns
- **Architecture:** Layered architecture with clear separation of concerns
- **State Management:** Provider pattern
- **Target Platforms:** Android (Google Play & Cafe Bazaar), iOS, Web, Windows
- **Database:** SQLite via sqflite package
- **Network:** Dio HTTP client with cookie-based authentication
- **Payment:** CafeBazaar integration via flutter_poolakey plugin

## 📁 Project Structure
- `lib/main.dart`: Application entry point with deep linking and authentication
- `lib/models/`: Data models (UserModel, BookModel, QuestionModel, etc.)
- `lib/screens/`: Main application screens (login, books, games, etc.)
- `lib/widgets/`: Reusable UI components
- `lib/providers/`: State management and business logic (UserProvider, QuestionProvider, etc.)
- `lib/services/`: API communication and external integrations (GlobalKeys, azbazi_service, etc.)
- `lib/database/`: Local database management (ebargeDBHelper, query files)
- `lib/utils/`: Utility functions and helper classes
- `lib/azbazi/`: Educational game system (Azbazi engine and gameplay)
- `lib/screens/login/`: Authentication flow components
- `lib/screens/books/`: Book browsing and content management
- `lib/screens/pageScreen/`: Content viewing and note-taking
- `lib/screens/azBaziScreen/`: Game browsing and management
- `assets/`: Images, fonts, KaTeX assets for mathematical expressions
- `flutter_poolakey/`: Local CafeBazaar payment plugin
- `image_painter/`: Local image annotation package
- `fieldssettings/` and `cupertino_settings/`: Local settings UI packages

## 🛠️ Coding Rules and Guidelines
- Follow the existing architectural patterns (Provider for state management)
- Maintain separation of concerns (UI in screens/widgets, logic in providers)
- Use const constructors for immutable widgets to optimize performance
- Implement proper error handling with try-catch blocks
- Use descriptive variable and function names in English
- Write comments in Persian for UI-related code and English for technical implementation
- Follow the DRY (Don't Repeat Yourself) principle
- Implement proper dispose methods for resources
- Use proper async/await patterns for asynchronous operations

## 📱 Key Features and Components

### Authentication System
- User login/logout with secure credential storage
- Session management with cookie persistence
- Deep linking support for game invitations
- Guest user support

### Educational Content System
- Digital textbooks with page viewing
- Content navigation and progress tracking
- Note-taking and annotation features
- Search and filtering capabilities

### Azbazi Game System
- Educational quiz-games based on book content
- Question generation and management
- Scoring and achievement tracking
- Multiplayer and social features

### Virtual Economy
- Zafran currency system
- Gold shop for in-app purchases
- Time balance and streak tracking
- Reward and achievement system

### Payment Integration
- CafeBazaar in-app purchases via flutter_poolakey
- Product listing and purchase verification
- Transaction history and wallet management

### Data Management
- Local SQLite database for offline functionality
- Data synchronization with backend API
- Caching strategies for performance optimization
- Data migration for version upgrades

## 🔐 Security Considerations
- Never hardcode API keys or sensitive credentials
- Use FlutterSecureStorage for credential storage
- Implement proper session management
- Validate and sanitize all user inputs
- Handle network security with HTTPS
- Implement access control checks

## 🌐 API Communication
- Base URL: https://ebarge.ir
- REST-like API endpoints with module/resource pattern
- Form data requests using Dio HTTP client
- Cookie-based session management
- Error handling with status codes and error messages

## 🧪 Testing Considerations
- Write unit tests for business logic in providers
- Create widget tests for UI components
- Implement integration tests for API interactions
- Test offline functionality and data persistence
- Verify RTL layout for Persian language support

## 📊 Performance Optimization
- Use const widgets where possible
- Implement efficient database queries
- Optimize image loading and caching
- Minimize widget rebuilds with proper state management
- Implement lazy loading for large datasets

## 🎯 Development Best Practices
- Make incremental changes that don't break existing functionality
- Follow the existing code style and patterns
- Document complex logic and architectural decisions
- Test changes thoroughly before submitting
- Handle edge cases and error conditions
- Maintain backward compatibility when possible

## ⚠️ Important Constraints
- Do not modify existing functionality without explicit request
- Preserve the existing visual design and user experience
- Maintain compatibility with Persian RTL layout
- Do not introduce breaking changes to public APIs
- Follow security best practices for data handling
- Ensure all changes work offline where applicable