# Ebarge Architecture Map

## Actual Architecture
Ebarge follows a loosely structured architecture with the following components:

### Entry Point
- `lib/main.dart` - Application initialization, deep linking, authentication flow

### State Management Layer
- Provider pattern implemented through ChangeNotifier
- Providers contain both state management and business logic
- Key providers:
  - `UserProvider` - Authentication and user state
  - `BookProvider` - Book content management
  - `QuestionProvider` - Quiz/question state
  - `AzbaziProvider` - Game state management
  - `ContentProvider` - Educational content management
  - `BargProvider` - Transaction and ranking data

### Data Layer
- **Local Database**: SQLite via sqflite package
- **Database Helper**: `lib/database/ebargeDBHelper.dart` (singleton pattern)
- **Query Layer**: Separate files for each entity:
  - `userQueries.dart`
  - `booksQueries.dart`
  - `bargesQueries.dart`
  - `azbaziQueries.dart`
  - `questionsQueries.dart`
- **Models**: Data structures in `lib/models/`

### Network Layer
- **HTTP Client**: Dio package
- **Session Management**: Cookie-based authentication with PersistCookieJar
- **Base Configuration**: `lib/services/GlobalKeys.dart`
- **API Pattern**: REST-like endpoints with module/resource structure

### UI Layer
- **Screens**: Main application pages in `lib/screens/`
- **Widgets**: Reusable UI components in `lib/widgets/`
- **Custom Components**: Specialized UI elements for specific features

### Business Logic Layer
- Embedded within Providers rather than separated
- Some utility functions in `lib/services/`
- Payment logic directly in UI components

### External Integrations
- **Payment**: CafeBazaar via flutter_poolakey plugin
- **Deep Linking**: app_links package
- **Annotations**: image_painter package
- **Settings**: fieldssettings and cupertino_settings packages

## Architectural Inconsistencies
1. **No Centralized API Service** - API calls scattered across providers and UI
2. **Business Logic in UI** - Payment processing in goldShop.dart
3. **Inconsistent HTTP Client Usage** - Multiple Dio instances created per call
4. **No Repository Pattern** - Direct database access from providers

## Intended vs Actual Architecture
**Intended**: Layered architecture with clear separation of concerns
**Actual**: Hybrid architecture with business logic mixed in providers and UI

## Critical Flows
1. **Authentication Flow**: main.dart → UserProvider → API → Database
2. **Content Flow**: BookProvider → API/Database → UI
3. **Game Flow**: AzbaziProvider → API/Database → Azbazi screens
4. **Payment Flow**: GoldShop UI → Poolakey → API verification