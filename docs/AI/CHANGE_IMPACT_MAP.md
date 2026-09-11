# Ebarge Change Impact Map

## Authentication System
**IF YOU CHANGE**: `UserProvider`, login, registration, session management
**YOU SHOULD INSPECT**: 
- `lib/providers/userProvider.dart`
- `lib/screens/login/`
- `lib/services/GlobalKeys.dart`
- `lib/database/userQueries.dart`
- `lib/models/userModel.dart`
**YOU MAY AFFECT**: 
- User login and registration flow
- Session persistence and validation
- Credential storage and security
- Deep linking with authentication
- User profile management
**YOU SHOULD TEST**: 
- Login with valid credentials
- Login with invalid credentials
- Registration and OTP verification
- Logout and session termination
- Session persistence across app restarts
- Deep link handling before/after authentication

## Payment System
**IF YOU CHANGE**: GoldShop, purchase flow, wallet management
**YOU SHOULD INSPECT**: 
- `lib/screens/books/goldShop.dart`
- `flutter_poolakey/` plugin
- `lib/providers/userProvider.dart` (goldShopData method)
- `lib/models/shopModel.dart`
- `lib/models/userModel.dart` (wallet fields)
- `lib/providers/bargProvider.dart` (transaction history)
**YOU MAY AFFECT**: 
- In-app purchase processing
- Wallet balance calculation and display
- Transaction history recording
- Purchase verification and consumption
- User gold and Zafran currency balances
**YOU SHOULD TEST**: 
- Product display and information
- Purchase initiation and CafeBazaar flow
- Purchase token consumption
- Server-side verification
- Wallet balance updates
- Transaction history recording
- Error handling (insufficient funds, network issues)

## Azbazi Game System
**IF YOU CHANGE**: Game logic, questions, scoring, results
**YOU SHOULD INSPECT**: 
- `lib/azbazi/` directory
- `lib/providers/azbaziProvider.dart`
- `lib/providers/questionProvider.dart`
- `lib/database/questionsQueries.dart`
- `lib/database/azbaziQueries.dart`
- `lib/models/questionModel.dart`
- `lib/models/azbaziModel.dart`
**YOU MAY AFFECT**: 
- Game availability and loading
- Question generation and presentation
- Answer processing and scoring
- Achievement and reward systems
- Leaderboard and ranking calculations
- Hint system and coin consumption
**YOU SHOULD TEST**: 
- Game discovery and loading
- Question display and interaction
- Answer submission and validation
- Scoring calculation and recording
- Hint system functionality
- Result display and achievement tracking
- Error handling (network issues, invalid questions)

## Book Content System
**IF YOU CHANGE**: Books, pages, content viewing, notes
**YOU SHOULD INSPECT**: 
- `lib/providers/bookProvider.dart`
- `lib/screens/pageScreen/`
- `lib/database/booksQueries.dart`
- `image_painter/` package
- `lib/services/GlobalKeys.dart` (getOnePageData, addUpUView)
- `lib/models/bookModel.dart`
- `lib/models/pageModel.dart`
**YOU MAY AFFECT**: 
- Book browsing and discovery
- Content loading and navigation
- Note-taking and annotation features
- Page view tracking and statistics
- Content search and filtering
- Offline access and synchronization
**YOU SHOULD TEST**: 
- Book listing and filtering
- Page loading and rendering
- Note creation and editing
- Annotation tools functionality
- Page view tracking
- Content search functionality
- Offline access and sync

## Database Layer
**IF YOU CHANGE**: Database schema, queries, models
**YOU SHOULD INSPECT**: 
- `lib/database/ebargeDBHelper.dart`
- All `*Queries.dart` files
- All `*Model.dart` files in `lib/models/`
- Provider files that use database operations
- Migration considerations and strategies
**YOU MAY AFFECT**: 
- Data persistence and integrity
- User profiles and preferences
- Book and content storage
- Game data and progress tracking
- Transaction and purchase history
- Note and annotation storage
**YOU SHOULD TEST**: 
- Data saving and retrieval
- Data integrity and consistency
- Query performance and efficiency
- Error handling (disk full, corruption)
- Migration scenarios (if applicable)
- Cross-table relationships and constraints

## API Layer
**IF YOU CHANGE**: API endpoints, request/response handling, error handling
**YOU SHOULD INSPECT**: 
- `lib/services/GlobalKeys.dart`
- All provider files with API calls
- Session management in providers
- Cookie handling patterns
- Error handling and retry logic
**YOU MAY AFFECT**: 
- Network communication reliability
- Authentication and session management
- Data synchronization with backend
- Error messaging and user feedback
- Performance and responsiveness
**YOU SHOULD TEST**: 
- API connectivity and response times
- Authentication and session handling
- Data synchronization and consistency
- Error handling and recovery
- Offline behavior and caching
- Rate limiting and throttling (if applicable)

## Content Management System
**IF YOU CHANGE**: Book organization, content structure, metadata
**YOU SHOULD INSPECT**: 
- `lib/providers/bookProvider.dart`
- `lib/models/bookModel.dart`
- `lib/database/booksQueries.dart`
- `lib/screens/books/myBooks.dart`
- Content categorization and tagging
- Search and filtering functionality
**YOU MAY AFFECT**: 
- Book discovery and browsing
- Content organization and navigation
- Search relevance and performance
- User content preferences and history
- Recommendation and suggestion systems
**YOU SHOULD TEST**: 
- Book listing and categorization
- Search functionality and accuracy
- Content filtering and sorting
- Metadata display and editing
- Performance with large content sets

## User Interface System
**IF YOU CHANGE**: UI components, navigation, user experience
**YOU SHOULD INSPECT**: 
- `lib/screens/` directory
- `lib/widgets/` directory
- Navigation and routing logic
- State management and data flow
- Accessibility and internationalization
**YOU MAY AFFECT**: 
- User experience and satisfaction
- App navigation and flow
- Accessibility compliance
- Internationalization support
- Performance and responsiveness
**YOU SHOULD TEST**: 
- UI rendering and layout
- Navigation and routing
- User interaction and feedback
- Accessibility features
- Performance on different device sizes
- Localization and RTL support

## Notification and Alert System
**IF YOU CHANGE**: User notifications, alerts, messaging
**YOU SHOULD INSPECT**: 
- Flushbar and snackbar implementations
- In-app messaging systems
- Push notification integration (if any)
- User feedback and error messaging
- Achievement and progress notifications
**YOU MAY AFFECT**: 
- User awareness of app events
- Error communication and resolution
- Achievement recognition and motivation
- User engagement and retention
- Accessibility of important information
**YOU SHOULD TEST**: 
- Notification display and timing
- Error message clarity and usefulness
- Achievement notification triggers
- User action responses to notifications
- Accessibility of notification content