# Ebarge Code Map

## Directory Structure
```
lib/
├── main.dart                 # Application entry point
├── azbazi/                   # Educational game system
│   ├── azbaziService.dart    # Game logic service
│   ├── gamePage.dart         # Game gameplay screen
│   ├── landingPage.dart      # Game selection screen
│   └── resultPage.dart       # Game results screen
├── database/                 # Database layer
│   ├── ebargeDBHelper.dart   # Database helper (singleton)
│   ├── userQueries.dart      # User database operations
│   ├── booksQueries.dart     # Books database operations
│   ├── bargesQueries.dart    # Transactions database operations
│   ├── azbaziQueries.dart    # Game database operations
│   └── questionsQueries.dart # Questions database operations
├── models/                   # Data models
│   ├── userModel.dart        # User data model
│   ├── bookModel.dart        # Book data model
│   ├── bargModel.dart        # Transaction data model
│   ├── azbaziModel.dart      # Game data model
│   ├── questionModel.dart    # Question data model
│   ├── pageModel.dart        # Page content model
│   └── shopModel.dart        # Shop product model
├── providers/                # State management and business logic
│   ├── userProvider.dart     # Authentication and user state
│   ├── bookProvider.dart     # Book content management
│   ├── questionProvider.dart # Quiz/question state management
│   ├── azbaziProvider.dart   # Game state management
│   ├── contentProvider.dart  # Content retrieval management
│   └── bargProvider.dart     # Transaction and ranking data
├── screens/                  # Application screens
│   ├── login/                # Authentication flow
│   │   ├── login.dart        # Login screen
│   │   ├── register.dart     # Registration screen
│   │   └── linkLoaderPage.dart # Deep link handler
│   ├── books/                # Book browsing and content
│   │   ├── myBooks.dart      # User books screen
│   │   └── goldShop.dart     # In-app purchase screen
│   ├── pageScreen/           # Content viewing
│   └── azBaziScreen/         # Game browsing and management
├── services/                 # External integrations
│   ├── GlobalKeys.dart       # API configuration and utilities
│   └── accessCheck.dart      # Access control utilities
├── widgets/                  # Reusable UI components
├── utils/                    # Utility functions
│   ├── hexColor.dart         # Color utility
│   └── utilities.dart        # General utilities
assets/                       # Application assets
├── images/                   # Image assets
├── fonts/                    # Font files
└── katex/                    # Mathematical formula assets
```

## Key Files and Their Roles

### Entry Point
- `lib/main.dart` - Application initialization, deep linking, authentication flow

### Core Providers
- `lib/providers/userProvider.dart` - Authentication, user profile, session management
- `lib/providers/bookProvider.dart` - Book content management and retrieval
- `lib/providers/questionProvider.dart` - Quiz/question state and management
- `lib/providers/azbaziProvider.dart` - Game state and gameplay logic
- `lib/providers/bargProvider.dart` - Transaction history and ranking data
- `lib/providers/contentProvider.dart` - Content retrieval and management

### Database Layer
- `lib/database/ebargeDBHelper.dart` - Database initialization and connection management
- `lib/database/userQueries.dart` - User data CRUD operations
- `lib/database/booksQueries.dart` - Book data CRUD operations
- `lib/database/bargesQueries.dart` - Transaction data CRUD operations
- `lib/database/azbaziQueries.dart` - Game data CRUD operations
- `lib/database/questionsQueries.dart` - Question data CRUD operations

### Models
- `lib/models/userModel.dart` - User data structure and JSON mapping
- `lib/models/bookModel.dart` - Book data structure and JSON mapping
- `lib/models/bargModel.dart` - Transaction data structure and JSON mapping
- `lib/models/azbaziModel.dart` - Game data structure and JSON mapping
- `lib/models/questionModel.dart` - Question data structure and JSON mapping
- `lib/models/pageModel.dart` - Page content data structure
- `lib/models/shopModel.dart` - Shop product data structure

### Network Services
- `lib/services/GlobalKeys.dart` - API endpoint configuration and utility functions
- `lib/services/accessCheck.dart` - Access control and validation utilities

### Payment System
- `lib/screens/books/goldShop.dart` - In-app purchase UI and logic
- `flutter_poolakey/` - Local CafeBazaar payment plugin

### Game System
- `lib/azbazi/azbaziService.dart` - Game logic and question processing
- `lib/azbazi/gamePage.dart` - Game gameplay interface
- `lib/azbazi/landingPage.dart` - Game selection and browsing
- `lib/azbazi/resultPage.dart` - Game results and scoring

### Authentication Flow
- `lib/screens/login/login.dart` - Login screen and form
- `lib/screens/login/register.dart` - Registration and OTP verification
- `lib/screens/login/linkLoaderPage.dart` - Deep link processing

### Content System
- `lib/screens/books/myBooks.dart` - Book browsing and management
- `lib/screens/pageScreen/` - Content viewing and note-taking

## File Dependencies
1. **UserProvider** → GlobalKeys, userQueries, UserModel, FlutterSecureStorage
2. **BookProvider** → GlobalKeys, booksQueries, BookModel
3. **GoldShop** → UserProvider, GlobalKeys, ShopModel, Poolakey
4. **Main** → All providers, deep linking, database helper
5. **Database Helper** → All query files, all models