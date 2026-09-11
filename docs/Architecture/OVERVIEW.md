# Ebarge Architecture Overview

## System Architecture

Ebarge follows a layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Screens   │  │   Widgets   │  │      Providers      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                      Business Logic Layer                   │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    Provider Pattern                     │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                        Data Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │  Database   │  │     Services        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                      External Systems                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │     API     │  │  Payments   │  │   Authentication    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Entry Point (`lib/main.dart`)
- Application initialization
- Deep linking handling
- Authentication flow management
- Initial route setup

### 2. State Management (Provider Pattern)
- `UserProvider` - User authentication and profile management
- `QuestionProvider` - Quiz/question state management
- `BookProvider` - Book content management
- `AzbaziProvider` - Game state management
- `ContentProvider` - Educational content management

### 3. Data Layer
- **Local Database**: SQLite via sqflite package
- **Models**: Data structures for user, books, questions, etc.
- **Database Queries**: Separate files for each entity's CRUD operations

### 4. Network Layer
- **HTTP Client**: Dio for API communication
- **API Endpoints**: Managed through GlobalKeys service
- **Session Management**: Cookie-based authentication persistence

### 5. UI Layer
- **Screens**: Main application pages (login, books, games, etc.)
- **Widgets**: Reusable UI components
- **Custom Components**: Specialized UI elements for specific features

### 6. Educational Game System (Azbazi)
- Game engine and gameplay logic
- Landing pages and game options
- Question-based quiz system
- Results and scoring mechanisms

### 7. Payment System
- CafeBazaar integration via flutter_poolakey plugin
- In-app purchase handling and verification

### 8. Content Management
- Book and educational content models
- Note-taking and annotation features
- Content viewing and navigation capabilities

## Data Flow

1. **User Interaction** → UI Layer (Screens/Widgets)
2. **State Changes** → Provider Pattern (Business Logic)
3. **Data Operations** → Database/Services (Data Layer)
4. **External Communication** → API Services (Network Layer)
5. **Results** → UI Updates (Presentation Layer)

## Architectural Patterns

### Provider Pattern
Ebarge uses the Provider package for state management, following Flutter best practices:
- Separation of UI and business logic
- Reactive updates through ChangeNotifier
- Efficient widget rebuilding

### Repository Pattern (Implicit)
While not explicitly implemented as a repository pattern, the database queries and API services serve similar purposes:
- Data abstraction layer
- Consistent data access interface
- Separation of data sources

### MVC-like Structure
The application follows a structure similar to Model-View-Controller:
- **Models**: Data structures (`lib/models/`)
- **Views**: Screens and widgets (`lib/screens/`, `lib/widgets/`)
- **Controllers**: Providers (`lib/providers/`)

## Security Considerations

- SSL certificate handling for secure communication
- Secure storage for user credentials
- Session management through cookies
- Local data encryption where appropriate

## Performance Considerations

- Lazy loading of content
- Caching of frequently accessed data
- Efficient database queries
- Optimized widget rebuilding through Provider

## Scalability

The current architecture supports:
- Modular feature development
- Easy addition of new educational content types
- Extensible game mechanics
- Flexible payment integration options